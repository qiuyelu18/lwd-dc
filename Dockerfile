FROM node:18.18-bullseye-slim AS base
 
# 安装Python和必要的依赖
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv curl ca-certificates git && \
    python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --no-cache-dir huggingface_hub && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
# 安装Rust和monolith
FROM rust:1.80-bullseye AS monolith-builder
RUN cargo install --locked monolith
 
# 主应用阶段
FROM base AS main-app
 
ARG DEBIAN_FRONTEND=noninteractive
 
WORKDIR /app
 
# 复制应用文件
COPY package.json yarn.lock ./
 
# 安装依赖
RUN yarn install --network-timeout 10000000 && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
# 从monolith-builder复制monolith二进制文件
COPY --from=monolith-builder /usr/local/cargo/bin/monolith /usr/local/bin/monolith
 
# 安装Playwright
RUN npx playwright install --with-deps chromium && \
    yarn cache clean
 
# 复制应用代码
COPY . .
 
# 生成Prisma客户端并构建应用
RUN yarn prisma generate && \
    yarn build
 
# 复制数据同步脚本
COPY sync_data.sh /
RUN chmod +x /sync_data.sh
 
# 复制入口脚本
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
 
# 健康检查
HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
            CMD [ "/usr/bin/curl", "--silent", "--fail", "http://127.0.0.1:3000/" ]
 
# 暴露端口
EXPOSE 3000
 
# 设置入口点
ENTRYPOINT ["/docker-entrypoint.sh"]


ref(APA): 7thLiane.Qiyuelianï¿½s blog.https://qyl.lovestoblog.com. Retrieved 2025/3/6.
