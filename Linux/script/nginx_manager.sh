#!/bin/bash

# =========================================================
# Nginx 管理面板
# Inspired by: openlist_manager.sh
# =========================================================

SERVICE_NAME="nginx"
MAIN_CONF="/etc/nginx/nginx.conf"
CONF_DIR="/etc/nginx"
BACKUP_PREFIX="nginx_backup"

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
PLAIN='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "${RED}错误: 请使用 root 用户运行此脚本。${PLAIN}" && exit 1

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

nginx_installed() {
    local pm
    pm=$(get_pkg_manager)

    case "$pm" in
        apt)
            if dpkg -l 2>/dev/null | awk '/^ii/ && $2 ~ /^nginx($|-)/ {found=1} END {exit !found}'; then
                return 0
            fi
            ;;
        dnf|yum|zypper)
            rpm -qa 2>/dev/null | grep -Eq '^nginx($|-)'
            [[ $? -eq 0 ]] && return 0
            ;;
        pacman)
            pacman -Q nginx >/dev/null 2>&1 && return 0
            ;;
    esac

    local bin_path=""
    bin_path=$(command -v nginx 2>/dev/null || true)
    [[ -n "$bin_path" && -x "$bin_path" ]]
}

pause_screen() {
    echo ""
    read -rp "按回车继续..." _
}

get_pkg_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists yum; then
        echo "yum"
    elif command_exists zypper; then
        echo "zypper"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

get_local_version() {
    local out ver
    out=$(nginx -v 2>&1) || { echo "未安装"; return; }
    ver=$(echo "$out" | sed -n 's#^nginx version: nginx/##p' | head -n 1)
    if [[ -n "$ver" ]]; then
        echo "$ver"
    else
        echo "未安装"
    fi
}

get_service_status() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}运行中${PLAIN}"
    else
        echo -e "${RED}已停止${PLAIN}"
    fi
}

get_enable_status() {
    if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo -e "${GREEN}是${PLAIN}"
    else
        echo -e "${RED}否${PLAIN}"
    fi
}

get_current_port() {
    local ports=""

    ports=$(ss -lntp 2>/dev/null | awk '/nginx/ {split($4,a,":"); print a[length(a)]}' | grep -E '^[0-9]+$' | sort -n | uniq | paste -sd, -)

    if [[ -z "$ports" ]] && command_exists netstat; then
        ports=$(netstat -lntp 2>/dev/null | awk '/nginx/ {split($4,a,":"); print a[length(a)]}' | grep -E '^[0-9]+$' | sort -n | uniq | paste -sd, -)
    fi

    if [[ -z "$ports" ]]; then
        echo "未知"
    else
        echo "$ports"
    fi
}

