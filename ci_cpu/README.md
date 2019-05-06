
Files in this directory are used in OSU CI for CPU only.

OSU has pre-built Docker images ; see https://github.com/osuosl/osl-dockerfiles/tree/master/ubuntu-ppc64le-cuda .<br>
The images are used in their CI environment. I use them for running CI for CPU only testing for PyTorch

See CPU only tests configuration at OSU <br>
https://powerci.osuosl.org/user/avmgithub/my-views/view/PyTorch/job/pytorch-master-nightly-py2-linux-ppc64le/configure  <br>
https://powerci.osuosl.org/user/avmgithub/my-views/view/PyTorch/job/pytorch-master-nightly-py3-linux-ppc64le/configure

In the configuration, the Label Expression box specifies which Docker image is used.
An example is :  docker-osuosl-ubuntu-ppc64le-cuda-9.0-cudnn7  <br>
This specifies the cuda and cudnn versions used.

The CI configuration clones this directory and executes the ./ci_cpu/build_nimbix.sh with some arguments
to execute the build and test inside the docker container.

Update (5/6/2019) <br>
Email from Lance regarding changes to CI builds: <br>
All,

I wanted to announce that we've deployed a new method for running your CI jobs on our Jenkins environment. We've installed the Docker Custom Build Environment [0] plugin and configured our docker nodes to properly use the plugin. This will allow you as users to deploy any image you would like without the OSL needing to configure the image on the admin panel. This also gives you a lot more flexibility in how you can use the system hopefully. In addition, this should help resolve load balancing issues we currently have with the current setup.

We've created new documentation [1] describing how to use the plugin and interact with our system. We've redeployed our docker nodes so that two are POWER8 and the other two are POWER9. You can select which one by using the 'power8' or 'power9' label. We are still maintaining the same docker images if you'd prefer to use them. If you want to use your own images, please read the documentation on what changes you need to make to ensure it works correctly.

Currently, this change is only for users of the CPU system. For users on the GPU system, we're in the process of migrating to using the same method which should hopefully be ready in a few weeks. The new system will completely bypass needing to go through SGE for submitting jobs and will run directly via docker and Jenkins.

We would like everyone with CPU jobs to migrate to using this plugin ASAP. After May 17th, we will migrate the remaining jobs over to the new system and ensure that those jobs are still working. We will be deprecating the previous docker system by the end of May. I've also updated the example "test" jobs if you would like to see how they work.

If you have any questions, please let me know!

[0] https://plugins.jenkins.io/docker-custom-build-environment  <br>
[1] https://wiki.osuosl.org/powerci/docker.html
