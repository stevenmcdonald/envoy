FROM debian:11.6 as java-inter
LABEL stage=java-inter

RUN echo 'quiet "1";' \
       'APT::Install-Recommends "0";' \
       'APT::Install-Suggests "0";' \
       'APT::Acquire::Retries "20";' \
       'APT::Get::Assume-Yes "true";' \
       'Dpkg::Use-Pty "0";' \
      > /etc/apt/apt.conf.d/99gitlab

RUN apt update && LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive apt upgrade

ADD https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u362-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u362b09.tar.gz /

# openjdk-8
# From: https://adoptium.net/temurin/releases/
RUN /bin/tar zxvf OpenJDK8U-jdk_x64_linux_hotspot_8u362b09.tar.gz && rm OpenJDK8U-jdk_x64_linux_hotspot_8u362b09.tar.gz



################
# real container
FROM debian:11.6

LABEL org.opencontainers.image.authors="scm@eds.org"
LABEL description="Build environment for GreatFire Envoy https://github.com/greatfire/envoy"

RUN echo Etc/UTC > /etc/timezone
RUN echo 'quiet "1";' \
       'APT::Install-Recommends "0";' \
       'APT::Install-Suggests "0";' \
       'APT::Acquire::Retries "20";' \
       'APT::Get::Assume-Yes "true";' \
       'Dpkg::Use-Pty "0";' \
      > /etc/apt/apt.conf.d/99gitlab

RUN apt update && LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive apt upgrade

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199#23 
#RUN mkdir -p /usr/share/man/man1
RUN LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive apt install \
	build-essential \
	curl \
	ccache \
	file \
	git \
	lsb-release \
	ninja-build \
	procps \
	python3 \
	python3-requests \
	sudo \
	vim-nox


RUN mkdir /build
COPY chromium-build /build/chromium-build

ENV CHROMIUM_SRC_ROOT=/build/chromium/src 
ENV DEPOT_TOOLS_ROOT=/build/depot_tools
ENV DEPOT_TOOLS_UPDATE=0

RUN LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive /build/chromium-build/install-build-deps-android.sh

WORKDIR /build

RUN git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git

# copy Java from intermediate container
COPY --from=java-inter /jdk8u362-b09 .

ENV CCACHE_BASEDIR=/build/.ccache
ENV CCACHE_SLOPPINESS=time_macros


ENV JAVA_HOME=/build/jdk8u362-b09/
ENV PATH=/build/jdk8u362-b09/bin:$PATH:$DEPOT_TOOLS_ROOT
ENV ANDROID_SDK_ROOT=/opt/android-sdk

RUN git clone --depth=1 --branch=0.4 https://gitlab.com/fdroid/sdkmanager.git
RUN cd sdkmanager && git checkout -B master b5a5640fc4cdc151696b2d27a5886119ebd3a8b7
RUN ./sdkmanager/sdkmanager.py tools "ndk;21.0.6113669" "platforms;android-29"
RUN yes | /build/sdkmanager/sdkmanager.py --licenses

COPY docker .

# create a normal user
RUN groupadd --gid 1000 build && useradd -ms /bin/bash --uid 1000 --gid 1000 build
# let that user sudo with no password
RUN echo "build ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/build

USER build

CMD ["/build/start.sh"]

