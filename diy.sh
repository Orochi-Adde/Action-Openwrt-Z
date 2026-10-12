#!/bin/bash

echo "正在写入 LuCI 网页后台、中文包及常用网络组件..."
cat >> .config << 'EOF'
# 1. 基础 LuCI 与中文支持
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y

# 2. 宽带拨号刚需（PPPoE 拨号，防止光猫桥接后无法联网）
CONFIG_PACKAGE_ppp-mod-pppoe=y

# 3. IPv6 支持（国内主流运营商必备）
CONFIG_PACKAGE_ipv6helper=y
CONFIG_PACKAGE_luci-proto-ipv6=y

# 4. 常用系统与排查工具（可选，方便在后台看状态）
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_curl=y
EOF

echo "正在创建首次开机自动开启 Wi-Fi 的 uci-defaults 脚本..."
mkdir -p files/etc/uci-defaults
cat << 'EOF' > files/etc/uci-defaults/99-enable-wifi
#!/bin/sh
# 强行将无线配置中的 disabled 设为 0，实现开机默认开启 Wi-Fi
# K2P 通常 radio0 是 2.4G，radio1 是 5G
uci -q batch << EOI
set wireless.radio0.disabled=0
set wireless.radio1.disabled=0
commit wireless
EOI
exit 0
EOF
chmod +x files/etc/uci-defaults/99-enable-wifi

echo "diy.sh 定制脚本执行完成！"
