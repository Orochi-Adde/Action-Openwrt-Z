#!/bin/bash

echo "正在清理不需要的视频和多媒体 Feeds（如 video/qt5）..."
# 1. 如果 feeds.conf.default 里有 video 源，直接把它注释掉或删掉
sed -i '/video/d' feeds.conf.default

# 2. 如果已经拉取下来了，直接暴力删除对应的 feeds 文件夹
rm -rf feeds/video
rm -rf package/feeds/video
# 暴力清除有循环依赖风险的垃圾插件目录
rm -rf feeds/packages/net/weechat
rm -rf feeds/packages/sound/squeezelite

echo "正在写入 LuCI 网页后台、中文包及常用网络组件..."
cat >> .config << 'EOF'
# 1. 基础 LuCI 与中文支持
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y

# 2. 宽带拨号刚需（PPPoE 拨号）
CONFIG_PACKAGE_ppp-mod-pppoe=y

# 3. IPv6 支持
CONFIG_PACKAGE_ipv6helper=y
CONFIG_PACKAGE_luci-proto-ipv6=y

# 4. 常用系统与排查工具
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_curl=y
EOF

echo "正在创建首次开机自动开启 Wi-Fi 的 uci-defaults 脚本..."
mkdir -p files/etc/uci-defaults
cat << 'EOF' > files/etc/uci-defaults/99-enable-wifi
#!/bin/sh
uci -q batch << EOI
set wireless.radio0.disabled=0
set wireless.radio1.disabled=0
commit wireless
EOI
exit 0
EOF
chmod +x files/etc/uci-defaults/99-enable-wifi

echo "diy.sh 定制脚本执行完成！"
