FROM ubuntu:bionic

# This determines what <SOC> gets filled in in the nvidia apt sources list:
# valid choices: t210, t186, t194
ARG SOC="t210"
# because Nvidia has no keyserver for Tegra currently, we DL the whole BSP tarball, just for the apt key.
ARG BSP_URI="https://developer.nvidia.com/embedded/dlc/r32-3-1_Release_v1.0/t210ref_release_aarch64/Tegra210_Linux_R32.3.1_aarch64.tbz2"
ARG BSP_SHA512="13c4dd8e6b20c39c4139f43e4c5576be4cdafa18fb71ef29a9acfcea764af8788bb597a7e69a76eccf61cbedea7681e8a7f4262cd44d60cefe90e7ca5650da8a"

WORKDIR /tmp
# install apt key and configure apt sources
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
    && BSP_SHA512_ACTUAL="$(wget --https-only -nv --show-progress --progress=bar:force:noscroll -O- ${BSP_URI} | tee bsp.tbz2 | sha512sum -b | cut -d ' ' -f 1)" \
    && [ ${BSP_SHA512_ACTUAL} = ${BSP_SHA512} ] \
    && echo "Extracting bsp.tbz2" \
    && tar --no-same-permissions -xjf bsp.tbz2 \
    && cp Linux_for_Tegra/nv_tegra/jetson-ota-public.key /etc/apt/trusted.gpg.d/jetson-ota-public.asc \
    && chmod 644 /etc/apt/trusted.gpg.d/jetson-ota-public.asc \
    && echo "deb https://repo.download.nvidia.com/jetson/common r32 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && echo "deb https://repo.download.nvidia.com/jetson/${SOC} r32 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && rm -rf * \
    && apt-get purge -y --autoremove \
        wget \
    && rm -rf /var/lib/apt/lists/*
# leaving ca-certificates because otherwise https sources like nvidia's will complain on apt-get.
