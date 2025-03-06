#!/bin/bash
 
# 检查必要的环境变量
if [[ -z "$NEXTAUTH_SECRET" ]] || [[ -z "$POSTGRES_PASSWORD" ]]; then
    echo "错误：缺少必要的环境变量 NEXTAUTH_SECRET 或 POSTGRES_PASSWORD"
    echo "请在Huggingface Space的Settings > Repository secrets中添加这些Secrets"
    exit 1
fi
 
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