get_nginx_run_user() {
    local conf_user=""
    conf_user=$(awk '
        /^[[:space:]]*#/ {next}
        /^[[:space:]]*user[[:space:]]+[^;]+;/ {
            u=$2
            gsub(";", "", u)
            print u
            exit
        }
    ' "$MAIN_CONF" 2>/dev/null)

    if [[ -n "$conf_user" ]] && id "$conf_user" >/dev/null 2>&1; then
        echo "$conf_user"
        return
    fi

    if id www-data >/dev/null 2>&1; then
        echo "www-data"
    elif id nginx >/dev/null 2>&1; then
        echo "nginx"
    else
        echo "root"
    fi
}

ensure_nginx_runtime_dirs() {
    local run_user run_group
    run_user=$(get_nginx_run_user)
    run_group=$(id -gn "$run_user" 2>/dev/null || echo "$run_user")

    local dirs=(
        "/var/lib/nginx"
        "/var/lib/nginx/body"
        "/var/lib/nginx/proxy"
        "/var/lib/nginx/fastcgi"
        "/var/lib/nginx/uwsgi"
        "/var/lib/nginx/scgi"
        "/var/cache/nginx"
        "/var/log/nginx"
    )

    local extra_dirs=()
    if [[ -d "$CONF_DIR" ]]; then
        mapfile -t extra_dirs < <(
            grep -RhsE '^[[:space:]]*(client_body_temp_path|proxy_temp_path|fastcgi_temp_path|uwsgi_temp_path|scgi_temp_path)[[:space:]]+' "$CONF_DIR" 2>/dev/null \
            | sed -E 's/^[[:space:]]*[a-z_]+[[:space:]]+([^ ;]+).*/\1/' \
            | grep -E '^/' \
            | sort -u
        )
    fi

    local d
    for d in "${extra_dirs[@]}"; do
        dirs+=("$d")
    done

    for d in "${dirs[@]}"; do
        [[ -n "$d" ]] && mkdir -p "$d"
    done

    chmod 755 /var/lib/nginx 2>/dev/null || true
    chmod 700 /var/lib/nginx/body /var/lib/nginx/proxy /var/lib/nginx/fastcgi /var/lib/nginx/uwsgi /var/lib/nginx/scgi 2>/dev/null || true
    chown -R "$run_user:$run_group" /var/lib/nginx /var/cache/nginx 2>/dev/null || true
}

start_nginx() {
    if ! nginx_installed; then
        echo -e "${RED}请先安装 Nginx。${PLAIN}"
        return
    fi
    ensure_nginx_runtime_dirs
    systemctl start "$SERVICE_NAME"
}

restart_nginx() {
    if ! nginx_installed; then
        echo -e "${RED}请先安装 Nginx。${PLAIN}"
        return
    fi
    ensure_nginx_runtime_dirs
    systemctl restart "$SERVICE_NAME"
}

install_nginx() {
    if nginx_installed; then
        echo -e "${YELLOW}检测到 Nginx 已安装。${PLAIN}"
        return
    fi

    local pm
    pm=$(get_pkg_manager)

    echo -e "${GREEN}正在安装 Nginx...${PLAIN}"
    case "$pm" in
        apt)
            apt-get update && apt-get install -y nginx
            ;;
        dnf)
            dnf install -y nginx
            ;;
        yum)
            yum install -y nginx
            ;;
        zypper)
            zypper --non-interactive install nginx
            ;;
        pacman)
            pacman -Sy --noconfirm nginx
            ;;
        *)
            echo -e "${RED}不支持的包管理器，请手动安装 Nginx。${PLAIN}"
            return
            ;;
    esac

    ensure_nginx_runtime_dirs
    systemctl enable --now "$SERVICE_NAME" >/dev/null 2>&1
    echo -e "${GREEN}安装完成。${PLAIN}"
}

update_nginx() {
    if ! nginx_installed; then
        echo -e "${RED}请先安装 Nginx。${PLAIN}"
        return
    fi

    local pm
    pm=$(get_pkg_manager)
    local do_update="n"

    case "$pm" in
        apt)
            echo -e "${GREEN}正在检查更新...${PLAIN}"
            apt-get update >/dev/null 2>&1

            local installed_ver candidate_ver
            installed_ver=$(dpkg-query -W -f='${Version}' nginx 2>/dev/null)
            candidate_ver=$(apt-cache policy nginx 2>/dev/null | awk '/Candidate:/ {print $2; exit}')

            if [[ -z "$installed_ver" ]]; then
                echo -e "${RED}无法读取已安装版本。${PLAIN}"
                return
            fi
            if [[ -z "$candidate_ver" || "$candidate_ver" == "(none)" ]]; then
                echo -e "${RED}无法获取候选版本。${PLAIN}"
                return
            fi
            if [[ "$installed_ver" == "$candidate_ver" ]]; then
                echo -e "${GREEN}当前已是最新版本: $installed_ver${PLAIN}"
                return
            fi

            echo -e "${YELLOW}发现新版本:${PLAIN} ${BLUE}$candidate_ver${PLAIN} (当前: $installed_ver)"
            read -rp "是否更新到该版本? [y/N]: " do_update
            [[ "$do_update" == "y" || "$do_update" == "Y" ]] || { echo "已取消更新。"; return; }

            apt-get install --only-upgrade -y nginx || return
            ;;
        dnf)
            echo -e "${YELLOW}将执行 dnf upgrade -y nginx${PLAIN}"
            read -rp "是否继续更新? [y/N]: " do_update
            [[ "$do_update" == "y" || "$do_update" == "Y" ]] || { echo "已取消更新。"; return; }
            dnf upgrade -y nginx || return
            ;;
        yum)
            echo -e "${YELLOW}将执行 yum update -y nginx${PLAIN}"
            read -rp "是否继续更新? [y/N]: " do_update
            [[ "$do_update" == "y" || "$do_update" == "Y" ]] || { echo "已取消更新。"; return; }
            yum update -y nginx || return
            ;;
        zypper)
            echo -e "${YELLOW}将执行 zypper --non-interactive update nginx${PLAIN}"
            read -rp "是否继续更新? [y/N]: " do_update
            [[ "$do_update" == "y" || "$do_update" == "Y" ]] || { echo "已取消更新。"; return; }
            zypper --non-interactive update nginx || return
            ;;
        pacman)
            echo -e "${YELLOW}将执行 pacman -Syu --noconfirm nginx${PLAIN}"
            read -rp "是否继续更新? [y/N]: " do_update
            [[ "$do_update" == "y" || "$do_update" == "Y" ]] || { echo "已取消更新。"; return; }
            pacman -Syu --noconfirm nginx || return
            ;;
        *)
            echo -e "${RED}不支持的包管理器，无法自动更新。${PLAIN}"
            return
            ;;
    esac

    if nginx -t >/dev/null 2>&1; then
        restart_nginx
    fi

    echo -e "${GREEN}更新完成，当前版本: $(get_local_version)${PLAIN}"
}

