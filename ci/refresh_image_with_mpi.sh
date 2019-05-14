#!/usr/bin/env bash

echo "here in build_nimbix"

set -xe

PROJECT=$1
GIT_COMMIT=$2
GIT_BRANCH=$3
GITHUB_TOKEN=$4
PYTHON_VERSION=$5
OS=$6

usermod -u 10000 jenkins
usermod -g 10000 jenkins

if [ "$#" -ne 6 ]
then
  echo "Did not find 6 arguments" >&2
  exit 1
fi

ARCH=`uname -m`

echo "Username: $USER"
echo "Homedir: $HOME"
echo "Home ls:"
ls -alh ~/ || true
echo "Current directory: $(pwd)"
echo "Project: $PROJECT"
echo "Branch: $GIT_BRANCH"
echo "Commit: $GIT_COMMIT"
echo "OS: $OS"

echo "Installing dependencies"

echo "Disks:"
df -h || true

if [ "$OS" == "LINUX" ]; then
    if [ "$ARCH" == "ppc64le" ]; then
        # ppc64le builds do not have GPU enabled so skip this for now
        # echo "skipping running nvidia-smi"

        echo "Processor info"
        cat /proc/cpuinfo|grep "cpu" | wc -l
        cat /proc/cpuinfo|grep "model name" | sort | uniq
    else
        echo "running nvidia-smi"
        nvidia-smi

        echo "Processor info"
        cat /proc/cpuinfo|grep "model name" | wc -l
        cat /proc/cpuinfo|grep "model name" | sort | uniq
        cat /proc/cpuinfo|grep "flags" | sort | uniq
    fi

    echo "Linux release:"
    #lsb_release -a || true
else
    echo "Processor info"    
    sysctl -n machdep.cpu.brand_string
fi

uname -a

