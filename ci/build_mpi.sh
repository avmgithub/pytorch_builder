#!/bin/bash

set -xe

# OSU currently has nvidia driver 396.26 installed
# This nvidia docker image is based on 396.37.
# There is possibility that /usr/lib64/libcuda.so is 
# linked to the incoorect nvidia library and may result
# in a file truncated error.
# This temporary workaround should fix it so our docker
# image can run on an older version of the nvidia driver.

DISTRO=`awk -F= '/^NAME/{print $2}' /etc/os-release`

if [ "$DISTRO" == "\"Ubuntu\"" ]
then
    if [ -f /usr/lib/powerpc64le-linux-gnu/libcuda.so.396.26 ] && [ -f /usr/lib/powerpc64le-linux-gnu/libcuda.so.396.37 ]
    then
        rm /usr/lib/powerpc64le-linux-gnu/libcuda.so
        ln -s /usr/lib/powerpc64le-linux-gnu/libcuda.so.396.26 /usr/lib/powerpc64le-linux-gnu/libcuda.so
    fi
fi

if [ "$DISTRO" == "\"CentOS Linux\"" ]
then
    if [ -f /usr/lib64/libcuda.so.396.26 ] && [ -f /usr/lib64/libcuda.so.396.37 ]
    then
        rm /usr/lib64/libcuda.so
        ln -s /usr/lib64/libcuda.so.396.26 /usr/lib64/libcuda.so
    fi

    if [ -f /usr/lib64/libcuda.so.396.37 ] && [ -f /usr/lib64/libcuda.so.410.72 ]
    then
        rm /usr/lib64/libcuda.so
        ln -s /usr/lib64/libcuda.so.410.72 /usr/lib64/libcuda.so
    fi
fi

./build_nimbix_with_scipy.sh  pytorch HEAD master foo ${PYTHON_VERSION} LINUX ${BUILD_ONLY} ${CREATE_ARTIFACTS} ${GIT_REPO}
