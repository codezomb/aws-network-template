FROM alpine:3.19.1

WORKDIR /workspace

COPY ./install.sh /workspace/
RUN ./install.sh && \
  rm install.sh

COPY ./ /workspace/
