FROM ubuntu:16.04

MAINTAINER Mitch Allen "docker@mitchallen.com"

# USAGE: docker run -it -v ~/raspberry/hello:/build mitchallen/pi-cross-compile

LABEL com.mitchallen.pi-cross-compile="{\"Description\":\"Cross Compile for Raspberry Pi\",\"Usage\":\"docker run -it -v ~/myprojects/mybuild:/build mitchallen/pi-cross-compile\",\"Version\":\"0.1.0\"}"

RUN apt-get update && apt-get install -y git && apt-get install -y build-essential

RUN git clone --progress --verbose https://github.com/raspberrypi/tools.git --depth=1 pitools

RUN git clone 'https://chromium.googlesource.com/chromium/tools/depot_tools.git'
RUN export PATH="${PWD}/depot_tools:${PATH}"

RUN apt-get install -y python

RUN apt-get install wget

RUN wget https://github.com/ninja-build/ninja/archive/v1.7.2.tar.gz -O - | tar -xz && cd ninja-1.7.2 && ./configure.py --bootstrap && ./configure.py && ./ninja ninja_test && ./ninja_test --gtest_filter=-SubprocessTest.SetWithLots

RUN git clone https://skia.googlesource.com/skia.git
# or
# fetch skia
RUN cd skia && git fetch origin chrome/m71 && git checkout chrome/m71 && python tools/git-sync-deps && bin/gn gen out/arm64  --args='is_official_build=true skia_use_expat=false skia_use_libjpeg_turbo=false skia_use_libpng=true skia_use_libwebp=false skia_use_zlib=false' 

RUN cd skia && ../ninja-1.7.2/./ninja -C out/arm64

#RUN git clone https://github.com/WiringPi/WiringPi.git
#git://git.drogon.net/wiringPi

#RUN apt-get install -y sudo

#RUN cd WiringPi && ./build

#RUN cd /WiringPi/wiringPi && sudo make install

ENV BUILD_FOLDER /build

WORKDIR ${BUILD_FOLDER}

CMD ["/bin/bash", "-c", "make", "-f", "${BUILD_FOLDER}/Makefile"]
# CMD ["make", "clean"]
