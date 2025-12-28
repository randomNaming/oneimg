#!/bin/bash

# 容器诊断脚本

echo "=========================================="
echo "容器诊断信息"
echo "=========================================="

# 检查容器状态
echo ""
echo "1. 容器状态："
docker ps -a | grep oneimg || echo "容器不存在"

# 检查容器日志（最后20行）
echo ""
echo "2. 容器日志（最后20行）："
docker logs --tail 20 oneimg 2>/dev/null || echo "无法获取日志"

# 检查端口映射
echo ""
echo "3. 端口映射："
docker port oneimg 2>/dev/null || echo "无法获取端口信息"

# 测试本地访问
echo ""
echo "4. 测试本地访问 (http://127.0.0.1:3000/meigui)："
curl -I http://127.0.0.1:3000/meigui 2>&1 | head -5 || echo "无法访问"

# 检查容器内的构建配置
echo ""
echo "5. 检查容器内的 next.config.mjs："
docker exec oneimg cat /app/next.config.mjs 2>/dev/null || echo "无法读取配置文件"

# 检查 .next 目录
echo ""
echo "6. 检查 .next 目录是否存在："
docker exec oneimg ls -la /app/.next 2>/dev/null | head -10 || echo "无法访问 .next 目录"

# 检查构建 ID
echo ""
echo "7. 构建 ID："
docker exec oneimg cat /app/.next/BUILD_ID 2>/dev/null || echo "无法获取构建 ID"

echo ""
echo "=========================================="

