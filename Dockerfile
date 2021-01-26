# MIT License

# Copyright (c) 2020 Michael de Gans

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM nvcr.io/nvidia/l4t-base:r32.4.4

# This determines what <SOC> gets filled in in the nvidia apt sources list:
# valid choices: t210, t186, t194
ARG SOC="t194"

WORKDIR /tmp
# install apt key and configure apt sources
#ADD --chown=root:root https://repo.download.nvidia.com/jetson/jetson-ota-public.asc /etc/apt/trusted.gpg.d/jetson-ota-public.asc
RUN sed 's#ports.ubuntu.com#mirrors.aliyun.com#g' /etc/apt/sources.list -i && \
    echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy && \
    echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy && \
# leaving ca-certificates because otherwise https sources like nvidia's will complain on apt-get.
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget http://172.17.0.1:9000/repo.download.nvidia.com/jetson/jetson-ota-public.asc -O /etc/apt/trusted.gpg.d/jetson-ota-public.asc \
    && chmod 644 /etc/apt/trusted.gpg.d/jetson-ota-public.asc \
    && echo "deb http://172.17.0.1:9000/cn-repo.download.nvidia.com/jetson/common r32.4 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && echo "deb http://172.17.0.1:9000/cn-repo.download.nvidia.com/jetson/${SOC} r32.4 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && apt-get update && \
    mkdir -p /opt/nvidia/l4t-packages/ && \
    touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall

RUN apt install -y libcudnn8
RUN apt install -y nvidia-cudnn8

RUN apt install -y libnvinfer-dev
RUN apt install -y libnvinfer-samples

RUN apt install -y cuda-cufft-dev* cuda-curand-dev*
RUN apt install -y cuda-cusparse-dev* cuda-cusolver-dev*
RUN apt install -y cuda-npp-dev* cuda-nvgraph-dev*
RUN apt install -y nvidia-cuda

RUN echo Y|apt install -y nvidia-l4t-jetson-multimedia-api
RUN apt install -y nvidia-jetpack
