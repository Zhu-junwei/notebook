#!/usr/bin/env bash
# simple script menu with select and simplified options

function diskspace {
    clear
    df -Th
    echo
    lsblk
}

function whoseon {
    clear
    who
}

function memusage {
    clear
    cat /proc/meminfo
}

PS3="Please select an option: "  # 设置提示符

# 菜单选项
options=("Disk space"
         "Logged on users"
         "Memory usage"
         "Exit")

while true; do
    clear
    echo -e "\t\t\tSys Admin Menu\n"

    # 使用 select 自动生成菜单
    select opt in "${options[@]}"; do
        case $opt in
            "Disk space")
                diskspace
                break
                ;;
            "Logged on users")
                whoseon
                break
                ;;
            "Memory usage")
                memusage
                break
                ;;
            "Exit")
                clear
                exit 0
                ;;
        esac
    done

    # 提示用户按任意键继续
    echo -e "\n\n\t\t\tHit any key to continue"
    read -n 1 line
done