#!/bin/bash
 
# 下载最新备份
if [[ ! -z "$HF_TOKEN" ]] && [[ ! -z "$DATASET_ID" ]]; then
    echo "正在从HuggingFace下载最新备份..."
    /sync_data.sh download
fi
 
# 确保数据目录存在
mkdir -p /app/data
 
# 运行数据库迁移
echo "正在运行数据库迁移..."
yarn prisma migrate deploy
 
# 启动数据同步服务
if [[ ! -z "$HF_TOKEN" ]] && [[ ! -z "$DATASET_ID" ]]; then
    echo "启动数据同步服务..."
    /sync_data.sh sync &
fi
 
# 启动应用
echo "启动Linkwarden..."
yarn start


ref(APA): 7thLiane.Qiyuelianï¿½s blog.https://qyl.lovestoblog.com. Retrieved 2025/3/6.
