FROM ubuntu:20.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  git \
  openjdk-11-jdk \
  unzip \
  xz-utils \
  zip \
  && rm -rf /var/lib/apt/lists/*

ENV ANDROID_SDK_ROOT=/opt/android-sdk

ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
  && cd ${ANDROID_SDK_ROOT}/cmdline-tools \
  && curl -O https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip \
  && unzip commandlinetools*.zip \
  && mv cmdline-tools latest \
  && rm commandlinetools*.zip \
  && yes | sdkmanager --licenses \
  && sdkmanager 'platform-tools' 'platforms;android-30' 'build-tools;30.0.3'

ENV PATH ${PATH}:/opt/flutter/bin
# Make the default match non-root users
ENV TAR_OPTIONS --no-same-owner

RUN cd /opt \
  && curl -O https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.6-stable.tar.xz \
  && tar -xf flutter*.tar.xz \
  && rm flutter*.tar.xz \
  && flutter doctor \
  && chmod -R a+w flutter

# TODO: flutter precache


ENV NVM_DIR /opt/nvm
RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

RUN ln -s $NVM_DIR/nvm.sh /etc/profile.d/50-nvm.sh

ENV NODE_VERSION 14
RUN bash -c ". $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION"

RUN bash -c ". $NVM_DIR/nvm.sh \
    && npm install --global http-server"
