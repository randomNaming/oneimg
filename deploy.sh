#!/bin/bash

# OneIMG Docker 部署脚本
# 适用于 AMD64 (x86_64) 架构的 Linux 服务器

set -e

echo "=========================================="
echo "OneIMG Docker 部署脚本"
echo "=========================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查当前架构
ARCH=$(uname -m)
echo "检测到系统架构: $ARCH"

if [ "$ARCH" != "x86_64" ]; then
    echo "警告: 此脚本主要针对 x86_64 (AMD64) 架构"
fi

# 镜像名称和标签
IMAGE_NAME="oneimg"
IMAGE_TAG="latest"
CONTAINER_NAME="oneimg"
PORT="3000"

# 停止并删除旧容器（如果存在）
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "停止并删除旧容器..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
fi

# 清理旧的构建缓存（可选，如果需要完全重新构建）
# echo "清理旧的构建缓存..."
# docker builder prune -f

# 构建镜像
echo "开始构建 Docker 镜像..."
echo "镜像名称: $IMAGE_NAME:$IMAGE_TAG"
echo "注意: 构建过程可能需要几分钟，请耐心等待..."
docker build --platform linux/amd64 --no-cache -t $IMAGE_NAME:$IMAGE_TAG .

if [ $? -eq 0 ]; then
    echo "镜像构建成功！"
else
    echo "镜像构建失败！"
    exit 1
fi

# 运行容器
echo "启动容器..."
docker run -d \
    --name $CONTAINER_NAME \
    --platform linux/amd64 \
    -p $PORT:3000 \
    --restart=always \
    $IMAGE_NAME:$IMAGE_TAG

if [ $? -eq 0 ]; then
    echo "容器启动命令执行成功，等待容器就绪..."
    sleep 5
    
    # 检查容器是否正在运行
    if docker ps | grep -q $CONTAINER_NAME; then
        echo "=========================================="
        echo "部署成功！"
        echo "=========================================="
        echo "容器名称: $CONTAINER_NAME"
        echo "访问地址: http://localhost:$PORT/meigui"
        echo ""
        echo "测试访问:"
        echo "  curl http://127.0.0.1:$PORT/meigui"
        echo ""
        echo "常用命令:"
        echo "  查看容器状态: docker ps -a | grep $CONTAINER_NAME"
        echo "  查看容器日志: docker logs -f $CONTAINER_NAME"
        echo "  停止容器: docker stop $CONTAINER_NAME"
        echo "  启动容器: docker start $CONTAINER_NAME"
        echo "  删除容器: docker rm -f $CONTAINER_NAME"
        echo ""
        echo "诊断脚本:"
        echo "  bash check-container.sh"
    else
        echo "警告: 容器启动后立即停止，请检查日志："
        echo "  docker logs $CONTAINER_NAME"
        exit 1
    fi
else
    echo "容器启动失败！"
    exit 1
fi

