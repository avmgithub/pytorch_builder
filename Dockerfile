FROM osuosl/ubuntu-ppc64le-cuda:8.0-cudnn6

#RUN git clone https://github.com/avmgithub/pytorch_builder.git; ls -lR  ; pwd 

ENTRYPOINT ["./build.sh"]