uninstall_nginx() {
    echo -e "${RED}警告: 此操作将卸载 Nginx。${PLAIN}"
    read -rp "确认卸载? [y/N]: " c
    [[ "$c" == "y" || "$c" == "Y" ]] || return

    systemctl stop "$SERVICE_NAME" >/dev/null 2>&1
    systemctl disable "$SERVICE_NAME" >/dev/null 2>&1

    local pm
    pm=$(get_pkg_manager)
    local removed_ok=0
    case "$pm" in
        apt)
            local apt_pkgs=()
            mapfile -t apt_pkgs < <(dpkg -l 2>/dev/null | awk '/^ii/ && $2 ~ /^nginx($|-)/ {print $2}')
            if [[ ${#apt_pkgs[@]} -gt 0 ]]; then
                apt-get purge -y "${apt_pkgs[@]}" >/dev/null 2>&1 || true
            fi
            apt-get autoremove -y >/dev/null 2>&1
            removed_ok=1
            ;;
        dnf)
            dnf remove -y 'nginx*' >/dev/null 2>&1 || true
            removed_ok=1
            ;;
        yum)
            yum remove -y 'nginx*' >/dev/null 2>&1 || true
            removed_ok=1
            ;;
        zypper)
            zypper --non-interactive remove nginx >/dev/null 2>&1 || true
            removed_ok=1
            ;;
        pacman)
            pacman -Rns --noconfirm nginx >/dev/null 2>&1 || true
            removed_ok=1
            ;;
        *)
            echo -e "${YELLOW}未识别包管理器，请手动卸载。${PLAIN}"
            return
            ;;
    esac

    read -rp "是否同时删除配置和站点目录(/etc/nginx /var/www /usr/share/nginx/html)? [y/N]: " rm_data
    if [[ "$rm_data" == "y" || "$rm_data" == "Y" ]]; then
        rm -rf /etc/nginx /var/www /usr/share/nginx/html /var/log/nginx /var/cache/nginx
    fi

    # 清理可能的残留二进制（例如手工安装或恢复包）
    local bin_path=""
    bin_path=$(command -v nginx 2>/dev/null || true)
    if [[ -n "$bin_path" && -f "$bin_path" ]]; then
        read -rp "检测到残留二进制($bin_path)，是否删除? [y/N]: " rm_bin
        if [[ "$rm_bin" == "y" || "$rm_bin" == "Y" ]]; then
            rm -f "$bin_path"
            hash -r 2>/dev/null || true
        fi
    fi

    systemctl daemon-reload >/dev/null 2>&1 || true

    if nginx_installed; then
        echo -e "${YELLOW}卸载流程执行完成，但系统仍检测到 nginx。可执行文件或包可能仍有残留。${PLAIN}"
    else
        [[ "$removed_ok" -eq 1 ]] && echo -e "${GREEN}卸载完成。${PLAIN}"
    fi
}

