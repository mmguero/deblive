FROM alpine:latest

RUN apk --no-cache -U add python3 && \
    apk upgrade --no-cache -U -a

COPY deblive-*.log /deblive/
COPY deblive-*.iso /deblive/

EXPOSE 8000

WORKDIR /deblive

ENTRYPOINT [ "python3", "-m", "http.server", "8000" ]