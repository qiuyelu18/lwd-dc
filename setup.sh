#!/bin/bash
 
# 检查是否在Huggingface Space环境中
if [ -z "$SPACE_ID" ]; then
    echo "错误：此脚本应在Huggingface Space环境中运行"
    exit 1
fi
 
echo "===== Linkwarden部署助手 ====="
echo "此脚本将帮助您设置必要的环境变量"
echo ""
 
# 生成随机密码和密钥
RANDOM_PASSWORD=$(openssl rand -base64 12)
RANDOM_SECRET=$(openssl rand -base64 32)
 
echo "已为您生成随机数据库密码和密钥"
echo "数据库密码: $RANDOM_PASSWORD"
echo "NextAuth密钥: $RANDOM_SECRET"
echo ""
echo "请在Huggingface Space的Settings > Repository secrets中添加以下Secrets:"
echo ""
echo "1. POSTGRES_PASSWORD: $RANDOM_PASSWORD"
echo "2. NEXTAUTH_SECRET: $RANDOM_SECRET"
echo "3. HF_TOKEN: 您的Huggingface Token"
echo "4. DATASET_ID: 您的数据集ID (格式: 用户名/数据集名称)"
echo "5. SYNC_INTERVAL: 数据同步间隔时间 (可选，默认7200秒)"
echo ""
echo "添加完成后，重启Space以应用新的环境变量"
