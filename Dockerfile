FROM ubuntu:24.04 AS build
RUN apt-get update \
    && apt-get install -y --no-install-recommends cmake gfortran make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/gsm-src
COPY . .
ARG BUILD_JOBS=4
RUN cmake -S . -B /opt/gsm-build -DCMAKE_BUILD_TYPE=Release \
        -Dgsm.BUILD_DOCS=OFF -Dgsm.SIM_DIR=OFF -Dgsm.TEST=OFF \
    && cmake --build /opt/gsm-build --target xgsm1 --parallel "$BUILD_JOBS"

FROM ubuntu:24.04
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgfortran5 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /opt/gsm-build/bin/xgsm1 /opt/gsm/xgsm1
COPY --from=build /opt/gsm-src/src/dataTbl/ /opt/gsm/data/
COPY docker-entrypoint.sh /usr/local/bin/gsm-entrypoint
RUN chmod 755 /usr/local/bin/gsm-entrypoint \
    && mkdir /work && chown 1000:1000 /work
ENV PATH="/opt/gsm:$PATH"
WORKDIR /work
USER 1000:1000
ENTRYPOINT ["gsm-entrypoint"]
CMD ["xgsm1"]
