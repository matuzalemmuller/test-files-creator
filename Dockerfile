FROM alpine:3.15

COPY create.sh /app/

RUN mkdir /data /log

CMD if [ -n "$hash" ]; then \
      /app/create.sh --output=/data --size=$size --create=$create --log=/log/log.txt --hash=$hash --csv; \
    else \
      /app/create.sh --output=/data --size=$size --create=$create --log=/log/log.txt --csv; \
    fi
