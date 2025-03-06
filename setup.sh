#!/bin/bash

# 检查是否在Huggingface Space环境中
if [ -z "$SPACE_ID" ]; then
    echo "错误：此脚本应在Huggingface Space环境中运行"
    exit 1
fi

echo "===== Linkwarden部署助手 ====="
echo "此脚本将帮助您设置必要的环境变量"
echo ""

# 生成随机密钥
RANDOM_SECRET=$(openssl rand -base64 32)

echo "已为您生成随机密钥"
echo "NextAuth密钥: $RANDOM_SECRET"
echo ""
echo "请在Huggingface Space的Settings > Repository secrets中添加以下Secrets:"
echo ""
echo "1. NEXTAUTH_SECRET: $RANDOM_SECRET"
echo "2. DATABASE_URL: 您的外部PostgreSQL数据库URL (格式: postgresql://username:password@hostname:port/database)"
echo "3. HF_TOKEN: 您的Huggingface Token"
echo "4. DATASET_ID: 您的数据集ID (格式: 用户名/数据集名称)"
echo "5. SYNC_INTERVAL: 数据同步间隔时间 (可选，默认7200秒)"
echo ""
echo "外部PostgreSQL数据库推荐："
echo "- ElephantSQL (https://www.elephantsql.com/) - 免费计划提供20MB存储空间"
echo "- Supabase (https://supabase.com/) - 免费计划提供500MB存储空间"
echo "- Neon (https://neon.tech/) - 免费计划提供3GB存储空间"
echo ""
echo "添加完成后，重启Space以应用新的环境变量" 