FROM ubuntu:latest

ENV HOME="/root"

RUN cd $HOME && apt update && \
    apt install -y clang unzip pkg-config build-essential wget curl git unzip xz-utils zip libglu1-mesa libxcursor1 libxinerama1 libxrandr2 rsync libgtk-3-dev && \
    git clone https://github.com/flutter/flutter.git

ENV PATH="/root/flutter/bin:${PATH}"

RUN flutter config --enable-linux-desktop && \
    flutter upgrade

CMD ["bash"]
