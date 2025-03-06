#!/bin/bash
 
# 检查环境变量
if [[ -z "$HF_TOKEN" ]] || [[ -z "$DATASET_ID" ]]; then
    echo "缺少HF_TOKEN或DATASET_ID环境变量，无法启用备份功能"
    exit 0
fi
 
# 激活虚拟环境
source /opt/venv/bin/activate
 
# 上传备份
upload_backup() {
    file_path="$1"
    file_name="$2"
    token="$HF_TOKEN"
    repo_id="$DATASET_ID"
 
    python3 -c "
from huggingface_hub import HfApi
import sys
import os
def manage_backups(api, repo_id, max_files=50):
    files = api.list_repo_files(repo_id=repo_id, repo_type='dataset')
    backup_files = [f for f in files if f.startswith('linkwarden_backup_') and f.endswith('.tar.gz')]
    backup_files.sort()
 
    if len(backup_files) >= max_files:
        files_to_delete = backup_files[:(len(backup_files) - max_files + 1)]
        for file_to_delete in files_to_delete:
            try:
                api.delete_file(path_in_repo=file_to_delete, repo_id=repo_id, repo_type='dataset')
                print(f'已删除旧备份: {file_to_delete}')
            except Exception as e:
                print(f'删除 {file_to_delete} 时出错: {str(e)}')
api = HfApi(token='$token')
try:
    api.upload_file(
        path_or_fileobj='$file_path',
        path_in_repo='$file_name',
        repo_id='$repo_id',
        repo_type='dataset'
    )
    print(f'成功上传 $file_name')
 
    manage_backups(api, '$repo_id')
except Exception as e:
    print(f'上传文件时出错: {str(e)}')
"
}
 
# 下载最新备份
download_latest_backup() {
    token="$HF_TOKEN"
    repo_id="$DATASET_ID"
 
    python3 -c "
from huggingface_hub import HfApi
import sys
import os
import tarfile
import tempfile
api = HfApi(token='$token')
try:
    files = api.list_repo_files(repo_id='$repo_id', repo_type='dataset')
    backup_files = [f for f in files if f.startswith('linkwarden_backup_') and f.endswith('.tar.gz')]
 
    if not backup_files:
        print('未找到备份文件')
        sys.exit()
 
    latest_backup = sorted(backup_files)[-1]
 
    with tempfile.TemporaryDirectory() as temp_dir:
        filepath = api.hf_hub_download(
            repo_id='$repo_id',
            filename=latest_backup,
            repo_type='dataset',
            local_dir=temp_dir
        )
 
        if filepath and os.path.exists(filepath):
            with tarfile.open(filepath, 'r:gz') as tar:
                tar.extractall('/app/data')
            print(f'成功从 {latest_backup} 恢复备份')
 
except Exception as e:
    print(f'下载备份时出错: {str(e)}')
"
}
 
# 同步数据
sync_data() {
    while true; do
        echo "开始同步过程，时间: $(date)"
 
        if [ -d /app/data ]; then
            timestamp=$(date +%Y%m%d_%H%M%S)
            backup_file="linkwarden_backup_${timestamp}.tar.gz"
 
            # 压缩数据目录
            tar -czf "/tmp/${backup_file}" -C /app/data .
 
            echo "正在上传备份到HuggingFace..."
            upload_backup "/tmp/${backup_file}" "${backup_file}"
 
            rm -f "/tmp/${backup_file}"
        else
            echo "数据目录不存在，等待下次同步..."
        fi
 
        SYNC_INTERVAL=${SYNC_INTERVAL:-7200}
        echo "下次同步将在 ${SYNC_INTERVAL} 秒后进行..."
        sleep $SYNC_INTERVAL
    done
}
 
# 根据命令行参数执行不同操作
case "$1" in
    download)
        download_latest_backup
        ;;
    sync)
        sync_data
        ;;
    *)
        echo "用法: $0 {download|sync}"
        exit 1
        ;;
esac
