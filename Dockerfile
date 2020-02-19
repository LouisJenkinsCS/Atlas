FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install -y apt-utils
# For some reason requires LLVM 10 due to '#include<new>' header
# not being found, despite the fact that its using the same LLVM base...
RUN apt-get install -y llvm-10 clang-10
# Needed for testing...
RUN apt-get install -y ruby libboost-dev
# Symlink because everything has suffix `-10`
RUN ln -s /usr/bin/llvm-config-10 /usr/bin/llvm-config
RUN ln -s /usr/bin/clang++-10 /usr/bin/clang++ 
RUN ln -s /usr/bin/clang-10 /usr/bin/clang 
# Needed to build
RUN apt-get install -y wget tar cmake

# Setup and create user
RUN useradd -ms /bin/bash Atlas
USER Atlas
WORKDIR /home/Atlas

# Pull Custom Image...
RUN wget https://github.com/LouisJenkinsCS/Atlas/archive/Atlas-LLVM-Fix.tar.gz -O Atlas.tar.gz
RUN tar -xzvf Atlas.tar.gz
# Rename
RUN mv Atlas-Atlas-LLVM-Fix Atlas
WORKDIR Atlas
# Build compiler plugin
RUN cd compiler-plugin && ./build_plugin
WORKDIR runtime
RUN mkdir Atlas-Build
WORKDIR Atlas-Build
# Build runtime
RUN cmake ../ && make
ENV PATH="/home/Atlas/Atlas/runtime/Atlas-Build/tools/:${PATH}"
LABEL Name="HewlettPackard/ATLAS" Version=0.0.1
CMD [ "/bin/bash" ] 