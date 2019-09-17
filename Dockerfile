FROM ubuntu:16.04

MAINTAINER Mitch Allen "docker@mitchallen.com"

# USAGE: docker run -it -v ~/raspberry/hello:/build mitchallen/pi-cross-compile

LABEL com.mitchallen.pi-cross-compile="{\"Description\":\"Cross Compile for Raspberry Pi\",\"Usage\":\"docker run -it -v ~/myprojects/mybuild:/build mitchallen/pi-cross-compile\",\"Version\":\"0.1.0\"}"

RUN apt-get update && apt-get install -y git && apt-get install -y build-essential

# check out skia and depot_tools as per https://github.com/mono/SkiaSharp/wiki/Building-on-Linux
RUN git clone https://github.com/mono/skia.git -b v1.68.0-preview28
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

# check out RPI compilers as per https://github.com/mono/SkiaSharp/issues/633#issuecomment-420025558 and add to path
RUN git clone https://github.com/raspberrypi/tools.git --depth=1 pitools


# installed libfontconfig on my RPI and then copied
# fcfreetype.h,  fcprivate.h and  fontconfig.h
# to
# <path-to-rpi-checkout>/tools/arm-bcm2708/arm-linux-gnueabihf/arm-linux-gnueabihf/include/fontconfig

# copied
# libfontconfig.a  libfontconfig.so  libfontconfig.so.1  libfontconfig.so.1.8.0
# to
# <path-to-rpi-checkout>/tools/arm-bcm2708/arm-linux-gnueabihf/arm-linux-gnueabihf/lib

# would it be possible to avoid the copy steps by installing libfontconfig:armhf directly on the build machine? I tried but couldn't get it to install

# change to skia directory - all work done here from now on
#RUN cd skia

RUN apt-get install -y python

# run git-sync-deps script (as per normal instructions)
RUN export PATH="$PATH:/pitools/arm-bcm2708/arm-linux-gnueabihf/bin" && cd skia && python tools/git-sync-deps

RUN dpkg --add-architecture armhf && apt-get update && apt-get install -y libfontconfig1-dev build-essential crossbuild-essential-armhf

# modified command line to use ARM cross-compilers from the RPI tools
RUN export PATH="$PATH:/pitools/arm-bcm2708/arm-linux-gnueabihf/bin" && cd skia && \
./bin/gn gen 'out/linux/x64' --args=' \
    cc = "arm-linux-gnueabihf-gcc" \
    cxx = "arm-linux-gnueabihf-g++" \
    is_official_build=true skia_enable_tools=false \
    target_os="linux" target_cpu="arm" \
    skia_use_icu=false skia_use_sfntly=false skia_use_piex=true \
    skia_use_system_expat=false skia_use_system_freetype2=false  \
    skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false \
    skia_use_system_libwebp=false skia_use_system_zlib=false \
    skia_enable_gpu=true \
    extra_cflags=[ "-DSKIA_C_DLL", "-I/usr/include/" ] \
    linux_soname_version="68.0.0"'

# compile
RUN export PATH="$PATH:/pitools/arm-bcm2708/arm-linux-gnueabihf/bin" && cd skia && ../depot_tools/ninja 'SkiaSharp' -C 'out/linux/x64'

##############################################################################
ENV BUILD_FOLDER /build

WORKDIR ${BUILD_FOLDER}

CMD ["/bin/bash", "-c", "make", "-f", "${BUILD_FOLDER}/Makefile"]
# CMD ["make", "clean"]
