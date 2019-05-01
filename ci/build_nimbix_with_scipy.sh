#!/usr/bin/env bash

echo "here in build_nimbix"

set -e

PROJECT=$1
GIT_COMMIT=$2
GIT_BRANCH=$3
GITHUB_TOKEN=$4
PYTHON_VERSION=$5
OS=$6
BUILD_ONLY=$7
CREATE_ARTIFACTS=$8
GIT_REPO=${GIT_REPO:=pytorch}

if [ "$#" -ne 9 ]
then
  echo "Did not find 9 arguments" >&2
  exit 1
fi

ARCH=`uname -m`
DISTRO=`awk -F= '/^NAME/{print $2}' /etc/os-release`

echo "Username: $USER"
echo "Homedir: $HOME"
echo "Home ls:"
ls -alh ~/ || true
echo "Current directory: $(pwd)"
echo "GIT Repository: $GIT_REPO"
echo "Project: $PROJECT"
echo "Branch: $GIT_BRANCH"
echo "Commit: $GIT_COMMIT"
echo "OS: $OS"
echo "BUILD_ONLY: $BUILD_ONLY"
echo "DISTRO: $DISTRO"

echo "Installing dependencies"

echo "Disks:"
df -h || true

if [ "$OS" == "LINUX" ]; then
    if [ "$ARCH" == "ppc64le" ]; then
        echo "running nvidia-smi"
        nvidia-smi

        echo "Processor info"
        cat /proc/cpuinfo|grep "model name" | wc -l
        cat /proc/cpuinfo|grep "model name" | sort | uniq
        cat /proc/cpuinfo|grep "flags" | sort | uniq
    fi
fi

uname -a

if [ "$OS" == "LINUX" ]; then

#    export PATH=~/ccache/lib:$PATH
#    export CUDA_NVCC_EXECUTABLE=~/ccache/cuda/nvcc

    # add cuda to PATH and LD_LIBRARY_PATH
    export PATH=/usr/local/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/nvidia/lib64:$LD_LIBRARY_PATH
    if [ "$ARCH" == "ppc64le" ]; then
        export LD_LIBRARY_PATH=/usr/local/magma/lib:$LD_LIBRARY_PATH
        LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH
        PATH=/usr/local/openmpi/bin:$PATH
    fi

    echo "nvcc: $(which nvcc)"
fi

echo "Checking Miniconda"

# clean ccache
if [ "$CLEAN_CCACHE" == "YES" ]; then
    echo "cleaning ccache"
    ccache -C
fi

if [ "$OS" == "LINUX" ]; then
    if [ "$ARCH" == "ppc64le" ]; then
        miniconda_url="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-ppc64le.sh"
    fi
fi

if ! ls ~/miniconda.sh
then
    echo "Miniconda needs to be installed"
    exit 1
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
else
    source activate root
fi

echo "Conda root: $CONDA_ROOT_PREFIX"

if ! which cmake
then
    echo "Did not find cmake"
    exit 1
fi

#install ninja
if ! which ninja
then
    echo "Did not find ninja"
    exit 1
fi

# add CMAKE_PREFIX_PATH
export CMAKE_LIBRARY_PATH=$CONDA_ROOT_PREFIX/lib:$CONDA_ROOT_PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$CONDA_ROOT_PREFIX

echo "Python Version:"
python --version

# Why is this uninstall necessary?  In ordinary development,
# 'python setup.py install' will overwrite an old install, so
# it is not usually necessary uninstall the old install first.
# However, it turns out that setuptools performs this install
# simply by copying files one-by-one, overwriting the old files,
# NOT an uninstall and reinstall.  This means that there is one
# nasty edge case:  suppose you have an old install of
# 'foo/bar/__init__.py', and your new install is 'foo/bar.py'
# (although this is "rare" to occur in a project history, it
# might occur if you PR a change to use __init__, but then builder
# goes back and builds another PR without this change).
# Because there is no uninstall step, BOTH 'foo/bar.py' and
# 'foo/bar/__init__.py' will exist in the install, and
# 'foo/bar/__init__.py' will ALWAYS win import resolution, even
# though you wanted 'foo/bar.py'.
#
# The fix is simple: uninstall, then reinstall.  Of course, if the
# uninstall leaves files behind, you can still get into a bad situation,
# but it is less likely to occur now.
echo "Removing old builds of torch"
pip uninstall -y torch || true

echo "Installing $GIT_REPO/$PROJECT at branch $GIT_BRANCH and commit $GIT_COMMIT"
rm -rf $PROJECT
git clone https://github.com/$GIT_REPO/$PROJECT --quiet
cd $PROJECT
git fetch --tags https://github.com/pytorch/$PROJECT +refs/pull/*:refs/remotes/origin/pr/* --quiet
git checkout $GIT_BRANCH
git submodule update --init --recursive

pip install -r requirements.txt || true
chown -R jenkins /home/jenkins/pytorch
export LD_LIBRARY_PATH=/usr/local/magma/lib:$LD_LIBRARY_PATH:/opt/miniconda/lib
if [ "$CREATE_ARTIFACTS" == "YES" ]; then
  python setup.py bdist_wheel
else
  time .jenkins/pytorch/build.sh
fi

if [ "$BUILD_ONLY"  == "YES" ]; then
    echo "PyTorch build complete"
    exit 0
fi

if [ "$CREATE_ARTIFACTS"  == "YES" ]; then
    echo "PyTorch build wheel complete"
    exit 0
fi

echo "Testing pytorch"
export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4

# New pytorch test script
if [ $PYTHON_VERSION -eq 2 ]
then
  time su jenkins -c "ulimit -s unlimited; export PATH=/opt/miniconda/envs/py2k/bin:$PATH; export VALGRIND=${VALGRIND:=OFF}; .jenkins/pytorch/test.sh"
else
  time su jenkins -c "ulimit -s unlimited; export PATH=/opt/miniconda/bin:$PATH; export VALGRIND=${VALGRIND:=OFF}; .jenkins/pytorch/test.sh"
fi

echo "ALL CHECKS PASSED"
exit 0
