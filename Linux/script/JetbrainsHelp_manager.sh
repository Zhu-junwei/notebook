#!/usr/bin/env bash

# Application settings
APP_NAME="JetbrainsHelp"
JAR_NAME="Jetbrains-Help.jar"
JAR_DOWNLOAD_URL="https://openlist.900198.xyz/d/%E5%8F%96%E6%96%87%E4%BB%B6/wd1/Jetbrains-Help/Jetbrains-Help.jar?sign=Q7O7xVcjLUt7hbOF6sfrllyMio-l80upkkX0z5zilAE=:0"
APP_HOME="/opt/${APP_NAME}"
JAR_PATH="${APP_HOME}/${JAR_NAME}"
LOG_FILE="${APP_HOME}/${APP_NAME}.log"
CONFIG_FILE="${APP_HOME}/${APP_NAME}.conf"
DEFAULT_APP_PORT=10768
APP_PORT=${DEFAULT_APP_PORT} # Default port, will be read from config or set during installation

# Java 设置
JAVA_CMD="java"
REQUIRED_JAVA_VERSION=17

# Colors for highlighting stages
PLAIN="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"

# 日志函数：信息/警告/成功/错误/提示
log_info() {
    echo "[info] $*"
}

log_warn() {
    echo -e "${YELLOW}[warn] $*${PLAIN}" >&2
}

log_nice() {
    echo -e "${GREEN}[nice] $*${PLAIN}"
}

log_error() {
    echo -e "${RED}[error] $*${PLAIN}" >&2
}

log_tip() {
    echo -e "${CYAN}[tip] $*${PLAIN}"
}

# --- 工具函数 ---

# 检查是否以 root 用户运行
check_root() {
    if [ "$EUID" -eq 0 ]; then
        return 0  # Running as root
    else
        return 1  # Not running as root
    fi
}

# 获取正在运行应用的 PID
get_pid() {
    pgrep -f "${JAR_NAME}"
}

# 加载配置
load_config() {
    if [ -f "${CONFIG_FILE}" ]; then
        source "${CONFIG_FILE}"
        log_info "已从 ${CONFIG_FILE} 加载配置。"
    else
        log_info "配置文件 ${CONFIG_FILE} 未找到，使用默认设置。" >&2
    fi
}

# 保存配置
save_config() {
    echo "APP_PORT=${APP_PORT}" > "${CONFIG_FILE}"
    echo "APP_HOME=${APP_HOME}" >> "${CONFIG_FILE}" # Save APP_HOME for systemd
    echo "JAVA_CMD=${JAVA_CMD}" >> "${CONFIG_FILE}" # Save JAVA_CMD for systemd
    log_info "配置已保存到 ${CONFIG_FILE}。"
}

# 检查 Java 版本
check_java_version() {
    log_info "正在检查 Java 版本..."
    local java_executable=""
    local current_java_version=""

    if command -v java >/dev/null 2>&1; then
        java_executable="java"
        local java_version_output=$("${java_executable}" -version 2>&1)
        # Extract major version number (handles both "version "17" and "version "17.0.18")
        current_java_version=$(echo "$java_version_output" | grep -oP 'version "\K[0-9]+')

        if [ -n "$current_java_version" ]; then
            if (( current_java_version >= REQUIRED_JAVA_VERSION )); then
                JAVA_CMD="${java_executable}"
                log_info "在 '${JAVA_CMD}' 找到系统 Java $current_java_version，满足要求 (>= $REQUIRED_JAVA_VERSION)。"
                return 0 # Success
            else
                log_warn "找到系统 Java $current_java_version，但需要 $REQUIRED_JAVA_VERSION 或更高版本。"
            fi
        else
            log_warn "无法确定已安装的系统 Java 版本。"
        fi
    else
        log_warn "系统 Java 未安装或未在 PATH 中找到。"
    fi

    log_error "未找到合适的 Java ${REQUIRED_JAVA_VERSION} 或更高版本。"
    return 1 # Java not found or not suitable
}

