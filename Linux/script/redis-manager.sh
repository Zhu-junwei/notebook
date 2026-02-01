#!/bin/bash
set -u

# ========= 基本信息 =========
SCRIPT_NAME="Redis Manager"
SCRIPT_VER="1.0"
TARGET_OS="Debian / Ubuntu"

REDIS_CONF="/etc/redis/redis.conf"
REDIS_DEFAULT="/usr/share/redis/redis.conf"
SERVICE="redis-server"

# ========= 颜色 =========
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[36m"
GRAY="\033[90m"
RESET="\033[0m"
BOLD="\033[1m"

# ========= 日志 =========
info()  { echo -e "${GREEN}[INFO]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error() { echo -e "${RED}[ERROR]${RESET} $*"; }

require_root() {
    [[ $EUID -eq 0 ]] || { error "请使用 root 运行"; exit 1; }
}

# ========= Redis 判断 =========
redis_installed() {
    systemctl list-unit-files | grep -q "^${SERVICE}.service"
}

redis_running() {
    systemctl is-active --quiet "$SERVICE"
}

redis_version() {
    redis-server --version 2>/dev/null \
        | sed -n 's/.*v=\([0-9.]*\).*/\1/p'
}

redis_status_line() {
    if ! redis_installed; then
        echo -e "Redis: ${RED}未安装${RESET}"
        return
    fi

    local status version
    version="$(redis_version)"

    if redis_running; then
        status="${GREEN}运行中${RESET}"
    else
        status="${YELLOW}已停止${RESET}"
    fi

    echo -e "Redis: $status | ${BLUE}${version:-unknown}${RESET}"
}

# ========= Banner =========
banner() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "======================================"
    echo "        $SCRIPT_NAME"
    echo "        v$SCRIPT_VER  ($TARGET_OS)"
    echo "======================================"
    echo -e "${RESET}"
}

# ========= 仓库 =========
install_repo() {
    [[ -f /etc/apt/sources.list.d/redis.list ]] && return
    apt-get update
    apt-get install -y curl gpg lsb-release ca-certificates
    curl -fsSL https://packages.redis.io/gpg \
        | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/redis.list
    apt-get update
}

# ========= 配置 =========
set_password() {
    while true; do
        read -rsp "Redis 密码（回车跳过）: " p1; echo
        [[ -z "$p1" ]] && return 1
        read -rsp "再次输入密码: " p2; echo
        [[ "$p1" != "$p2" ]] && { warn "两次密码不一致"; continue; }
        sed -i "s|^[# ]*requirepass .*|requirepass $p1|" "$REDIS_CONF"
        return 0
    done
}

set_port() {
    while true; do
        read -rp "Redis 端口（默认 6379，回车跳过）: " port
        [[ -z "$port" ]] && return
        [[ "$port" =~ ^[0-9]+$ && $port -ge 1 && $port -le 65535 ]] || continue
        sed -i "s|^port .*|port $port|" "$REDIS_CONF"
        return
    done
}

enable_public() {
    sed -i 's/^bind .*/bind 0.0.0.0 ::1/' "$REDIS_CONF"
    sed -i 's/^protected-mode .*/protected-mode no/' "$REDIS_CONF"
}

disable_public() {
    sed -i 's/^bind .*/bind 127.0.0.1/' "$REDIS_CONF"
    sed -i 's/^protected-mode .*/protected-mode yes/' "$REDIS_CONF"
}

# ========= 安装 =========
install_redis() {
    redis_installed && { info "Redis 已安装"; return; }

    install_repo
    apt-get install -y redis-server

    echo
    echo -e "${BOLD}初始化配置${RESET}"

    set_password && info "密码已设置" || warn "未设置密码"
    set_port

    read -rp "是否开启公网访问？[y/N]: " c
    [[ $c =~ ^[Yy]$ ]] && enable_public

    systemctl enable "$SERVICE"
    systemctl restart "$SERVICE"
}

reset_config() {
    read -rp "确认恢复默认配置？[y/N]: " c
    [[ $c =~ ^[Yy]$ ]] || return
    cp "$REDIS_DEFAULT" "$REDIS_CONF"
    systemctl restart "$SERVICE"
}

uninstall_redis() {
    echo
    warn "此操作将卸载 Redis 服务和程序包"
    read -rp "确认继续卸载 Redis？[y/N]: " c
    [[ $c =~ ^[Yy]$ ]] || return

    systemctl stop "$SERVICE" 2>/dev/null || true

    apt-get purge -y redis-server redis
    rm -rf /etc/redis
    apt-get autoremove -y

    echo
    if [[ -d /var/lib/redis ]]; then
        warn "检测到 Redis 数据目录：/var/lib/redis"
        warn "其中可能包含 RDB / AOF 数据文件"
        read -rp "是否同时删除 Redis 数据？⚠ 此操作不可恢复 [y/N]: " d
        if [[ $d =~ ^[Yy]$ ]]; then
            rm -rf /var/lib/redis
            rm -rf /var/log/redis
            info "Redis 数据已删除"
        else
            info "已保留 Redis 数据目录"
        fi
    fi

    info "Redis 卸载完成"
}


# ========= 设置菜单 =========
settings_menu() {
    while true; do
        banner
        redis_status_line
        echo
        echo -e "${BLUE} 1${RESET} 安装 Redis"
        echo -e "${BLUE} 2${RESET} 修改密码"
        echo -e "${BLUE} 3${RESET} 修改端口"
        echo -e "${BLUE} 4${RESET} 开启公网访问"
        echo -e "${BLUE} 5${RESET} 关闭公网访问"
        echo -e "${BLUE} 6${RESET} 重置配置"
        echo -e "${RED} 7${RESET} 卸载 Redis"
        echo -e "${GRAY} 0${RESET} 返回"
        echo
        read -rp "> " c
        [[ -z "$c" ]] && continue
        case "$c" in
            1) install_redis ;;
            2) set_password && systemctl restart "$SERVICE" ;;
            3) set_port && systemctl restart "$SERVICE" ;;
            4) enable_public && systemctl restart "$SERVICE" ;;
            5) disable_public && systemctl restart "$SERVICE" ;;
            6) reset_config ;;
            7) uninstall_redis ;;
            0) break ;;
        esac
    done
}

# ========= 主菜单 =========
main_menu() {
    while true; do
        banner
        redis_status_line
        echo
        echo -e "${GREEN} 1${RESET} 启动 Redis"
        echo -e "${YELLOW} 2${RESET} 停止 Redis"
        echo -e "${BLUE} 3${RESET} 重启 Redis"
        echo -e "${GRAY} 4${RESET} 设置"
        echo -e "${GRAY} 0${RESET} 退出"
        echo
        read -rp "> " c
        [[ -z "$c" ]] && continue
        case "$c" in
            1) systemctl start "$SERVICE" ;;
            2) systemctl stop "$SERVICE" ;;
            3) systemctl restart "$SERVICE" ;;
            4) settings_menu ;;
            0) exit 0 ;;
        esac
    done
}

require_root
main_menu
