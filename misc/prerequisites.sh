#!/bin/bash

if [[ -z "$WORKDIR" ]]; then
    WORKDIR=/tmp/ovenmediaengine
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    NCPU=$(sysctl -n hw.ncpu)
    OSNAME=$(sw_vers -productName)
    OSVERSION=$(sw_vers -productVersion)
else
    NCPU=$(nproc)
    OSNAME=$(cat /etc/*-release | grep "^NAME" | tr -d "\"" | cut -d"=" -f2)
    OSVERSION=$(cat /etc/*-release | grep ^VERSION= | tr -d "\"" | cut -d"=" -f2 | cut -d"." -f1 | awk '{print  $1}')
fi

MAKE="make -j${NCPU}"
CURRENT=$(pwd)

check_cached_build()
{
    PACKAGE_NAME=$1
    if [[ ! -z "$CACHED_BUILD" && -f "${WORKDIR}/$PACKAGE_NAME.prefix" ]]; then
        CACHED_PREFIX=$(cat ${WORKDIR}/$PACKAGE_NAME.prefix)
        if [[ "$PREFIX" == "$CACHED_PREFIX" ]]; then
            echo "Skipping building $PACKAGE_NAME since ${WORKDIR}/$PACKAGE_NAME.build has the same prefix"
            return 0
        fi
    fi
    return 1
}

install_libsrt()
{
    LIBSRT_PACKAGE_NAME=srt-1.3.1
    if check_cached_build $LIBSRT_PACKAGE_NAME; then
        return 0
    fi

    BUILD_PRG="LIBSRT"

    cd ${WORKDIR}

    if [ ! -d ${BUILD_PRG} ]; then
        curl -OLf https://github.com/Haivision/srt/archive/v1.3.1.tar.gz || fail_exit ${BUILD_PRG}
        tar xvf v1.3.1.tar.gz -C ${WORKDIR} && rm -rf v1.3.1.tar.gz && mv srt-* ${BUILD_PRG}
    fi

    cd ${BUILD_PRG}

    if [[ ! -z "$PREFIX" ]]; then
        LIBSRT_PREFIX="--prefix=$PREFIX"
        LIBSRT_OPENSSL_FLAGS="--openssl-include-dir=$PREFIX/include"
    fi

    ./configure $LIBSRT_PREFIX $LIBSRT_OPENSSL_FLAGS && ${MAKE} || exit 1

    if [[ ! -z "$PREFIX" && -w "$PREFIX" ]]; then
        make install || exit 1
    else
        sudo make install || exit 1
    fi

    echo $PREFIX > ${WORKDIR}/$LIBSRT_PACKAGE_NAME.prefix
}

install_libsrtp()
{
    LIBSRTP_PACKAGE_NAME=libsrtp-2.2.0
    if check_cached_build $LIBSRTP_PACKAGE_NAME; then
        return 0
    fi

    BUILD_PRG="LIBSRTP"

    cd ${WORKDIR}

    if [ ! -d ${BUILD_PRG} ]; then
        curl -OLkf https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz || fail_exit ${BUILD_PRG}
        tar xvfz v2.2.0.tar.gz -C ${WORKDIR} && rm -rf v2.2.0.tar.gz && mv libsrtp-* ${BUILD_PRG}
    fi

    cd ${BUILD_PRG}

    if [[ ! -z "$PREFIX" ]]; then
        LIBSRTP_PREFIX="--prefix=$PREFIX"
    fi

    ./configure $LIBSRTP_PREFIX --enable-openssl && ${MAKE} || exit 1

    if [[ ! -z "$PREFIX" && -w "$PREFIX" ]]; then
        make install || exit 1
    else
        sudo make install || exit 1
    fi

    echo $PREFIX > ${WORKDIR}/$LIBSRTP_PACKAGE_NAME.prefix
}

install_fdk_aac()
{
    FDK_AAC_PACKAGE_NAME=fdk-aac-0.1.5
    if check_cached_build $FDK_AAC_PACKAGE_NAME; then
        return 0
    fi

    BUILD_PRG="FDKAAC"

    cd ${WORKDIR}

    if [ ! -d ${BUILD_PRG} ]; then
        curl -OLf https://github.com/mstorsjo/fdk-aac/archive/v0.1.5.tar.gz  || fail_exit ${BUILD_PRG}
        tar xvf v0.1.5.tar.gz -C ${WORKDIR} && rm -rf v0.1.5.tar.gz && mv fdk-aac-* ${BUILD_PRG}
    fi

    cd ${BUILD_PRG}

    if [[ ! -z "$PREFIX" ]]; then
        FDK_AAC_PREFIX="--prefix=$PREFIX"
    fi

    ./autogen.sh && ./configure $FDK_AAC_PREFIX && ${MAKE} || exit 1

    if [[ ! -z "$PREFIX" && -w "$PREFIX" ]]; then
        make install || exit 1
    else
        sudo make install || exit 1
    fi

    echo $PREFIX > ${WORKDIR}/$FDK_AAC_PACKAGE_NAME.prefix
}

install_libopus()
{
    LIBOPUS_PACKAGE_NAME=opus-1.1.13
    if check_cached_build $LIBOPUS_PACKAGE_NAME; then
        return 0
    fi

    BUILD_PRG="OPUS"

    cd ${WORKDIR}

    if [ ! -d ${BUILD_PRG} ]; then
        curl -OLf https://archive.mozilla.org/pub/opus/opus-1.1.3.tar.gz  || fail_exit ${BUILD_PRG}
        tar xvfz opus-1.1.3.tar.gz -C ${WORKDIR} && rm -rf opus-1.1.3.tar.gz && mv opus-* ${BUILD_PRG}
    fi

    cd ${BUILD_PRG}

    if [[ ! -z "$PREFIX" ]]; then
        LIBOPUS_PREFIX="--prefix=$PREFIX"
    fi

    autoreconf -f -i && ./configure $LIBOPUS_PREFIX --enable-shared --disable-static && ${MAKE} || exit 1

    if [[ ! -z "$PREFIX" && -w "$PREFIX" ]]; then
        make install || exit 1
    else
        sudo make install || exit 1
    fi

    echo $PREFIX > ${WORKDIR}/$LIBOPUS_PACKAGE_NAME.prefix
}

install_libvpx()
{
    LIBVPX_PACKAGE_NAME=libvpx-1.7.0
    if check_cached_build $LIBVPX_PACKAGE_NAME; then
        return 0
    fi

    BUILD_PRG="LIBVPX"

    cd ${WORKDIR}

    if [ ! -d ${BUILD_PRG} ]; then
        curl -OLf https://chromium.googlesource.com/webm/libvpx/+archive/v1.7.0.tar.gz  || fail_exit ${BUILD_PRG}
        mkdir ${BUILD_PRG}
        tar xvfz v1.7.0.tar.gz -C ${WORKDIR}/${BUILD_PRG} && rm -rf v1.7.0.tar.gz
    fi

    cd ${BUILD_PRG}

    if [[ ! -z "$PREFIX" ]]; then
        LIBVPX_PREFIX="--prefix=$PREFIX"
    fi

    ADDITIONAL_FLAGS=
    if [ "x${OSNAME}" == "xMac OS X" ]; then
        case $OSVERSION in
            10.12.* | 10.13.* | 10.14.* ) ADDITIONAL_FLAGS=--target=x86_64-darwin16-gcc;;
        esac
    fi

    ./configure $LIBVPX_PREFIX $ADDITIONAL_FLAGS --enable-shared --disable-static --disable-examples && ${MAKE} || exit 1

    if [[ ! -z "$PREFIX" && -w "$PREFIX" ]]; then
        make install || exit 1
    else
        sudo make install || exit 1
    fi

    echo $PREFIX > ${WORKDIR}/$LIBVPX_PACKAGE_NAME.prefix
}

install_openssl()
{
    OPENSSL_PACKAGE_NAME=openssl-1.1.0g
    if check_cached_build $OPENSSL_PACKAGE_NAME; then
        return 0
    fi

    BUILD_PRG="OPENSSL"

    cd ${WORKDIR}

    OPENSSL_PACKAGE_DOWNLOAD_NAME=$OPENSSL_PACKAGE_NAME.tar.gz

    if [ ! -d ${BUILD_PRG} ]; then
        curl -OLf https://www.openssl.org/source/$OPENSSL_PACKAGE_DOWNLOAD_NAME  || fail_exit ${BUILD_PRG}
        tar xvfz $OPENSSL_PACKAGE_DOWNLOAD_NAME -C ${WORKDIR} && rm -rf $OPENSSL_PACKAGE_DOWNLOAD_NAME && mv openssl-* ${BUILD_PRG}
    fi

    cd ${BUILD_PRG}

    if [[ ! -z "$PREFIX" ]]; then
        OPENSSL_PREFIX="--prefix=$PREFIX --openssldir=$PREFIX"
    fi

    ./config $OPENSSL_PREFIX shared no-idea no-mdc2 no-rc5 no-ec2m no-ecdh no-ecdsa && ${MAKE} || exit 1

    if [[ ! -z "$PREFIX" && -w "$PREFIX" ]]; then
        make install || exit 1
    else
        sudo make install || exit 1
    fi

    echo $PREFIX > ${WORKDIR}/$OPENSSL_PACKAGE_NAME.prefix
}

install_ffmpeg()
{
    FFMPEG_PACKAGE_NAME=ffmpeg-3.4.2
    if check_cached_build $FFMPEG_PACKAGE_NAME; then
        return 0
    fi

    BUILD_PRG="FFMPEG"

    cd ${WORKDIR}

    if [ ! -d ${BUILD_PRG} ]; then
        curl -OLkf https://www.ffmpeg.org/releases/ffmpeg-3.4.2.tar.xz  || fail_exit ${BUILD_PRG}
        xz -d ffmpeg-3.4.2.tar.xz && tar xvf ffmpeg-3.4.2.tar -C ${WORKDIR} && rm -rf xvf ffmpeg-3.4.2.tar
        mv ffmpeg-3.4.2 ${BUILD_PRG}
    fi

    cd ${BUILD_PRG}

    if [[ ! -z "$PREFIX" ]]; then
        FFMPEG_PREFIX="--prefix=$PREFIX"
    fi

    ./configure \
        $FFMPEG_PREFIX \
        --disable-static --enable-shared \
        --extra-libs=-ldl \
        --enable-ffprobe \
        --disable-ffplay --disable-ffserver --disable-filters --disable-vaapi --disable-avdevice --disable-doc --disable-symver \
        --disable-debug --disable-indevs --disable-outdevs --disable-devices --disable-hwaccels --disable-encoders \
        --enable-zlib --enable-libopus --enable-libvpx --enable-libfdk_aac \
        --enable-encoder=libvpx_vp8,libvpx_vp9,libopus,libfdk_aac \
        --disable-decoder=tiff \
        --enable-filter=asetnsamples,aresample,aformat,channelmap,channelsplit,scale,transpose,fps,settb,asettb && ${MAKE} || exit 1

    if [[ ! -z "$PREFIX" && -w "$PREFIX" ]]; then
        make install || exit 1
    else
        sudo make install || exit 1
    fi

    echo $PREFIX > ${WORKDIR}/$FFMPEG_PACKAGE_NAME.prefix
}

install_libopenh264()
{
    BUILD_PRG="OPENH264"

    cd ${WORKDIR}


    if [ "x${OSNAME}" == "xMac OS X" ]; then
        LIBRARY_EXTENSION=dylib
        OPENH264_BINARY_NAME="libopenh264-1.8.0-osx64.4.dylib"
    else
        LIBRARY_EXTENSION=so
        OPENH264_BINARY_NAME="libopenh264-1.8.0-linux64.4.so"
    fi

    OPENH264_PACKAGE_NAME="${OPENH264_BINARY_NAME}.bz2"

    curl -OLf http://ciscobinary.openh264.org/${OPENH264_PACKAGE_NAME}  || fail_exit ${BUILD_PRG}

    bzip2 -d ${OPENH264_PACKAGE_NAME}

    if [[ ! -z "$PREFIX" ]]; then
        DESTINATION="${PREFIX}/lib"
    else
        DESTINATION=/usr/lib
    fi

    if [[ -w "$DESTINATION" ]]; then
        mv ${OPENH264_BINARY_NAME} ${DESTINATION} \
        && chmod a+x ${DESTINATION}/${OPENH264_BINARY_NAME} \
        && ln -sf ${DESTINATION}/${OPENH264_BINARY_NAME} ${DESTINATION}/libopenh264.${LIBRARY_EXTENSION} \
        && ln -sf ${DESTINATION}/${OPENH264_BINARY_NAME} ${DESTINATION}/libopenh264.4.${LIBRARY_EXTENSION} \
        || exit 1
    else
        sudo mv ${OPENH264_BINARY_NAME} ${DESTINATION} \
        && sudo chmod a+x ${DESTINATION}/${OPENH264_BINARY_NAME} \
        && sudo ln -sf ${DESTINATION}/${OPENH264_BINARY_NAME} ${DESTINATION}/libopenh264.${LIBRARY_EXTENSION} \
        && sudo ln -sf ${DESTINATION}/${OPENH264_BINARY_NAME} ${DESTINATION}/libopenh264.4.${LIBRARY_EXTENSION} \
        || exit 1
    fi
}

install_base_ubuntu()
{
    PKGS="build-essential nasm autoconf libtool zlib1g-dev libssl-dev libvpx-dev libopus-dev pkg-config libfdk-aac-dev \
tclsh cmake curl"
    for PKG in ${PKGS}; do
        sudo apt install -y ${PKG} || fail_exit ${PKG}
    done
}

install_base_fedora()
{
    PKGS="gcc-c++ make nasm autoconf libtool zlib-devel openssl-devel libvpx-devel opus-devel tcl cmake"
    for PKG in ${PKGS}; do
        sudo yum install -y ${PKG} || fail_exit ${PKG}
    done

    export PKG_CONFIG_PATH=\${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig
    export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/usr/local/lib:/usr/local/lib64
}

install_base_centos()
{
    PKGS="centos-release-scl bc gcc-c++ nasm autoconf libtool glibc-static zlib-devel git bzip2 tcl cmake devtoolset-7"
    for PKG in ${PKGS}; do
        sudo yum install -y ${PKG} || fail_exit ${PKG}
    done

    source scl_source enable devtoolset-7

    export PKG_CONFIG_PATH=\${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig
    export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/usr/local/lib:/usr/local/lib64
}

install_base_macos()
{
    BREW_PATH=$(which brew)
    if [ ! -x "$BREW_PATH" ] ; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 1
    fi

    brew install pkg-config nasm automake libtool xz cmake

    export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
    export PATH=/usr/local/bin:$PATH
}

fail_exit()
{
    echo "Software ($1) download failed."
    cd ${CURRENT}
    exit 1
}

check_version()
{
    if [[ "x${OSNAME}" == "xUbuntu" && "x${OSVERSION}" != "x18" ]]; then
        proceed_yn
    fi

    if [[ "x${OSNAME}" == "xCentOS Linux" && "x${OSVERSION}" != "x7" ]]; then
        proceed_yn
    fi

    if [[ "x${OSNAME}" == "xFedora" && "x${OSVERSION}" != "x28" ]]; then
        proceed_yn
    fi
}

proceed_yn()
{
    read -p "This program [$0] is tested on [Ubuntu 18, CentOS 7, Fedora 28]
Do you want to continue [y/N] ? " ANS
    if [[ "x${ANS}" != "xy" && "x$ANS" != "xyes" ]]; then
        cd ${CURRENT}
        exit 1
    fi
}

mkdir -p ${WORKDIR}

if [[ ! -z ${PREFIX} && ! -d ${PREFIX} ]]; then
    mkdir -p ${PREFIX}
fi

if [ "x${OSNAME}" == "xUbuntu" ]; then

    check_version

    install_base_ubuntu

    install_libsrtp

    install_libopenh264

    install_libsrt

    install_ffmpeg

    sudo ldconfig
elif  [ "x${OSNAME}" == "xCentOS Linux" ]; then

    check_version

    install_base_centos

    install_openssl

    install_libvpx

    install_libopus

    install_libsrtp

    install_fdk_aac

    install_ffmpeg

    install_libopenh264

    install_libsrt

    sudo ldconfig
elif  [ "x${OSNAME}" == "xFedora" ]; then

    check_version

    install_base_fedora

    install_libsrtp

    install_fdk_aac

    install_ffmpeg

    install_libopenh264

    install_libsrt

    sudo ldconfig
elif  [ "x${OSNAME}" == "xMac OS X" ]; then

    PREFIX=$WORKDIR/prerequisites

    mkdir -p $PREFIX

    install_base_macos

    check_version

    install_openssl

    install_libvpx

    install_libopus

    install_libsrtp

    install_fdk_aac

    install_ffmpeg

    install_libsrt

    install_libopenh264
else
    echo "This program [$0] does not support your operating system [${OSNAME}]"
    echo "Please refer to manual installation page"
fi

cd ${CURRENT}