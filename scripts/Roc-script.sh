# 修改默认IP & 固件名称 & 编译署名
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='Roc'/g" package/base-files/files/bin/config_generate
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Built by Roc')/g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# 修正使用ccache编译vlmcsd的问题
mkdir -p feeds/packages/net/vlmcsd/patches
cp -f $GITHUB_WORKSPACE/patches/fix_vlmcsd_compile_with_ccache.patch feeds/packages/net/vlmcsd/patches

# 调整NSS驱动q6_region内存区域预留大小（ipq6018.dtsi默认预留85MB，ipq6018-512m.dtsi默认预留55MB，带WiFi必须至少预留54MB，以下分别是改成预留16MB、32MB、64MB和96MB）
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x01000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x02000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x04000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x06000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi

# 移除要替换的包
rm -rf feeds/packages/net/open-app-filter
rm -rf feeds/luci/applications/luci-app-appfilter
rm -rf feeds/packages/net/adguardhome
# rm -rf feeds/packages/net/openlist
# rm -rf feeds/luci/applications/luci-app-openlist

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# OpenList & AdGuardHome & WolPlus & Lucky & OpenAppFilter & 集客无线AC控制器 & 雅典娜LED控制
git clone --depth=1 https://github.com/sbwml/luci-app-openlist2 package/openlist
git_sparse_clone master https://github.com/kenzok8/openwrt-packages adguardhome luci-app-adguardhome
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/luci-app-lucky
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac package/openwrt-gecoosac
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`
sed -i 's/"HomeProxy"/"科学上网"/g' `grep "HomeProxy" -rl ./`
sed -i 's/"启动项"/"启动项目"/g' `grep "启动项" -rl ./`
sed -i 's/"挂载点"/"挂载地点"/g' `grep "挂载点" -rl ./`
sed -i 's/"重启"/"重启开关"/g' `grep "重启" -rl ./`
sed -i 's/"主机名"/"主机名称"/g' `grep "主机名" -rl ./`
sed -i 's/"接口"/"接口设置"/g' `grep "接口" -rl ./`
sed -i 's/"无线"/"无线设置"/g' `grep "无线" -rl ./`
sed -i 's/"管理权"/"管理设置"/g' `grep "管理权" -rl ./`
sed -i 's/"软件包"/"软件包名"/g' `grep "软件包" -rl ./`
sed -i 's/"UPnP IGD 和 PCP"/"U P N P"/g' `grep "UPnP IGD 和 PCP" -rl ./`
sed -i 's/"动态 DNS"/"动态DNS"/g' `grep "动态 DNS" -rl ./`
sed -i 's/"路由表"/"路由器表"/g' `grep "路由表" -rl ./`
sed -i 's/"路由"/"路由设置"/g' `grep "路由" -rl ./`
sed -i 's/"备份与升级"/"备份升级"/g' `grep "备份与升级" -rl ./`
sed -i 's/"FileBrowser"/"文件管理"/g' `grep "FileBrowser" -rl ./`
sed -i 's/"终端"/"终端命令"/g' `grep "终端" -rl ./`

./scripts/feeds update -a
./scripts/feeds install -a
