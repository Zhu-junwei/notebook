#!/bin/bash
# 脚本名称：Termux 恢复脚本
# 脚本作者：@zjw
# 脚本版本：1.0
# 脚本描述：从备份文件中恢复 Termux 的 ./home 和 ./usr 目录。

# 默认备份目录
BACKUP_DIR="/sdcard/Download"

# 检查 Termux 是否具有存储权限
check_storage_permission() {
    if [ ! -d "$HOME/storage/shared" ]; then
        echo "Termux does not have storage permission."
        echo "Requesting storage permission..."
        termux-setup-storage
        echo "Please click 'Allow' in the pop-up dialog, then press Enter to continue..."
        read -r  # 等待用户按下回车键
    fi

    # 再次检查权限
    if [ ! -d "$HOME/storage/shared" ]; then
        echo "Error: Storage permission not granted. The script cannot continue."
        exit 1
    else
        echo "Storage permission granted. Continuing with restore..."
    fi
}

# 查找最新的备份文件
find_latest_backup() {
    local latest_backup
    # 使用 find 查找所有备份文件，并按修改时间排序
    latest_backup=$(find "$BACKUP_DIR" "." -type f -name "termux-backup-*.tar.gz" -printf "%T@ %p\n" | sort -n | tail -n1 | cut -d' ' -f2-)

    if [ -z "$latest_backup" ]; then
        echo "Error: No backup files found in $BACKUP_DIR or the current directory."
        exit 1
    fi

    echo "$latest_backup"
}

# 恢复备份
restore_backup() {
    local backup_file=$1
    echo "Restoring from backup file: $backup_file..."

    if ! tar -zxf "$backup_file" -C /data/data/com.termux/files --recursive-unlink --preserve-permissions; then
        echo "Error: Failed to restore backup."
        exit 1
    fi

    echo "Restore completed successfully."
}

# 主逻辑
main() {
    local backup_file

    # 检查存储权限
    check_storage_permission

    # 如果提供了参数，则使用指定的备份文件
    if [ $# -ge 1 ]; then
        backup_file=$1
    else
        # 否则查找最新的备份文件
        echo "No backup file specified. Searching for the latest backup in $BACKUP_DIR..."
        backup_file=$(find_latest_backup)
    fi

    # 检查备份文件是否存在
    if [ ! -f "$backup_file" ]; then
        echo "Error: Backup file not found: $backup_file"
        exit 1
    fi

    # 恢复备份
    restore_backup "$backup_file"
}

# 执行主逻辑
main "$@"