FROM ubuntu:16.04

MAINTAINER Mitch Allen "docker@mitchallen.com"

# USAGE: docker run -it -v ~/raspberry/hello:/build mitchallen/pi-cross-compile

LABEL com.mitchallen.pi-cross-compile="{\"Description\":\"Cross Compile for Raspberry Pi\",\"Usage\":\"docker run -it -v ~/myprojects/mybuild:/build mitchallen/pi-cross-compile\",\"Version\":\"0.1.0\"}"

RUN apt-get update && apt-get install -y git && apt-get install -y build-essential && apt-get install -y wget

RUN wget https://developer1.toradex.com/files/toradex-dev/uploads/media/Colibri/Linux/SDKs/2.8/colibri-imx7/angstrom-lxde-image/angstrom-glibc-x86_64-armv7at2hf-neon-v2017.12-toolchain.sh

RUN chmod +x angstrom-glibc-x86_64-armv7at2hf-neon-v2016.12-toolchain.sh 

#&& ./angstrom-glibc-x86_64-armv7at2hf-neon-v2016.12-toolchain.sh

##############################################################################
ENV BUILD_FOLDER /build

WORKDIR ${BUILD_FOLDER}

CMD ["/bin/bash", "-c", "make", "-f", "${BUILD_FOLDER}/Makefile"]
# CMD ["make", "clean"]
