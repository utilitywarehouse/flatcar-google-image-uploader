FROM google/cloud-sdk:alpine

COPY ./flatcar-google-image-uploader.sh /usr/local/bin/flatcar-google-image-uploader.sh

RUN chmod +x /usr/local/bin/flatcar-google-image-uploader.sh

ENTRYPOINT ["/usr/local/bin/flatcar-google-image-uploader.sh"]