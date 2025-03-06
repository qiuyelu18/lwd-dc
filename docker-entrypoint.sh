#!/bin/bash

# 打印环境变量信息
echo "环境变量信息:"
echo "NEXTAUTH_SECRET: ${NEXTAUTH_SECRET:0:3}***"
echo "HF_TOKEN: ${HF_TOKEN:0:3}***"
echo "DATASET_ID: ${DATASET_ID}"
echo "SPACE_ID: ${SPACE_ID}"
echo "DATABASE_URL: ${DATABASE_URL:0:20}***"

# 确保数据目录存在
mkdir -p /app/data
echo "数据目录已创建: /app/data"

# 检查数据库连接
echo "检查数据库连接..."
max_retries=10
counter=0
until pg_isready -d "$DATABASE_URL" 2>/dev/null; do
    sleep 2
    counter=$((counter + 1))
    echo "尝试连接数据库... $counter/$max_retries"
    if [ $counter -ge $max_retries ]; then
        echo "警告: 无法连接到数据库，但将继续尝试启动应用"
        break
    fi
done
echo "数据库连接检查完成"

# 下载最新备份
if [[ ! -z "$HF_TOKEN" ]] && [[ ! -z "$DATASET_ID" ]]; then
    echo "正在从HuggingFace下载最新备份..."
    /sync_data.sh download
fi

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