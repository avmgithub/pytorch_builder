FROM osuosl/ubuntu-ppc64le-cuda:8.0-cudnn6

#RUN git clone https://github.com/avmgithub/pytorch_builder.git
COPY build.sh ./
RUN pwd
RUN ls

ENTRYPOINT ["./build.sh"]
