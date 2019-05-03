
Files in this directory are used in OSU CI for CPU only.

OSU has pre-built Docker images ; see https://github.com/osuosl/osl-dockerfiles/tree/master/ubuntu-ppc64le-cuda
The images are used in their CI environment. I use them for running CI for CPU only testing for PyTorch

See CPU only tests configuration at OSU
https://powerci.osuosl.org/user/avmgithub/my-views/view/PyTorch/job/pytorch-master-nightly-py2-linux-ppc64le/configure
https://powerci.osuosl.org/user/avmgithub/my-views/view/PyTorch/job/pytorch-master-nightly-py3-linux-ppc64le/configure

In the configuration, the Label Expression box specifies which Docker image is used.
An example is :  docker-osuosl-ubuntu-ppc64le-cuda-9.0-cudnn7 
This specifies the cuda and cudnn versions used.

The CI configuration clones this directory and executes the ./ci_cpu/build_nimbix.sh with some arguments
to execute the build and test inside the docker container.
