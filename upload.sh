DST_DIST=jammy

sudo docker build \
        -t pv-safronov-backports:${DST_DIST} \
        --build-arg DIST=${DST_DIST} \
        .

# NOTE: your local GPG keyring should be GPG2
sudo docker run \
    -e DEBEMAIL="Pavel Safronov <pv.safronov@gmail.com>" \
    -e PPA=ppa:pv-safronov/backports \
    -v ${HOME}/.gnupg:/tmp/host_gnupg \
    -it pv-safronov-backports:${DST_DIST}
