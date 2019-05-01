sed s/DOCKER_VERSION/9.2-cudnn7-devel-centos7/ Dockerfile.centos  > Dockerfile
sudo docker build -t docker.io/avmdocker/pytorch-ci-centos:cuda92cudnn7 .

#sed s/DOCKER_VERSION/9.1-cudnn7/ Dockerfile.ORG > Dockerfile 
#sudo docker build -t docker.io/avmdocker/pytorch-ci:cuda91cudnn7 .

#sed s/DOCKER_VERSION/8.0-cudnn6/ Dockerfile.ORG > Dockerfile 
#sudo docker build -t docker.io/avmdocker/pytorch-ci:cuda8cudnn6 .

#sudo docker push docker.io/avmdocker/pytorch-ci:cuda92cudnn7
#sudo docker push docker.io/avmdocker/pytorch-ci:cuda91cudnn7
#sudo docker push docker.io/avmdocker/pytorch-ci:cuda8cudnn6
#sudo docker push docker.io/avmdocker/pytorch-ci-centos:cuda92cudnn7

rm Dockerfile
