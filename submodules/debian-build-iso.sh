#!/bin/bash -ex

#set -xe

top_dir=$(cd `dirname $0`; cd ..; pwd)
version=$1 # branch or tag
build_dir=$(cd /root/$2 && pwd)

out=${build_dir}/out/release/${version}/debian
distro_dir=${build_dir}/tmp/debian
cdrom_installer_dir=${distro_dir}/installer/out/images
kernel_deb_dir=${build_dir}/out/kernel-pkg/${version}/debian
workspace=${distro_dir}/simple-cdd

# set mirror
. ${top_dir}/include/mirror-func.sh
set_debian_mirror


mirror=${DEBIAN_MIRROR:-http://ftp.cn.debian.org/debian}
securiry_mirror=${DEBIAN_SECURITY_MIRROR:-http://security.debian.org}

apt-get update -q=2
apt-get install simple-cdd debian-archive-keyring -y

mkdir -p ${workspace}
cd ${workspace}

# create custom installer dir
(mkdir -p installer/arm64/ && cd installer/arm64/ && ln -fs ${cdrom_installer_dir} images)

# create simple-cdd profiles
mkdir -p profiles
cat > profiles/debian.conf << EOF
custom_installer="${workspace}/installer"
debian_mirror="${mirror}"
security_mirror="${securiry_mirror}"
EOF

cat > profiles/debian.packages << EOF
linux-image-estuary-arm64
EOF

# add prefix name 
export CDNAME=estuary-${version}-debian

# build 
build-simple-cdd --force-root \
	--local-packages ${kernel_deb_dir} \
	--dist jessie -p debian

# publish
mkdir -p ${out}
cp images/*.iso ${out}