backup_nginx() {
    local backup_file="${BACKUP_PREFIX}_$(date +%Y%m%d_%H%M%S).tar.gz"
    local items=()
    local service_file=""
    local nginx_bin=""
    local with_bin=""
    local nginx_real_bin=""

    [[ -d /etc/nginx ]] && items+=("etc/nginx")
    [[ -d /var/www ]] && items+=("var/www")
    [[ -d /usr/share/nginx/html ]] && items+=("usr/share/nginx/html")
    [[ -d /var/lib/nginx ]] && items+=("var/lib/nginx")
    [[ -d /var/cache/nginx ]] && items+=("var/cache/nginx")

    service_file=$(systemctl show -p FragmentPath --value "$SERVICE_NAME" 2>/dev/null)
    if [[ -n "$service_file" && -f "$service_file" ]]; then
        items+=("${service_file#/}")
    fi

    nginx_bin=$(command -v nginx 2>/dev/null || true)
    if [[ -n "$nginx_bin" && -f "$nginx_bin" ]]; then
        nginx_real_bin=$(readlink -f "$nginx_bin" 2>/dev/null || echo "$nginx_bin")
        if [[ -n "$nginx_real_bin" && -f "$nginx_real_bin" ]]; then
            read -rp "是否备份 Nginx 二进制文件 ($nginx_bin)? [y/N]: " with_bin
            if [[ "$with_bin" == "y" || "$with_bin" == "Y" ]]; then
                items+=("${nginx_bin#/}")
                if [[ "$nginx_real_bin" != "$nginx_bin" ]]; then
                    items+=("${nginx_real_bin#/}")
                fi
            fi
        fi
    fi

    if [[ ${#items[@]} -eq 0 ]]; then
        echo -e "${RED}未找到可备份目录。${PLAIN}"
        return
    fi

    echo -e "${CYAN}备份文件名: $backup_file${PLAIN}"
    echo -e "${CYAN}备份清单:${PLAIN}"
    local idx=1
    local item
    for item in "${items[@]}"; do
        echo " $idx. /$item"
        ((idx++))
    done
    echo -e "${GREEN}开始打包，以下是详细过程:${PLAIN}"

    if tar -zcvf "$PWD/$backup_file" -C / "${items[@]}" --no-same-owner; then
        echo -e "${GREEN}备份成功: $backup_file${PLAIN}"
    else
        echo -e "${RED}备份失败。${PLAIN}"
    fi
}

restore_nginx() {
    local files
    mapfile -t files < <(ls -1t ${BACKUP_PREFIX}_*.tar.gz 2>/dev/null)

    if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "${RED}未找到备份文件。${PLAIN}"
        return
    fi

    echo -e "${YELLOW}请选择备份文件:${PLAIN}"
    local i=1
    for f in "${files[@]}"; do
        echo " $i. $f"
        ((i++))
    done
    echo " 0. 返回"

    read -rp "编号 (默认 1): " choice
    choice=${choice:-1}
    [[ "$choice" == "0" ]] && return

    local idx=$((choice - 1))
    local selected="${files[$idx]}"
    [[ -z "$selected" ]] && { echo -e "${RED}无效选择。${PLAIN}"; return; }

    read -rp "确认恢复 $selected ? [Y/n]: " c
    c=${c:-Y}
    [[ "$c" == "y" || "$c" == "Y" ]] || return

    systemctl stop "$SERVICE_NAME" >/dev/null 2>&1
    tar -zxf "$selected" -C / || { echo -e "${RED}恢复失败。${PLAIN}"; return; }
    systemctl daemon-reload >/dev/null 2>&1
    ensure_nginx_runtime_dirs

    if nginx_installed && nginx -t >/dev/null 2>&1; then
        systemctl enable "$SERVICE_NAME" >/dev/null 2>&1
        start_nginx
        echo -e "${GREEN}恢复完成并已启动 Nginx。${PLAIN}"
    elif nginx_installed; then
        echo -e "${YELLOW}恢复完成，但配置校验未通过，请手动检查。${PLAIN}"
    else
        if tar -tzf "$selected" 2>/dev/null | grep -Eq '(^|/)(usr/)?sbin/nginx$'; then
            echo -e "${YELLOW}恢复包中包含 nginx 条目，但当前命令不可执行。可能是符号链接目标缺失或权限异常，请手动检查 /usr/sbin/nginx。${PLAIN}"
        else
            echo -e "${YELLOW}恢复完成，但未检测到 nginx 可执行文件（你可能在备份时未包含二进制）。${PLAIN}"
        fi
    fi
}

test_and_reload() {
    if ! nginx_installed; then
        echo -e "${RED}请先安装 Nginx。${PLAIN}"
        return
    fi

    ensure_nginx_runtime_dirs
    echo -e "${GREEN}正在检测配置...${PLAIN}"
    if nginx -t; then
        systemctl reload "$SERVICE_NAME"
        echo -e "${GREEN}配置有效，已重载。${PLAIN}"
    else
        echo -e "${RED}配置存在错误，请修复后重试。${PLAIN}"
    fi
}

autostart_settings() {
    while true; do
        clear
        echo -e "      ${GREEN}自启动设置${PLAIN}"
        echo "--------------------------------"
        echo " 1. 开启开机自启"
        echo " 2. 关闭开机自启"
        echo -e " 当前状态: $(get_enable_status)"
        echo " 0. 返回"
        echo "--------------------------------"

        read -rp "选择: " opt
        case "$opt" in
            1)
                systemctl enable "$SERVICE_NAME"
                echo "已开启"
                sleep 1
                ;;
            2)
                systemctl disable "$SERVICE_NAME"
                echo "已关闭"
                sleep 1
                ;;
            0)
                break
                ;;
            *)
                ;;
        esac
    done
}

