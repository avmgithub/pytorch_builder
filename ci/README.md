
This directory builds docker containers used for the OSU CI for Power with GPUs.

See : https://powerci.osuosl.org/

Most if not all the pytorch CI builds will start with "pytorch-"

Files in this directory:

build_dockefile_centos.sh  - to build centos based docker file
build_dockefile.sh - to build Ubuntu based docker file
buildme.mpi - for building openmpi with GPU support
build_mpi.sh
build_nimbix_with_scipy.sh
Dockerfile.centos
Dockerfile.ORG - template used by Ubuntu or Docker based files
README.md - this file
refresh_image_with_mpi.sh
