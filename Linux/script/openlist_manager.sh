#!/bin/bash

# =========================================================
# OpenList 管理面板
# Optimized by: zjw
# Target Repo: OpenListTeam/OpenList
# =========================================================

# --- 配置区域 ---
REPO="OpenListTeam/OpenList"
BIN_NAME="openlist"
INSTALL_DIR="/usr/local/bin"
DATA_DIR="/opt/openlist"
SERVICE_NAME="openlist"
CONFIG_FILE="$DATA_DIR/config.json"

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
PLAIN='\033[0m'

# 全局变量：用于存储用户输入的密码结果
Global_Pass_Result=""

# 检查 root 权限
[[ $EUID -ne 0 ]] && echo -e "${RED}错误: 必须使用 root 用户运行此脚本！${PLAIN}" && exit 1

# --- 辅助函数 ---

get_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64) echo "amd64" ;;
        aarch64) echo "arm64" ;;
        armv7l) echo "arm-7" ;; 
        *) echo "unknown" ;;
    esac
}

format_size() {
    local size=$1
    if [ "$size" -ge 1048576 ]; then
        awk -v s="$size" 'BEGIN {printf "%.2f MB", s/1048576}'
    elif [ "$size" -ge 1024 ]; then
        awk -v s="$size" 'BEGIN {printf "%.2f KB", s/1024}'
    else
        echo "${size} B"
    fi
}

format_date() {
    local iso_date=$1
    date -d "$iso_date" "+%Y-%m-%d" 2>/dev/null || echo "$iso_date"
}

get_local_version() {
    if [ -f "$INSTALL_DIR/$BIN_NAME" ]; then
        local ver=$($INSTALL_DIR/$BIN_NAME version 2>&1 | grep "^Version:" | awk '{print $2}')
        if [ -z "$ver" ]; then echo "未知"; else echo "$ver"; fi
    else
        echo "未安装"
    fi
}

get_service_status() {
    if systemctl is-active --quiet $SERVICE_NAME; then echo -e "${GREEN}运行中${PLAIN}"; else echo -e "${RED}已停止${PLAIN}"; fi
}

get_enable_status() {
    if systemctl is-enabled --quiet $SERVICE_NAME 2>/dev/null; then echo -e "${GREEN}是${PLAIN}"; else echo -e "${RED}否${PLAIN}"; fi
}

# 获取当前配置的端口
get_current_port() {
    if [ -f "$CONFIG_FILE" ]; then
        local port=$(jq -r '.scheme.http_port' "$CONFIG_FILE" 2>/dev/null)
        if [[ "$port" =~ ^[0-9]+$ ]]; then
            echo "$port"
        else
            echo "5244(默认)"
        fi
    else
        echo "未知"
    fi
}

# --- 密码输入核心函数 (修复版) ---
# 不使用 echo 返回值，而是直接修改全局变量 Global_Pass_Result
read_secure_password() {
    local prompt_text=$1
    local p1=""
    local p2=""
    
    # 重置全局变量
    Global_Pass_Result=""

    echo -e "${YELLOW}$prompt_text${PLAIN}"
    
    while true; do
        # 1. 输入第一次
        read -s -p "请输入密码 (直接回车默认为 admin): " p1
        echo "" # 强制换行

        # 2. 判断是否为空 (使用默认)
        if [ -z "$p1" ]; then
            Global_Pass_Result="admin"
            echo -e "${CYAN}>> 已选择使用默认密码: admin${PLAIN}"
            break
        fi

        # 3. 输入第二次
        read -s -p "请再次输入以确认: " p2
        echo "" # 强制换行

        # 4. 比对
        if [ "$p1" == "$p2" ]; then
            Global_Pass_Result="$p1"
            break
        else
            echo -e "${RED}两次输入的密码不一致，请重新输入！${PLAIN}"
            echo -e "---------------------------------"
        fi
    done
}