settings_menu() {
    while true; do
        clear
        echo -e "      ${GREEN}Nginx 高级设置${PLAIN}"
        echo "--------------------------------"
        echo " 1. 安装 Nginx"
        echo " 2. 更新 Nginx"
        echo " 3. 自启动设置"
        echo " 4. 备份"
        echo " 5. 恢复备份"
        echo " 6. 卸载 Nginx"
        echo " 0. 返回"
        echo "--------------------------------"

        read -rp "请输入选择: " opt
        case "$opt" in
            1) install_nginx; pause_screen ;;
            2) update_nginx; pause_screen ;;
            3) autostart_settings ;;
            4) backup_nginx; pause_screen ;;
            5) restore_nginx; pause_screen ;;
            6) uninstall_nginx; pause_screen ;;
            0) break ;;
            *) ;;
        esac
    done
}

main_menu() {
    while true; do
        clear
        local ver status port
        ver=$(get_local_version)

        echo -e "       Nginx 管理面板 ${BLUE}v1.0${PLAIN}"
        echo "--------------------------------"
        if [[ "$ver" == "未安装" ]]; then
            echo -e " 状态: ${RED}未安装${PLAIN}"
        else
            status=$(get_service_status)
            port=$(get_current_port)
            echo -e " 运行状态: $status"
            echo -e " 当前版本: ${BLUE}$ver${PLAIN}"
            echo -e " 监听端口: ${YELLOW}$port${PLAIN}"
        fi
        echo "--------------------------------"
        echo " 1. 测试配置并重载"
        echo " 2. 启动 Nginx"
        echo " 3. 停止 Nginx"
        echo " 4. 重启 Nginx"
        echo " 5. 高级设置"
        echo " 0. 退出"
        echo "--------------------------------"

        read -rp "请输入选择: " c
        case "$c" in
            1) test_and_reload; pause_screen ;;
            2) start_nginx ;;
            3) systemctl stop "$SERVICE_NAME" ;;
            4) restart_nginx ;;
            5) settings_menu ;;
            0) exit 0 ;;
            *) ;;
        esac
    done
}

main_menu
