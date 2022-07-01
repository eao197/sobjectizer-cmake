FROM ubuntu:22.04

# Prepare build environment
RUN apt-get update && \
    apt-get -qq -y install gcc g++ \
    wget pkg-config \
    libtool \
    cmake

ARG so_version=5.7.4.1

RUN echo "*** Downloading SObjectizer ***" \
	&& cd /tmp \
	&& mkdir so-build-dir \
	&& cd so-build-dir \
	&& wget -O so-$so_version.tar.xz https://github.com/Stiffstream/sobjectizer/releases/download/v.5.7.4.1/so-5.7.4.1.tar.xz \
	&& tar xf so-$so_version.tar.xz

RUN echo "*** Building SObjectizer ***" \
	&& cd /tmp/so-build-dir/so-$so_version/dev \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DSOBJECTIZER_BUILD_SHARED=ON \
			-DSOBJECTIZER_BUILD_STATIC=OFF \
			-DBUILD_ALL=OFF \
			-DCMAKE_INSTALL_PREFIX=/tmp/libs \
			.. \
	&& cmake --build . --config Release --target install

RUN echo "*** Preparing hello_world source code ***" \
	&& cd /tmp \
	&& mkdir hello_world_example \
	&& mkdir hello_world_example/hello_world

COPY CMakeLists.txt /tmp/hello_world_example
COPY hello_world /tmp/hello_world_example/hello_world

RUN echo "*** Building hello_world  ***" \
	&& cd /tmp/hello_world_example \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_PREFIX_PATH=/tmp/libs \
			-DCMAKE_INSTALL_PREFIX=../target .. \
	&& cmake --build . --config Release --target install

RUN echo "*** Running the example ***" \
	&& LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tmp/libs/lib /tmp/hello_world_example/target/bin/sample.so_5.hello_world


