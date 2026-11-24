#!/bin/bash
# FRP 服务端一键安装（Alibaba Cloud Linux / CentOS / Ubuntu 通用）
# 用法：bash install-frps.sh

set -e

FRP_VER="0.72.0"
FRP_DIR="/opt/frp"
TOKEN="Dreame2026AltPart"
WEB_USER="admin"
WEB_PASS="Dreame2026"

echo "=========================================="
echo "  FRP 服务端安装"
echo "=========================================="
echo ""

# 1. 检查 root
if [ "$(id -u)" != "0" ]; then
  echo "[错误] 请用 root 权限运行（sudo bash $0）"
  exit 1
fi

# 2. 下载 frp
echo "[1/6] 下载 frp ${FRP_VER} ..."
mkdir -p ${FRP_DIR}
cd /tmp
if [ ! -f frp.tar.gz ]; then
  curl -sL -o frp.tar.gz "https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_amd64.tar.gz"
fi
tar -xzf frp.tar.gz
cp frp_${FRP_VER}_linux_amd64/frps ${FRP_DIR}/frps
chmod +x ${FRP_DIR}/frps
echo "     完成"

# 3. 写配置
echo "[2/6] 生成配置 ..."
cat > ${FRP_DIR}/frps.toml << EOF
bindPort = 7000

auth.method = "token"
auth.token = "${TOKEN}"

vhostHTTPPort = 8080

webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "${WEB_USER}"
webServer.password = "${WEB_PASS}"

log.to = "/var/log/frps.log"
log.level = "info"
log.maxDays = 7
EOF
echo "     完成"

# 4. 创建 systemd 服务
echo "[3/6] 配置开机自启 ..."
cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=FRP Server
After=network.target

[Service]
Type=simple
ExecStart=${FRP_DIR}/frps -c ${FRP_DIR}/frps.toml
Restart=always
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable frps >/dev/null 2>&1
echo "     完成"

# 5. 启动
echo "[4/6] 启动服务 ..."
systemctl restart frps
sleep 3
echo "     完成"

# 6. 检查
echo "[5/6] 检查状态 ..."
if systemctl is-active --quiet frps; then
  echo "     ✓ frps 运行中"
else
  echo "     ✗ frps 启动失败，查看日志："
  journalctl -u frps -n 20 --no-pager
  exit 1
fi

echo "[6/6] 端口检查 ..."
ss -tlnp 2>/dev/null | grep -E ':7000|:7500|:8080' || echo "     (端口未监听)"

echo ""
echo "=========================================="
echo "  安装完成"
echo "=========================================="
echo ""
echo "  服务端地址: 47.77.229.61:7000"
echo "  Token:      ${TOKEN}"
echo "  Web 面板:   http://47.77.229.61:7500"
echo "  面板账号:   ${WEB_USER} / ${WEB_PASS}"
echo ""
echo "  常用命令："
echo "    查看状态: systemctl status frps"
echo "    查看日志: journalctl -u frps -f"
echo "    重启:     systemctl restart frps"
echo ""
echo "  下一步：在你电脑上运行 frpc"
echo ""