# 内部函数：通用下载与二进制替换逻辑
_do_core_replace() {
    local url=$1
    local remote_filename=$(basename "$url")
    local max_retries=3
    local count=0
    local success=0

    echo -e "准备下载: ${CYAN}$remote_filename${PLAIN}"

    while [ $count -lt $max_retries ]; do
        ((count++))
        if [ $count -gt 1 ]; then
            echo -e "${YELLOW}下载失败，正在进行第 $count 次重试...${PLAIN}"
            sleep 2
        fi
        
        wget -q --show-progress -T 15 -O "/tmp/$remote_filename" "$url"
        
        if [ $? -eq 0 ]; then
            success=1
            break
        fi
    done

    if [ $success -eq 0 ]; then
        echo -e "${RED}错误: 下载失败，请检查网络连接或 GitHub 访问情况。${PLAIN}"
        return 1
    fi

    echo "正在安装..."
    systemctl stop $SERVICE_NAME >/dev/null 2>&1
    
    # 解压
    tar -zxf "/tmp/$remote_filename" -C /tmp
    
    # 查找二进制文件
    local extracted_bin=$(find /tmp -maxdepth 2 -type f -name "$BIN_NAME" | head -n 1)
    if [ -z "$extracted_bin" ]; then extracted_bin=$(find /tmp -maxdepth 2 -type f -name "alist" | head -n 1); fi
    
    if [ -f "$extracted_bin" ]; then
        mv -f "$extracted_bin" "$INSTALL_DIR/$BIN_NAME"
        chmod +x "$INSTALL_DIR/$BIN_NAME"
        rm -f "/tmp/$remote_filename"
        rm -f "$extracted_bin" 2>/dev/null
        return 0
    else
        echo -e "${RED}安装失败：未能从压缩包中找到二进制文件。${PLAIN}"
        rm -f "/tmp/$remote_filename"
        return 1
    fi
}

# --- 核心功能 ---

