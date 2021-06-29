
ARG nominatim_version=3.5.2

FROM peterevans/nominatim:latest-focal

LABEL \
    maintainer="Godwin peter .O <me@godwin.dev>" \
    org.opencontainers.image.title="nominatim-nigeria-ghana" \
    org.opencontainers.image.description="Docker image for Nominatim Nigeria & Ghana." \
    org.opencontainers.image.authors="Godwin peter .O <me@godwin.dev>" \
    org.opencontainers.image.url="https://github.com/gpproton/nominatim-nigeria-ghana" \
    org.opencontainers.image.vendor="https://godwin.dev" \
    org.opencontainers.image.licenses="MIT" \
    app.tag="nominatim${nominatim_version}"

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