if [ "$OS" == "LINUX" ]; then
    # install and export ccache
    if which ccache > /dev/null
    then
        mkdir -p ~/ccache/lib
        mkdir -p ~/ccache/cuda
        ln -s /usr/bin/ccache ~/ccache/lib/cc
        ln -s /usr/bin/ccache ~/ccache/lib/c++
        ln -s /usr/bin/ccache ~/ccache/lib/gcc
        ln -s /usr/bin/ccache ~/ccache/lib/g++
        ln -s /usr/bin/ccache ~/ccache/cuda/nvcc

        ccache -M 50Gi
    fi

    export PATH=~/ccache/lib:$PATH
    export CUDA_NVCC_EXECUTABLE=~/ccache/cuda/nvcc

    # add cuda to PATH and LD_LIBRARY_PATH
    export PATH=/usr/local/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    if [ "$ARCH" == "ppc64le" ]; then
        sudo apt-get update 
        sudo apt-get remove -y openmpi-bin libopenmpi-dev libopenmpi1.10 openmpi-common 
        sudo apt-get install -y libopenblas-dev libc6-dbg
        wget http://launchpadlibrarian.net/334328053/valgrind_3.13.0-1ubuntu1_ppc64el.deb
        dpkg -i valgrind_3.13.0-1ubuntu1_ppc64el.deb
        rm valgrind_3.13.0-1ubuntu1_ppc64el.deb
        export LD_LIBRARY_PATH=/usr/local/magma/lib:$LD_LIBRARY_PATH
    fi

    if ! ls /usr/local/cuda-8.0
    then
        if [ "$ARCH" == "ppc64le" ]; then
            if ! ls /usr/local/cuda-8.0 && ! ls /usr/local/cuda-9.* 
            then 
                # ppc64le builds assume to have all CUDA libraries installed
                # if they are not installed then exit and fix the problem
                echo "Download CUDA 8.0 or CUDA 9.0 for ppc64le"
                exit
            fi
        else
            echo "Downloading CUDA 8.0"
            wget -c https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda_8.0.44_linux-run -O ~/cuda_8.0.44_linux-run

            echo "Installing CUDA 8.0"
            chmod +x ~/cuda_8.0.44_linux-run
            sudo bash ~/cuda_8.0.44_linux-run --silent --toolkit --no-opengl-libs
            echo "\nDone installing CUDA 8.0"
        fi
    else
        echo "CUDA 8.0 already installed"
    fi

    echo "nvcc: $(which nvcc)"

    if [ "$ARCH" == "ppc64le" ]; then
        # cuDNN libraries need to be downloaded from NVDIA and 
        # requires user registration.
        # ppc64le builds assume to have all cuDNN libraries installed
        # if they are not installed then exit and fix the problem
        if ! ls /usr/lib/powerpc64le-linux-gnu/libcudnn.so.6.0.21 && ! ls /usr/lib/powerpc64le-linux-gnu/libcudnn.so.7* && ! ls /usr/local/cuda/lib64/libcudnn.so.7*
        then
            #apt-get  remove libcudnn7-dev -y
            #apt-get  remove libcudnn7 -y
            #apt-get  install  libcudnn7=7.0.3.11-1+cuda9.0 -y
            #apt-get  install  libcudnn7-dev=7.0.3.11-1+cuda9.0 -y
            echo "download cudnn"
            exit 1
        fi
    else
        if ! ls /usr/local/cuda/lib64/libcudnn.so.6.0.21
        then
            echo "CuDNN 6.0.21 not found. Downloading and copying to /usr/local/cuda"
            mkdir -p /tmp/cudnn-download
            pushd /tmp/cudnn-download
            rm -rf cuda
            wget http://developer.download.nvidia.com/compute/redist/cudnn/v6.0/cudnn-8.0-linux-x64-v6.0.tgz
            tar -xvf cudnn-8.0-linux-x64-v6.0.tgz
            sudo cp -P cuda/include/* /usr/local/cuda/include/
            sudo cp -P cuda/lib64/* /usr/local/cuda/lib64/
            popd
            echo "Downloaded and installed CuDNN 6.0.21"
        fi
    fi
fi

echo "Checking Miniconda"


if [ "$OS" == "LINUX" ]; then
    if [ "$ARCH" == "ppc64le" ]; then
        miniconda_url="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-ppc64le.sh"
    else
        miniconda_url="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    fi
else
    miniconda_url="https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
fi

if ! ls ~/miniconda
then
    echo "Miniconda needs to be installed"
    # wget $miniconda_url -O ~/miniconda.sh
    curl $miniconda_url -o ~/miniconda.sh
    bash ~/miniconda.sh -b -p $HOME/miniconda
else
    echo "Miniconda is already installed"
fi

export PATH="/opt/miniconda/bin:$HOME/miniconda/bin:$PATH"
echo $PATH


export CONDA_ROOT_PREFIX=$(conda info --root)

# by default we install py3. If requested py2, create env and activate
if [ $PYTHON_VERSION -eq 2 ]
then
    echo "Requested python version 2. Activating conda environment"
    if ! conda info --envs | grep py2k
    then
	# create virtual env and activate it
	conda create -n py2k python=2 -y
    fi
    source activate py2k
    export CONDA_ROOT_PREFIX="$HOME/miniconda/envs/py2k"
    conda install -y pillow hypothesis cmake
else
    source activate root
fi

echo "Conda root: $CONDA_ROOT_PREFIX"

if ! which cmake
then
    echo "Did not find cmake"
    conda install -y cmake
fi

if [ "$ARCH" == "ppc64le" ]; then
    # Installing numpy via conda pulls in openblas 2.19 , but it has a bug
    # Workaround is to install via pip until openblas gets updated to
    # newer version 2.20
    # conda install -y numpy openblas
    # pip install numpy scipy==1.0.0
    # pre-install pillow. Needed by torchvision installation
    #conda install -y pillow hypothesis numpy scipy openblas
    conda install -y pillow hypothesis openblas
else
    conda install -y mkl numpy
fi

#install ninja
if [ "$ARCH" == "ppc64le" ]; then
    if ! ls /usr/local/bin/ninja
    then
        git clone https://github.com/ninja-build/ninja.git
        pushd ninja
        #git checkout tags/v1.7.2
        git checkout tags/v1.8.2
        ./configure.py --bootstrap 
        sudo cp ninja /usr/local/bin
        popd
    fi
fi


# install pyyaml (for setup)
conda install -y pyyaml typing

if [ "$OS" == "LINUX" ]; then
    if [ "$ARCH" == "ppc64le" ]; then
      # remove pre-installed magma libraries
      # rm -rf  /usr/local/magma
      if [ $BUILD_MAGMA == "YES" ]; then
        if ! ls /usr/local/magma/lib/libmagma.so
        then
            sudo apt-get install -y gfortran
            /usr/bin/curl -o magma-2.4.0.tar.gz "http://icl.cs.utk.edu/projectsfiles/magma/downloads/magma-2.4.0.tar.gz"
            gunzip -c magma-2.4.0.tar.gz | tar -xvf -
            pushd magma-2.4.0
            cp make.inc-examples/make.inc.openblas make.inc
            sed -i 's/nvcc/\/usr\/local\/cuda\/bin\/nvcc/' make.inc
            sed -i 's/#OPENBLASDIR/OPENBLASDIR/' make.inc
            sed -i 's/\/usr\/local\/openblas/\/usr/' make.inc
            sed -i 's/#CUDADIR/CUDADIR/' make.inc
            sed -i 's/#GPU_TARGET ?= Kepler Maxwell Pascal/GPU_TARGET ?= Pascal/' make.inc
            sudo make -j32 install
            popd
            rm magma-2.4.0.tar.gz
            rm -rf magma-2.4.0
            sudo apt-get remove -y gfortran
        fi
      fi
    fi
fi

# add mkl to CMAKE_PREFIX_PATH
export CMAKE_LIBRARY_PATH=$CONDA_ROOT_PREFIX/lib:$CONDA_ROOT_PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$CONDA_ROOT_PREFIX

echo "Python Version:"
python --version

exit 0