# 启动应用
start_app() {
    load_config # Load latest port setting
    if get_pid > /dev/null; then
        log_info "${APP_NAME} 已经在运行 (PID: $(get_pid))，监听端口 ${APP_PORT}。"
        return
    fi

    if [ ! -f "${JAR_PATH}" ]; then
        log_error "未在 ${JAR_PATH} 找到 ${JAR_NAME}。请先安装应用程序。"
        return 1
    fi

    # 显示 Java 版本（简洁）但不在每次启动时阻止启动
    if command -v java >/dev/null 2>&1; then
        local java_version_short=$(java -version 2>&1 | head -n1 | sed -E 's/.*version "([^"]+)".*/\1/')
        log_info "Java 版本: ${java_version_short}"
    else
        log_error "请安装Java环境后再尝试启动 ${APP_NAME}。"
        return 1
    fi

    log_info "正在启动 ${APP_NAME}，监听端口 ${APP_PORT}，使用 ${JAVA_CMD} (日志: ${LOG_FILE})..."
    nohup "${JAVA_CMD}" -jar "${JAR_PATH}" --server.port="${APP_PORT}" > "${LOG_FILE}" 2>&1 &

    sleep 3 # 给予应用一点时间启动

    if get_pid > /dev/null; then
        log_nice "${APP_NAME} 已启动 (PID: $(get_pid))，监听端口 ${APP_PORT}。"
    else
        log_error "启动 ${APP_NAME} 失败。请查看 ${LOG_FILE} 获取详细信息。"
        return 1
    fi
    return 0
}

# Function to stop the application
stop_app() {
    PIDS=$(get_pid)
    if [ -z "$PIDS" ]; then
        log_info "${APP_NAME} 未运行。"
        return 0
    fi
    log_info "正在停止 ${APP_NAME} (PID: $PIDS)..."
    for PID in $PIDS; do
        kill "$PID"
    done
    sleep 5 # Give it some time to shut down gracefully
    # 强制杀死未关闭的
    for PID in $PIDS; do
        if ps -p "$PID" > /dev/null 2>&1; then
            log_warn "进程 $PID 未正常停止，强制杀死..."
            kill -9 "$PID"
            sleep 1
        fi
    done
    # 检查是否全部关闭
    local still_running=""
    for PID in $PIDS; do
        if ps -p "$PID" > /dev/null 2>&1; then
            still_running=1
        fi
    done
    if [ -z "$still_running" ]; then
        log_nice "${APP_NAME} 已全部停止。"
        return 0
    else
        log_error "有进程未能关闭。"
        return 1
    fi
}

# systemd 自启动管理
service_name="${APP_NAME}.service"
service_file="/etc/systemd/system/${service_name}"

