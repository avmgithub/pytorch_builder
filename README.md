 
Directories in this directory

ci - Docker scripts to build Dockerfile for GPU based CI at OSU ; see https://powerci.osuosl.org <br>
ci_cpu - Scripts executed build Dockerfile for GPU based CI at OSU ; see https://powerci.osuosl.org

See README.md in each sub-directory to learn more


Update (5/6/2019)
Email from Lance regarding changes to CI builds:
All,

I wanted to announce that we've deployed a new method for running your CI jobs on our Jenkins environment. We've installed the Docker Custom Build Environment [0] plugin and configured our docker nodes to properly use the plugin. This will allow you as users to deploy any image you would like without the OSL needing to configure the image on the admin panel. This also gives you a lot more flexibility in how you can use the system hopefully. In addition, this should help resolve load balancing issues we currently have with the current setup.

We've created new documentation [1] describing how to use the plugin and interact with our system. We've redeployed our docker nodes so that two are POWER8 and the other two are POWER9. You can select which one by using the 'power8' or 'power9' label. We are still maintaining the same docker images if you'd prefer to use them. If you want to use your own images, please read the documentation on what changes you need to make to ensure it works correctly.

Currently, this change is only for users of the CPU system. For users on the GPU system, we're in the process of migrating to using the same method which should hopefully be ready in a few weeks. The new system will completely bypass needing to go through SGE for submitting jobs and will run directly via docker and Jenkins.

We would like everyone with CPU jobs to migrate to using this plugin ASAP. After May 17th, we will migrate the remaining jobs over to the new system and ensure that those jobs are still working. We will be deprecating the previous docker system by the end of May. I've also updated the example "test" jobs if you would like to see how they work.

If you have any questions, please let me know!

[0] https://plugins.jenkins.io/docker-custom-build-environment
[1] https://wiki.osuosl.org/powerci/docker.html
