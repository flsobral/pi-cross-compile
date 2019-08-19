FROM ubuntu:16.04

MAINTAINER Mitch Allen "docker@mitchallen.com"

# USAGE: docker run -it -v ~/raspberry/hello:/build mitchallen/pi-cross-compile

LABEL com.mitchallen.pi-cross-compile="{\"Description\":\"Cross Compile for Raspberry Pi\",\"Usage\":\"docker run -it -v ~/myprojects/mybuild:/build mitchallen/pi-cross-compile\",\"Version\":\"0.1.0\"}"

RUN apt-get update && apt-get install -y git && apt-get install -y build-essential

RUN git clone --progress --verbose https://github.com/raspberrypi/tools.git --depth=1 pitools

RUN git clone https://github.com/WiringPi/WiringPi.git
#git://git.drogon.net/wiringPi

RUN apt-get install -y sudo

RUN cd WiringPi && ./build

RUN cd /WiringPi/wiringPi && sudo make install

ENV BUILD_FOLDER /build

WORKDIR ${BUILD_FOLDER}

CMD ["/bin/bash", "-c", "make", "-f", "${BUILD_FOLDER}/Makefile"]
# CMD ["make", "clean"]
