#!/bin/bash

# This script manually installs gromacs with plumed

# Install dependencies for build
sudo apt-get update && sudo apt-get install -y \
    build-essential cmake git wget curl unzip \
    libfftw3-dev libgsl-dev \
    openmpi-bin libopenmpi-dev \
    libboost-all-dev \
    python3 python3-pip vim \

mkdir -p ${HOME}/programs
cd ${HOME}/programs

# Get sources
wget ftp://ftp.gromacs.org/gromacs/gromacs-2024.5.tar.gz && tar -xzf gromacs-2024.5.tar.gz
git clone https://github.com/plumed/plumed2.git

# Build and install PLUMED
cd ${HOME}/programs/plumed2 && \
    ./configure --prefix=${HOME}/programs/install/plumed-install --enable-mpi && \
    make -j$(nproc) && \
    make install

export PATH=${HOME}/programs/install/plumed-install/bin:$PATH
export LD_LIBRARY_PATH=${HOME}/programs/install/plumed-install/lib:$LD_LIBRARY_PATH

echo "export PATH=${HOME}/programs/install/plumed-install/bin:$PATH" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=${HOME}/programs/install/plumed-install/lib:$LD_LIBRARY_PATH" >> ${HOME}/.bashrc

# Patch GROMACS with PLUMED
cd ${HOME}/programs/gromacs-2024.5 && \
    plumed patch -p --runtime -e gromacs-2024.3

# Build and install GROMACS
mkdir ${HOME}/programs/gromacs-2024.5/build && cd ${HOME}programs/gromacs-2024.5/build && \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=${HOME}/programs/install/gromacs-install \
    -DGMX_MPI=ON \
    -DGMX_GPU=CUDA \
    -DGMX_BUILD_OWN_FFTW=ON \
    -DGMX_DOUBLE=OFF \
    -DGMX_PLUMED=ON \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_CXX_COMPILER=mpicxx && \
    make -j$(nproc) && \
    make install

export PATH=/usr/local/plumed/bin:/usr/local/gromacs/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/plumed/lib:$LD_LIBRARY_PATH


echo "export PATH=/usr/local/plumed/bin:/usr/local/gromacs/bin:$PATH" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/plumed/lib:$LD_LIBRARY_PATH" >> ${HOME}/.bashrc


# Source GMXRC for convenience
echo "source /usr/local/gromacs/bin/GMXRC" >> ${HOME}/.bashrc

source ${HOME}/.bashrc
