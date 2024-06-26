FROM alpine:3
RUN apk add --no-cache wget tar

RUN wget https://github.com/microsoft/go-sqlcmd/releases/download/v1.7.0/sqlcmd-linux-amd64.tar.bz2
RUN mkdir sqlcmd

# keep repo to comply with MIT licence
RUN tar -xf sqlcmd-linux-amd64.tar.bz2 -C sqlcmd
RUN cp sqlcmd/sqlcmd /bin
RUN chmod +x /bin/sqlcmd
ENTRYPOINT ["/bin/sh"]