# 1. 安装功能
install_openlist() {
    local keep_data=false
    local custom_port=5244
    local final_password="admin" # 本地变量

    # 已安装检查
    if [ -f "$INSTALL_DIR/$BIN_NAME" ]; then
        echo -e "${YELLOW}检测到 OpenList 已安装。${PLAIN}"
        echo " 1) 重新安装 (清空数据重新开始)"
        echo " 2) 保留数据安装 (仅替换程序)"
        read -p "请选择 [1-2] (默认取消): " inst_opt
        case $inst_opt in
            1) 
                echo -e "${RED}正在清理旧数据...${PLAIN}"
                systemctl stop $SERVICE_NAME >/dev/null 2>&1
                rm -rf "$DATA_DIR"
                rm -f "$INSTALL_DIR/$BIN_NAME"
                keep_data=false
                ;;
            2) 
                keep_data=true
                ;;
            *) 
                echo "操作已取消。"
                return
                ;;
        esac
    fi

    # 检查依赖
    for dep in curl wget tar jq grep awk; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${YELLOW}正在安装依赖: $dep${PLAIN}"
            if [ -x "$(command -v apt-get)" ]; then apt-get update >/dev/null && apt-get install -y $dep >/dev/null
            elif [ -x "$(command -v yum)" ]; then yum install -y $dep >/dev/null; fi
        fi
    done

    local arch=$(get_arch)
    if [ "$arch" == "unknown" ]; then echo -e "${RED}不支持的架构。${PLAIN}"; return; fi

    # 获取版本列表
    echo -e "${GREEN}正在获取版本列表...${PLAIN}"
    local releases_json=$(curl -s "https://api.github.com/repos/$REPO/releases?per_page=20")
    local filtered_json=$(echo "$releases_json" | jq -c '[.[] | select(.prerelease == false)][0:5]')
    
    if [ -z "$filtered_json" ] || [ "$filtered_json" == "null" ]; then
        echo -e "${RED}获取版本列表失败或无正式版本。${PLAIN}"
        return
    fi
    
    local tags=($(echo "$filtered_json" | jq -r '.[].tag_name'))
    if [ ${#tags[@]} -eq 0 ]; then echo -e "${RED}未找到版本记录。${PLAIN}"; return; fi

    # 选择版本
    echo -e "${YELLOW}请选择要安装的版本:${PLAIN}"
    for i in "${!tags[@]}"; do echo " $((i+1)). ${tags[$i]}"; done
    read -p "选择编号 (默认 1): " v_choice
    v_choice=${v_choice:-1}
    local index=$((v_choice-1))
    local version=${tags[$index]}

    echo -e "${GREEN}正在检索 ${version} 的安装包...${PLAIN}"
    
    local sorted_assets=$(echo "$filtered_json" | jq -c "
        [
            .[$index].assets[] 
            | select(.name | contains(\"linux\")) 
            | select(.name | contains(\"$arch\"))
        ] 
        | sort_by( (.name | sub(\"-lite\";\"\")), (.name | contains(\"lite\")) )
    ")
    
    if [ "$sorted_assets" == "[]" ] || [ -z "$sorted_assets" ]; then
        echo -e "${RED}未找到匹配 $arch 的包。${PLAIN}"; return; fi
    
    local asset_names=($(echo "$sorted_assets" | jq -r '.[].name'))
    local asset_sizes=($(echo "$sorted_assets" | jq -r '.[].size'))
    local asset_dates=($(echo "$sorted_assets" | jq -r '.[].updated_at'))
    local asset_urls=($(echo "$sorted_assets" | jq -r '.[].browser_download_url'))

    echo -e "${YELLOW}请选择具体文件:${PLAIN}"
    printf "%-4s %-40s %-12s %-15s\n" "No." "文件名" "大小" "更新日期"
    echo "--------------------------------------------------------------------------"
    for i in "${!asset_names[@]}"; do
        local f_size=$(format_size ${asset_sizes[$i]})
        local f_date=$(format_date ${asset_dates[$i]})
        printf "%-4s %-40s %-12s %-15s\n" "$((i+1))." "${asset_names[$i]}" "$f_size" "$f_date"
    done
    
    read -p "选择编号 (默认 1): " a_choice
    a_choice=${a_choice:-1}
    local a_index=$((a_choice-1))
    local download_url=${asset_urls[$a_index]}
    
    if [ -z "$download_url" ] || [ "$download_url" == "null" ]; then echo -e "${RED}无效的选择。${PLAIN}"; return; fi

    mkdir -p "$DATA_DIR"
    
    # === 下载与安装 ===
    if _do_core_replace "$download_url"; then
        
        # === 用户输入阶段 (在二进制文件安装后，初始化前) ===
        if [ "$keep_data" = false ]; then
            echo -e "------------------------------------------------"
            # 1. 端口设置
            read -p "请设置运行端口 (默认 5244): " input_port
            if [[ "$input_port" =~ ^[0-9]+$ ]]; then
                custom_port=$input_port
            else
                custom_port=5244
            fi
            
            # 2. 密码设置 (调用全局变量函数)
            read_secure_password "正在设置管理员密码:"
            # 将全局结果存入本地变量，防止后续污染
            final_password="$Global_Pass_Result"
        fi

        # 配置 Systemd
        if [ ! -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
            cat > /etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=OpenList Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$DATA_DIR
ExecStart=$INSTALL_DIR/$BIN_NAME server --data "$DATA_DIR"
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
        fi
        systemctl daemon-reload
        
        # === 初始化配置流程 ===
        echo -e "${YELLOW}正在初始化系统配置...${PLAIN}"
        
        # 1. 启动服务以生成 config.json
        systemctl start $SERVICE_NAME
        sleep 5 

        # 2. 停止服务以修改配置
        systemctl stop $SERVICE_NAME

        if [ "$keep_data" = false ]; then
            # 修改端口
            if [ -f "$CONFIG_FILE" ]; then
                jq --argjson port $custom_port '.scheme.http_port = $port' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
                echo -e "端口配置已应用: ${GREEN}$custom_port${PLAIN}"
            fi
            
            # 应用密码
            "$INSTALL_DIR/$BIN_NAME" admin set "$final_password" --data "$DATA_DIR" >/dev/null 2>&1
        fi
        
        # 3. 最终启动
        systemctl start $SERVICE_NAME
        
        echo -e "${GREEN}安装并启动完成！${PLAIN}"

        if [ "$keep_data" = false ]; then
            echo -e "------------------------------------------------"
            echo -e "访问地址: http://127.0.0.1:$custom_port"
            echo -e "访问地址: http://$(curl -s ifconfig.me):$custom_port"
            echo -e "用户名: admin"
            
            # 这里的判断逻辑修复：如果用户未输入（默认为admin），显示admin；否则隐藏。
            if [ "$final_password" == "admin" ]; then
                echo -e "密码: ${YELLOW}admin${PLAIN} (默认)"
            else
                echo -e "密码: ${GREEN}(已设置，隐式保护)${PLAIN}"
            fi
            echo -e "------------------------------------------------"
        fi
    fi
}

# 2. 更新功能
update_openlist() {
    local local_ver=$(get_local_version)
    if [ "$local_ver" == "未安装" ]; then echo -e "${RED}请先安装后再使用更新功能。${PLAIN}"; return; fi

    echo "正在检查最新版本..."
    local releases_json=$(curl -s "https://api.github.com/repos/$REPO/releases?per_page=10")
    local latest_stable_obj=$(echo "$releases_json" | jq -c '[.[] | select(.prerelease == false)][0]')
    
    if [ -z "$latest_stable_obj" ] || [ "$latest_stable_obj" == "null" ]; then echo -e "${RED}无法获取最新版本信息。${PLAIN}"; return; fi

    local remote_ver=$(echo "$latest_stable_obj" | jq -r '.tag_name')
    if [ "$local_ver" == "$remote_ver" ]; then echo -e "${GREEN}当前已是最新版 ($local_ver)。${PLAIN}"; return; fi

    echo -e "发现新版本: ${GREEN}$remote_ver${PLAIN} (当前: $local_ver)"
    read -p "是否更新到此版本？[y/N]: " confirm_update
    if [[ "$confirm_update" != "y" && "$confirm_update" != "Y" ]]; then echo "已取消更新。"; return; fi
    
    local arch=$(get_arch)
    local sorted_assets=$(echo "$latest_stable_obj" | jq -c "
        [
            .assets[] 
            | select(.name | contains(\"linux\")) 
            | select(.name | contains(\"$arch\"))
        ] 
        | sort_by( (.name | sub(\"-lite\";\"\")), (.name | contains(\"lite\")) )
    ")
    
    if [ "$sorted_assets" == "[]" ] || [ -z "$sorted_assets" ]; then echo -e "${RED}未找到匹配包。${PLAIN}"; return; fi

    local asset_names=($(echo "$sorted_assets" | jq -r '.[].name'))
    local asset_urls=($(echo "$sorted_assets" | jq -r '.[].browser_download_url'))

    local download_url=${asset_urls[0]}
    
    if _do_core_replace "$download_url"; then
        systemctl start $SERVICE_NAME
        echo -e "${GREEN}版本更新成功！${PLAIN}"
    fi
}

# 3. 卸载功能
uninstall_openlist() {
    echo -e "${RED}警告：此操作将删除程序，数据可选择保留。${PLAIN}"
    read -p "确认卸载? [y/N]: " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        systemctl stop $SERVICE_NAME >/dev/null 2>&1
        systemctl disable $SERVICE_NAME >/dev/null 2>&1
        rm -f /etc/systemd/system/$SERVICE_NAME.service
        systemctl daemon-reload
        rm -f "$INSTALL_DIR/$BIN_NAME"
        read -p "是否同时删除数据目录 ($DATA_DIR)? [y/N]: " del_data
        [[ "$del_data" == "y" || "$del_data" == "Y" ]] && rm -rf "$DATA_DIR"
        echo -e "${GREEN}卸载完成。${PLAIN}"
    fi
}

# 4. 备份功能
backup_openlist() {
    if [ ! -f "$INSTALL_DIR/$BIN_NAME" ] && [ ! -d "$DATA_DIR" ]; then echo -e "${RED}未安装，无法备份。${PLAIN}"; return; fi

    local ver="unknown"
    if [ -f "$INSTALL_DIR/$BIN_NAME" ]; then
        ver=$($INSTALL_DIR/$BIN_NAME version 2>&1 | grep "^Version:" | awk '{print $2}')
        [ -z "$ver" ] && ver="unknown"
    fi

    local backup_file="openlist_backup_${ver}_$(date +%Y%m%d_%H%M%S).tar.gz"
    local svc_file="/etc/systemd/system/$SERVICE_NAME.service"
    local exclude_args="--exclude=$DATA_DIR/log"
    
    echo "正在开始备份..."
    tar -zcvf "$PWD/$backup_file" -C / \
        --exclude="opt/openlist/log" \
        "${INSTALL_DIR#/}/$BIN_NAME" \
        "${DATA_DIR#/}" \
        "${svc_file#/}" \
        --no-same-owner

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}备份成功: $backup_file${PLAIN}"
    else
        echo -e "${RED}备份失败！${PLAIN}"
    fi
}

# 5. 还原功能
restore_openlist() {
    local files=($(ls -1t openlist_backup_*.tar.gz 2>/dev/null))
    if [ ${#files[@]} -eq 0 ]; then echo -e "${RED}未找到备份文件。${PLAIN}"; return; fi
    echo -e "${YELLOW}请选择备份文件:${PLAIN}"
    local i=1
    for file in "${files[@]}"; do echo " $i. $file"; ((i++)); done
    echo " 0. 返回"
    read -p "编号 (默认 1): " choice
    choice=${choice:-1}
    [[ "$choice" == "0" ]] && return
    local index=$((choice-1))
    local selected_file="${files[$index]}"
    [[ -z "$selected_file" ]] && { echo -e "${RED}无效选择${PLAIN}"; return; }

    read -p "确定还原 $selected_file 吗? [Y/n]: " confirm
    confirm=${confirm:-y}
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        systemctl stop $SERVICE_NAME >/dev/null 2>&1
        rm -f "$INSTALL_DIR/$BIN_NAME"
        rm -rf "$DATA_DIR"
        tar -zxvf "$selected_file" -C /
        chmod +x "$INSTALL_DIR/$BIN_NAME"
        systemctl daemon-reload
        systemctl enable $SERVICE_NAME >/dev/null 2>&1
        systemctl start $SERVICE_NAME
        echo -e "${GREEN}还原成功！${PLAIN}"
    fi
}

# 6. 修改端口功能
modify_port_setting() {
    if [ ! -f "$CONFIG_FILE" ]; then echo -e "${RED}配置文件不存在，请先安装。${PLAIN}"; return; fi
    
    local current_port=$(jq -r '.scheme.http_port' "$CONFIG_FILE")
    echo -e "当前端口: ${GREEN}$current_port${PLAIN}"
    read -p "请输入新端口 (1-65535): " new_port
    
    if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1 ] && [ "$new_port" -le 65535 ]; then
        if [ "$new_port" == "$current_port" ]; then
            echo -e "${YELLOW}端口未改变。${PLAIN}"
            return
        fi
        
        echo "正在停止服务..."
        systemctl stop $SERVICE_NAME
        
        jq --argjson port $new_port '.scheme.http_port = $port' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        echo "正在重启服务..."
        systemctl start $SERVICE_NAME
        sleep 2
        
        if systemctl is-active --quiet $SERVICE_NAME; then
            echo -e "${GREEN}端口已修改为 $new_port 并重启成功！${PLAIN}"
        else
            echo -e "${RED}重启失败，请检查日志。${PLAIN}"
        fi
    else
        echo -e "${RED}无效的端口号。${PLAIN}"
    fi
}

reset_admin_password() {
	if [ -f "$INSTALL_DIR/$BIN_NAME" ]; then
		# 调用统一的密码输入函数
		read_secure_password "正在重置密码..."
		local reset_pass="$Global_Pass_Result"
		
		"$INSTALL_DIR/$BIN_NAME" admin set "$reset_pass" --data "$DATA_DIR" >/dev/null 2>&1
		echo -e "\n${GREEN}密码修改操作已完成。${PLAIN}"
		
		# 仅当是默认密码时才提示 admin，否则不显示具体密码
		if [ "$reset_pass" == "admin" ]; then
			echo -e "当前密码: ${YELLOW}admin${PLAIN}"
		else
			echo -e "当前密码: ${GREEN}****** (已隐藏)${PLAIN}"
		fi
		
		# 暂停等待用户确认
		echo ""
		read -p "按回车键返回菜单..."
	else
		echo "未安装"; sleep 1
	fi
}

# --- 菜单界面 ---
autostart_settings() {
    while true; do
        clear
        echo -e "      ${GREEN}自启动管理${PLAIN}"
        echo "--------------------------------"
        echo " 1. 开启开机自启"
        echo " 2. 关闭开机自启"
        echo -e " 当前状态: $(get_enable_status)"
        echo " 0. 返回"
        echo "--------------------------------"
        read -p "选择: " opt
        case $opt in
            1) systemctl enable $SERVICE_NAME; echo "已开启"; sleep 1 ;;
            2) systemctl disable $SERVICE_NAME; echo "已关闭"; sleep 1 ;;
            0) break ;;
        esac
    done
}

settings_menu() {
    while true; do
        clear
        echo -e "      ${GREEN}OpenList 高级设置${PLAIN}"
        echo "--------------------------------"
        echo " 1. 安装 OpenList"
        echo " 2. 检查更新"
        echo " 3. 修改运行端口"
        echo " 4. 自启动设置"
        echo " 5. 备份 (程序+数据+服务)"
        echo " 6. 还原"
        echo " 7. 重置 admin 密码"
        echo " 8. 卸载 OpenList"
        echo " 0. 返回"
        echo "--------------------------------"
        read -p "请输入选择: " opt
        case $opt in
            1) install_openlist; read -p "按回车继续..." ;;
            2) update_openlist; read -p "按回车继续..." ;;
            3) modify_port_setting; read -p "按回车继续..." ;;
            4) autostart_settings ;;
            5) backup_openlist; read -p "按回车继续..." ;;
            6) restore_openlist; read -p "按回车继续..." ;;
            7) reset_admin_password ;;
            8) uninstall_openlist; read -p "按回车继续..." ;;
            0) break ;;
        esac
    done
}

main_menu() {
    while true; do
        clear
        local l_ver=$(get_local_version)
        local status=$(get_service_status)
        local c_port=$(get_current_port)
        
        echo -e "  【 OpenList 管理面板 1.0 】"
        echo -e "--------------------------------"
        if [ "$l_ver" == "未安装" ]; then
            echo -e " 状态: ${RED}未安装${PLAIN}"
        else
            echo -e " 运行状态: $status"
            echo -e " 当前版本: ${BLUE}$l_ver${PLAIN}"
            echo -e " 监听端口: ${YELLOW}$c_port${PLAIN}"
        fi
        echo -e "--------------------------------"
        echo -e " 1. 启动 OpenList"
        echo -e " 2. 停止 OpenList"
        echo -e " 3. 重启 OpenList"
        echo -e " 4. 高级设置"
        echo -e " 0. 退出"
        echo -e "--------------------------------"
        
        read -p "请输入选择: " choice
        case $choice in
            1) systemctl start $SERVICE_NAME; ;;
            2) systemctl stop $SERVICE_NAME; ;;
            3) systemctl restart $SERVICE_NAME; ;;
            4) settings_menu ;;
            0) exit 0 ;;
            *) ;;
        esac
    done
}

main_menu