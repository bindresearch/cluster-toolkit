# --- Stage 1: Build stage ---
FROM nvidia/cuda:12.3.2-devel-ubuntu22.04 AS builder

# Install dependencies for build
RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl unzip \
    libfftw3-dev libgsl-dev \
    openmpi-bin libopenmpi-dev \
    libboost-all-dev \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Get sources
RUN wget ftp://ftp.gromacs.org/gromacs/gromacs-2024.5.tar.gz && tar -xzf gromacs-2024.5.tar.gz
RUN git clone https://github.com/plumed/plumed2.git

# Build and install PLUMED
RUN cd /opt/plumed2 && \
    ./configure --prefix=/opt/plumed-install --enable-mpi && \
    make -j$(nproc) && \
    make install

ENV PATH=/opt/plumed-install/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/plumed-install/lib:$LD_LIBRARY_PATH

# Patch GROMACS with PLUMED
RUN cd /opt/gromacs-2024.5 && \
    plumed patch -p --runtime -e gromacs-2024.3

# Build and install GROMACS
RUN mkdir /opt/gromacs-2024.5/build && cd /opt/gromacs-2024.5/build && \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=/opt/gromacs-install \
    -DGMX_MPI=ON \
    -DGMX_GPU=CUDA \
    -DGMX_BUILD_OWN_FFTW=ON \
    -DGMX_DOUBLE=OFF \
    -DGMX_PLUMED=ON \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_CXX_COMPILER=mpicxx && \
    make -j$(nproc) && \
    make install


# --- Stage 2: Runtime stage ---
FROM nvidia/cuda:12.3.2-runtime-ubuntu22.04

LABEL maintainer="candide.champion@bindresearch.org"

RUN apt-get update && apt-get install -y \
    libgsl27 libfftw3-single3 libboost-program-options1.74.0 \
    openmpi-bin libopenmpi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy only the final installs
COPY --from=builder /opt/plumed-install /usr/local/plumed
COPY --from=builder /opt/gromacs-install /usr/local/gromacs

ENV PATH=/usr/local/plumed/bin:/usr/local/gromacs/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/plumed/lib:$LD_LIBRARY_PATH

# Source GMXRC for convenience
RUN echo "source /usr/local/gromacs/bin/GMXRC" >> /root/.bashrc

WORKDIR /root

CMD ["/bin/bash"]
