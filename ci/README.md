
This directory builds docker containers used for the OSU CI for Power with GPUs.

See : https://powerci.osuosl.org/

Most if not all the pytorch CI builds will start with "pytorch-"

Files in this directory:

Dockerfile.centos  <br>
Dockerfile.ORG - template used by Ubuntu or Docker based files <br>
build_dockefile_centos.sh  - to build centos based docker file <br>
build_dockefile.sh - to build Ubuntu based docker file <br>
buildme.mpi - for building openmpi with GPU support <br>
build_mpi.sh <br>
build_nimbix_with_scipy.sh  <br>
README.md - this file <br>
refresh_image_with_mpi.sh <br>
