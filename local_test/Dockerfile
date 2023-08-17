ARG RUST_IMAGE_VERSION=latest
FROM ubuntu as datenlord
LABEL maintainers="DatenLord Authors"
LABEL description="DatenLord Distributed Storage"

COPY datenlord /usr/local/bin/datenlord
COPY ./umount-in-container.sh /usr/local/bin/umount-in-container.sh
COPY ./datenlord-entrypoint.sh /usr/local/bin/datenlord-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/datenlord-entrypoint.sh"]
CMD []