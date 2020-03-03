FROM google/cloud-sdk:alpine

COPY ./flatcar-google-image-uploader /usr/local/bin/flatcar-google-image-uploader

RUN chmod +x /usr/local/bin/flatcar-google-image-uploader

ENTRYPOINT ["/usr/local/bin/flatcar-google-image-uploader"]