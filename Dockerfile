FROM nvidia/cuda:10.2-devel-ubuntu18.04

# Get apt dependencies
RUN apt-get update && apt-get install -y  \
    sudo clang-format wget apt-utils \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev \
    wget build-essential checkinstall pkg-config yasm git \
    gfortran libjpeg8-dev libpng-dev libtiff5-dev libavcodec-dev libavformat-dev \
    libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev libavcodec-dev libavformat-dev libswscale-dev \
    qt5-default libgtk2.0-dev libtbb-dev libatlas-base-dev \
    libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libopencore-amrnb-dev \
    libopencore-amrwb-dev x264 v4l-utils libprotobuf-dev protobuf-compiler libgoogle-glog-dev \
    libgflags-dev libgphoto2-dev libeigen3-dev libhdf5-dev doxygen software-properties-common &&\
    rm -rf /var/lib/apt/lists/*


## Install CMake and Python3.6
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg software-properties-common wget && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
    apt-get update && apt-get install -y cmake python3 python3-dev python3-pip & \
    rm -rf /var/lib/apt/lists/*


## Install Python packages
RUN python -m pip install --upgrade pip
RUN python -m pip install --upgrade setuptools wheel twine keyring keyrings.alt


# Install Opencv 4.1.2 + contrib + cuda
RUN wget https://github.com/opencv/opencv/archive/4.3.0.tar.gz -O /opt/core.tar.gz &&\
    wget https://github.com/opencv/opencv_contrib/archive/4.3.0.tar.gz -O opt/contrib.tar.gz &&\
    cd /opt && tar -xvf core.tar.gz &&\
    cd /opt && tar -xvf contrib.tar.gz &&\
    rm -rf /opt/core.tar.gz /opt/contrib.tar.gz

RUN cd /opt && mkdir -p opencv-4.3.0/build &&\
    cd /opt/opencv-4.3.0/build &&\
    cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D WITH_CUDA=ON \
    -D WITH_TBB=ON \
    -D WITH_V4L=ON \
    -D WITH_QT=ON \
    -D WITH_OPENGL=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_WEBP=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D BUILD_JAVA=OFF \
    -D BUILD_NEW_PYTHON_SUPPORT=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D CUDA_NVCC_FLAGS="--expt-relaxed-constexpr" \
    -D OPENCV_EXTRA_MODULES_PATH="../../opencv_contrib-4.3.0/modules" \
    .. &&\
    cd /opt/opencv-4.3.0/build && make -j 2 install &&\
    rm -rf /opt/opencv-4.3.0/build
