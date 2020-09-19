FROM ubuntu:latest

ENV HOME="/root"

# set timezone info so apt can run without prompts
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install build dependencies and clone the flutter repo
RUN cd $HOME && apt update && \
    apt install -y clang cmake ninja-build libblkid-dev unzip pkg-config build-essential wget curl git unzip xz-utils zip libglu1-mesa libxcursor1 libxinerama1 libxrandr2 rsync libgtk-3-dev && \
    git clone https://github.com/flutter/flutter.git

# set up flutter
ENV PATH="/root/flutter/bin:${PATH}"
RUN flutter config --enable-linux-desktop && \
    flutter upgrade

CMD ["bash"]
