FROM nvidia/cuda:12.3.2-devel-ubuntu22.04

LABEL maintainer="candide.champion@bindresearch.org"

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential cmake git wget curl unzip \
    libfftw3-dev libgsl-dev \
    openmpi-bin libopenmpi-dev \
    libboost-all-dev \
    python3 python3-pip \
    vim nano \
    && rm -rf /var/lib/apt/lists/*

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Copy your source directories (assumes they are in the same directory as the Dockerfile)
# I obtained those from the following: (TODO: edit the copy commands to download inside the container directly)
# wget ftp://ftp.gromacs.org/gromacs/gromacs-2024.5.tar.gz
# git clone git@github.com:plumed/plumed2.git
# COPY gromacs-2024.5 /opt/gromacs-2024.5
# COPY plumed2 /opt/plumed2

WORKDIR /opt

RUN wget ftp://ftp.gromacs.org/gromacs/gromacs-2024.5.tar.gz && tar -xzf gromacs-2024.5.tar.gz
RUN git clone https://github.com/plumed/plumed2.git

# === Build and install PLUMED ===
RUN cd /opt/plumed2 && \
    ./configure --prefix=/usr/local/plumed --enable-mpi && \
    make -j$(nproc) && \
    make install

# Make plumed available to PATH
ENV PATH=/usr/local/plumed/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/plumed/lib:$LD_LIBRARY_PATH


# === Patch GROMACS with PLUMED ===
RUN cd /opt/gromacs-2024.5 && \
    plumed patch -p --runtime -e gromacs-2024.3

# === Build and install GROMACS ===
RUN mkdir /opt/gromacs-2024.5/build && cd /opt/gromacs-2024.5/build && \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr/local/gromacs \
    -DGMX_MPI=ON \
    -DGMX_GPU=CUDA \
    -DGMX_BUILD_OWN_FFTW=ON \
    -DGMX_DOUBLE=OFF \
    -DGMX_PLUMED=ON \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_CXX_COMPILER=mpicxx && \
    make -j$(nproc) && \
    make install

# Source GMXRC on container startup (optional)
RUN echo "source /usr/local/gromacs/bin/GMXRC" >> /root/.bashrc

# Add gromacs to path
ENV PATH=/usr/local/gromacs/bin:$PATH

WORKDIR /root

CMD ["/bin/bash"]
