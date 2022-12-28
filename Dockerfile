# Copyright © 2001 by the Rectors and Visitors of the University of Virginia. 
FROM androidsdk/android-30
LABEL org.opencontainers.image.description "Underlying environment for UVA's MoralPain project"

# Update and configure Ubuntu 
RUN apt-get clean && apt-get update -y && apt-get upgrade -y
RUN apt-get install -y locales && locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Use bash rather than sh to RUN commands in this Dockerfile
SHELL ["/bin/bash", "-c"]

WORKDIR /opt

# ENV DEBIAN_FRONTEND=noninteractive
# ENV FRONTEND=noninteractive
# RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Basic dependencies
RUN apt-get update && apt-get -y install lsb-release build-essential git vim wget gnupg \
    curl libssl-dev libffi-dev libconfig-dev zip unzip git-lfs pkg-config 

# Python3
RUN apt-get update && apt-get -y install python3.8 python3.8-distutils python3-pip python3-venv python3-dev 
RUN apt-get update --fix-missing
ENV PYTHONIOENCODING utf-8
RUN python3 -m pip install pipx
RUN python3 -m pipx ensurepath --force 
RUN . ~/.profile


# Libraries needed by VSCode.
ADD https://aka.ms/vsls-linux-prereq-script /opt
RUN chmod 700 vsls-linux-prereq-script && \
    ./vsls-linux-prereq-script && \
    rm vsls-linux-prereq-script

# Flutter and Dart.
ARG FLUTTER_VERSION=3.0.0
ADD https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz /opt
RUN tar xJvf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
ENV PATH="/opt/flutter/bin:${PATH}"
RUN git config --global --add safe.directory /opt/flutter 
RUN flutter doctor

# AWS Sceptre
# Required markupsafe but >=2.0 breaks lots of stuff
RUN python3.8 -m pip install MarkupSafe==1.1.1   
RUN python3.8 -m pip install sceptre

# AWS Cli.
ADD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip /opt/awscliv2.zip
RUN unzip awscliv2.zip && ./aws/install && rm -r aws awscliv2.zip

# AWS SAM.
ADD https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip /opt
RUN unzip aws-sam-cli-linux-x86_64.zip -d sam-installation && \
    ./sam-installation/install && \
    rm aws-sam-cli-linux-x86_64.zip

# Get dependencies
RUN apt-get -y install software-properties-common apt-transport-https
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 8F3DA4B5E9AEF44C


WORKDIR /root  
# COPY .devcontainer/.profile.txt /root/.profile
VOLUME /hostdir

# Install Lean
RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y 
ENV LEAN_PATH /root/.elan/toolchains/stable/lib/lean/library:/root/.lean/_target/deps/mathlib/src
ENV PATH=/root/.elan/bin:${PATH}
RUN pipx install mathlibtools
RUN echo `ls /root/.local/bin/`
RUN /root/.local/bin/leanproject global-install
RUN /root/.local/bin/leanproject upgrade-mathlib

# Java package manager (sdkman)
RUN curl "https://get.sdkman.io" | bash
RUN chmod a+x "$HOME/.sdkman/bin/sdkman-init.sh"
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && \
  sdk install gradle 7.5 && \
  sdk install maven && \
  sdk install java 11.0.17-amzn

#RUN /root/.local/bin/leanproject get-mathlib-cache
#RUN /root/.local/bin/leanproject build
# RUN /root/.local/bin/leanproject import-graph project_structure.dot

# Install libraries needed by VSCode  
# - support joining sessions using a browser link 
RUN wget -O ~/vsls-reqs https://aka.ms/vsls-linux-prereq-script && chmod +x ~/vsls-reqs && ~/vsls-reqs

# Install TypeDB.
RUN add-apt-repository 'deb [ arch=all ] https://repo.vaticle.com/repository/apt/ trusty main'
RUN apt update
RUN apt-get -y install \
  typedb-all=2.11.0 \
  typedb-server=2.11.0 \
  typedb-bin=2.9.0 \
  typedb-console=2.11.0

COPY bin /opt/

ENTRYPOINT ["flutter"]
CMD ["doctor"]