install_app() {
    log_info "准备安装 ${APP_NAME}..."
    # Check if already installed
    if [ -f "${JAR_PATH}" ]; then
        read -p "${APP_NAME} 已安装。是否重新安装? [y/N]: " reinstall
        if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
            log_info "已取消安装。"
            return 0
        fi
        uninstall_app --yes
        local uninstall_rc=$?
        if [ ${uninstall_rc} -ne 0 ]; then
            if [ ${uninstall_rc} -eq 2 ]; then
                log_info "用户取消卸载，已中止重新安装。"
                return 0
            else
                echo "[错误] 卸载失败，无法继续安装。"
                return 1
            fi
        fi
    fi
    
    # Check if we have permission to create directory
    log_nice "创建应用程序目录: ${APP_HOME}"
    if ! mkdir -p "${APP_HOME}" 2>/dev/null; then
        # Need elevated privileges
        if ! check_root; then
            echo -e "${YELLOW}[提示] 需要 root 权限来创建目录 ${APP_HOME}${PLAIN}"
            echo -e "${YELLOW}[提示] 请使用以下命令运行此脚本:${PLAIN}"
            echo "      请以 root 用户运行此脚本"
            return 1
        fi
    fi
    
    # Download JAR file
    log_nice "下载 JAR: ${JAR_NAME}"
    log_info "${JAR_DOWNLOAD_URL}"
    log_info "这可能需要一些时间，请稍候..."
    
    local temp_jar=$(mktemp --suffix=.jar)
    if ! curl -L -o "${temp_jar}" "${JAR_DOWNLOAD_URL}"; then
        log_error "下载 ${JAR_NAME} 失败。"
        rm -f "${temp_jar}"
        return 1
    fi
    
    # Move JAR to destination
    log_nice "安装 JAR 到: ${JAR_PATH}"
    log_info "正在移动文件..."
    if ! mv "${temp_jar}" "${JAR_PATH}" 2>/dev/null; then
        if ! check_root; then
            log_tip "需要 root 权限来写入文件到 ${JAR_PATH}"
            log_tip "请以 root 用户运行此脚本"
            rm -f "${temp_jar}"
            return 1
        fi
    fi
    
    # Set permissions
    chmod 644 "${JAR_PATH}" 2>/dev/null
    
    # Check Java version
    log_info "检查 Java 环境"
    if ! check_java_version; then
        log_warn "Java ${REQUIRED_JAVA_VERSION} 或更高版本未找到。"
        log_tip "请先安装OpenJDK 17 或更高版本。"
        log_tip "例如: apt-get install openjdk-17-jre (Debian/Ubuntu)"
        log_tip "     yum install java-17-openjdk-headless (Red Hat/CentOS)"
    fi
    
    # Save configuration
    log_info "保存配置..."
    if ! bash -c "echo 'APP_PORT=${APP_PORT}' > ${CONFIG_FILE} && echo 'APP_HOME=${APP_HOME}' >> ${CONFIG_FILE} && echo 'JAVA_CMD=${JAVA_CMD}' >> ${CONFIG_FILE}" 2>/dev/null; then
        if ! check_root; then
            log_tip "需要 root 权限来保存配置文件"
            log_tip "请以 root 用户运行此脚本"
            return 1
        fi
    fi
    # 写入 systemd 服务
    if check_root; then
        cat > "$service_file" <<EOF
[Unit]
Description=${APP_NAME} Service
After=network.target

[Service]
Type=simple
ExecStart=${JAVA_CMD} -jar ${JAR_PATH} --server.port=${APP_PORT}
WorkingDirectory=${APP_HOME}
Restart=always
RestartSec=5min
User=root

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable "$service_name"
        systemctl start "$service_name"
        log_info "已设置 systemd 自启动并启动应用。"
    else
        log_tip "需 root 权限设置 systemd 服务。"
    fi
    log_nice "${APP_NAME} 已成功安装！"
    log_info "应用位置: ${JAR_PATH}"
    log_info "配置文件: ${CONFIG_FILE}"
    log_info "默认端口: ${APP_PORT}"
    log_nice "应用已启动。"
    read -p "按回车继续..."
    return 0
}

# Function to uninstall the application
uninstall_app() {
    # 支持传入参数 --yes 或 -y 表示强制卸载（跳过确认）
    local force_uninstall=0
    if [ "$1" == "--yes" ] || [ "$1" == "-y" ]; then
        force_uninstall=1
    fi

    if [ ! -f "${JAR_PATH}" ]; then
        log_info "未安装，无需卸载。"
        sleep 1
        return 0
    fi

    if [ ${force_uninstall} -eq 0 ]; then
        read -p "确认卸载 ${APP_NAME} 吗? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "已取消卸载"
            sleep 1
            # 返回特殊码 2 表示用户主动取消卸载（调用者可据此中止后续流程）
            return 2
        fi
    fi
    log_info "准备卸载 ${APP_NAME}..."
    if get_pid > /dev/null; then
        log_warn "应用正在运行，先停止..."
        stop_app
        sleep 1
    fi
    local removed_any=0
    # 直接删除整个应用目录，清除所有残留文件
    if [ -d "${APP_HOME}" ]; then
        rm -rf "${APP_HOME}"
        log_info "已删除应用目录: ${APP_HOME}"
        removed_any=1
    fi
    # 删除 systemd 服务并禁用自启动
    if [ -f "$service_file" ]; then
        systemctl stop "$service_name"
        systemctl disable "$service_name"
        rm -f "$service_file"
        systemctl daemon-reload
        log_info "已删除 systemd 服务及自启动。"
    fi
    if [ "$removed_any" -eq 1 ]; then
        log_nice "${APP_NAME} 卸载完成。"
    else
        log_info "未找到可删除的文件。"
    fi
    sleep 1
    return 0
}

