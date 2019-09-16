FROM ubuntu:16.04

MAINTAINER Mitch Allen "docker@mitchallen.com"

# USAGE: docker run -it -v ~/raspberry/hello:/build mitchallen/pi-cross-compile

LABEL com.mitchallen.pi-cross-compile="{\"Description\":\"Cross Compile for Raspberry Pi\",\"Usage\":\"docker run -it -v ~/myprojects/mybuild:/build mitchallen/pi-cross-compile\",\"Version\":\"0.1.0\"}"

RUN apt-get update && apt-get install -y git && apt-get install -y build-essential && apt-get install -y sudo debootstrap qemu-user-static schroot


#RUN apt-get install -y g++-arm-linux-gnueabihf
RUN apt-get install -y python
#RUN apt-get install -y libglib2.0-dev

#RUN apt-get install -y debootstrap qemu-user-static schroot g++-arm-linux-gnueabihf libglib2.0-dev

# Installing clang-3.8
RUN echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.8 main" >> /etc/apt/sources.list
#RUN wget -qO - https://raw.githubusercontent.com/yarnpkg/releases/gh-pages/debian/pubkey.gpg | apt-key add -
RUN wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add -
RUN apt-get update
RUN apt-get install -y clang-3.8	
#RUN apt -q -y --force-yes install gcc-multilib g++-multilib

RUN git clone https://github.com/terwoord/skiasharp-raspberry.git

RUN cd skiasharp-raspberry && ./build.sh

##############################################################################
ENV BUILD_FOLDER /build

WORKDIR ${BUILD_FOLDER}

CMD ["/bin/bash", "-c", "make", "-f", "${BUILD_FOLDER}/Makefile"]
# CMD ["make", "clean"]
