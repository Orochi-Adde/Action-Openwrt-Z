#!/bin/bash

echo "=========================================="
echo " 开始执行 diy.sh 自定义配置与清理..."
echo "=========================================="

# 1. 暴力清除所有有循环依赖风险的垃圾插件目录与视频源
sed -i '/video/d' feeds.conf.default 2>/dev/null || true
rm -rf feeds/video package/feeds/video 2>/dev/null || true
rm -rf feeds/packages/net/weechat 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite 2>/dev/null || true

# 2. 写入完整的固件核心配置 (.config)
cat >> .config << 'EOF'
# --- LuCI 网页后台与中文语言包 ---
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-i18n-opkg-zh-cn=y
CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y
CONFIG_PACKAGE_luci-i18n-network-zh-cn=y
# 确保开启系统包管理器 opkg
CONFIG_PACKAGE_opkg=y
CONFIG_LUCI_LANG_zh_Hans=y

# --- USB 基础控制器与手机/网卡共享驱动 ---
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb3=y
# 安卓 USB 共享 (RNDIS / CDC-Ethernet)
CONFIG_PACKAGE_kmod-usb-net=y
CONFIG_PACKAGE_kmod-usb-net-rndis=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y
# 苹果 iPhone USB 共享
CONFIG_PACKAGE_kmod-usb-net-ipheth=y
CONFIG_PACKAGE_usbmuxd=y
# 常用 4G/5G 随身 WiFi / 模块驱动
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y
CONFIG_PACKAGE_kmod-usb-serial=y
CONFIG_PACKAGE_kmod-usb-serial-option=y

# --- 宽带拨号与 IPv6 支持 ---
CONFIG_PACKAGE_ppp-mod-pppoe=y
CONFIG_PACKAGE_ipv6helper=y
CONFIG_PACKAGE_luci-proto-ipv6=y

# --- 系统排查常用工具 ---
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_curl=y
EOF

# 3. 创建首次开机自动设置（默认语言中文 + 开启 Wi-Fi）
mkdir -p files/etc/uci-defaults

cat << 'EOF' > files/etc/uci-defaults/99-custom-init
#!/bin/sh

# 1. 强行把系统后台语言设为简体中文
uci set luci.main.lang='zh_cn'
uci commit luci

# 2. 首次开机自动开启 Wi-Fi (2.4G & 5G)
wifi config
uci set wireless.radio0.disabled='0'
uci set wireless.radio1.disabled='0'
uci commit wireless

# 重新加载无线配置使 Wi-Fi 立即发射信号
wifi reload 2>/dev/null || true

exit 0
EOF

# 赋权可执行权限
chmod +x files/etc/uci-defaults/99-custom-init

echo "=========================================="
echo " diy.sh 执行完毕，准备进入配置解析..."
echo "=========================================="
