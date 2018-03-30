FROM osuosl/ubuntu-ppc64le-cuda:8.0-cudnn6

#RUN git clone https://github.com/avmgithub/pytorch_builder.git
COPY build.sh ./
COPY build_nimbix.sh ./
COPY refresh_image.sh ./
RUN pwd
RUN ls
RUN ./refresh_image.sh

ENTRYPOINT ["./build.sh"]