# Function to display main menu
main_menu() {
    while true; do
        clear
        local status="未运行"
        local pid=$(get_pid)
        local status_color="\033[31m" # 红色
        if [ ! -f "$JAR_PATH" ]; then
            status="未安装"
            status_color="\033[33m" # 黄色
        elif [ -n "$pid" ]; then
            status="运行中 (PID: $pid)"
            status_color="\033[32m" # 绿色
        fi
        # 检查 Java 并使用与应用状态相同的颜色显示（与 status_color 保持一致）
        local java_version_label="${status_color}未知${PLAIN}"
        if command -v java >/dev/null 2>&1; then
            java_version_output=$(java -version 2>&1)
            local java_version_short=$(echo "$java_version_output" | head -n1 | sed -E 's/.*version "([^\"]+)".*/\1/')
            if [ -n "$java_version_short" ]; then
                java_version_label="${status_color}${java_version_short}${PLAIN}"
            else
                java_version_label="${status_color}未知${PLAIN}"
            fi
        else
            java_version_label="${status_color}未安装${PLAIN}"
        fi

        echo "----------------------------------------------"
        echo -e "       ${CYAN}${APP_NAME} 管理菜单${PLAIN}"
        echo "----------------------------------------------"
        echo -e " 状态      : ${status_color}${status}${PLAIN}"
        if [ -f "$JAR_PATH" ]; then
            echo -e " 监听端口  : ${CYAN}${APP_PORT}${PLAIN}"
            echo -e " 安装位置  : ${CYAN}${APP_HOME}${PLAIN}"
        else
            echo -e " 监听端口  : ${YELLOW}--${PLAIN}"
            echo -e " 安装位置  : ${YELLOW}--${PLAIN}"
        fi
        echo -e " Java版本  : ${java_version_label}"
        echo "----------------------------------------------"
        echo " 1. 启动 ${APP_NAME}"
        echo " 2. 停止 ${APP_NAME}"
        echo " 3. 重启 ${APP_NAME}"
        echo " 4. 设置"
        echo " 0. 退出"
        echo "----------------------------------------------"
        read -p "请输入选择 [0-4]: " choice
        case $choice in
            1)
                start_app
                sleep 2
                ;;
            2)
                stop_app
                sleep 1
                ;;
            3)
                restart_app
                sleep 2
                ;;
            4)
                settings_menu
                ;;
            0)
                exit 0
                ;;
            *)
                ;;
        esac
    done
}

settings_menu() {
    while true; do
        clear
        echo "     ${APP_NAME} 设置菜单"
        echo "--------------------------------"
        echo " 1. 安装 ${APP_NAME}"
        echo " 2. 卸载 ${APP_NAME}"
        echo " 3. 设置端口"
        echo " 4. 自启动管理"
        echo " 0. 返回"
        echo "--------------------------------"
        read -p "请输入选择 [0-4]: " choice
        case $choice in
            1)
                install_app
                ;;
            2)
                uninstall_app
                sleep 1
                ;;
            3)
                read -p "请输入新端口号 (当前: ${APP_PORT}): " new_port
                if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -gt 0 ] && [ "$new_port" -lt 65536 ]; then
                    APP_PORT="$new_port"
                    save_config
                    log_nice "端口已设置为 ${APP_PORT}。"
                else
                    log_error "无效的端口号 (必须在 1-65535 之间)。"
                fi
                sleep 1
                ;;
            4)
                manage_autostart
                ;;
            0)
                return
                ;;
            *)
                ;;
        esac
    done
}

manage_autostart() {
    while true; do
        clear
        local status="未启用"
        if systemctl is-enabled "$service_name" 2>/dev/null | grep -q enabled; then
            status="已启用"
        fi
        echo "     ${APP_NAME} 自启动管理 "
        echo "--------------------------------"
        echo "当前自启动状态: $status"
        echo "--------------------------------"
        echo " 1. 启用自启动"
        echo " 2. 禁用自启动"
        echo " 0. 返回"
        echo "--------------------------------"
        read -p "请输入选择 [0-2]: " choice
        case $choice in
            1)
                systemctl enable "$service_name" && systemctl start "$service_name"
                log_nice "已启用并启动自启动。"
                ;;
            2)
                systemctl disable "$service_name" && systemctl stop "$service_name"
                log_nice "已禁用自启动并停止服务。"
                ;;
            0)
                return
                ;;
            *)
                ;;
        esac
    done
}

# Initial configuration load
load_config

# Display main menu
main_menu
