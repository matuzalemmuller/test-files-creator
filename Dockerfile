FROM alpine:3.15

COPY test-files-creator.sh /app/

CMD if [ ! -d "/data" ]; then \
      echo "Output folder not mounted"; \
      exit 1; \
    fi; \
    if [ -d "/log" ]; then \
      if [ "$csv" = "true" ]; then \
        args="--log=/log/log.csv --csv"; \
      else \
        args="--log=/log/log.txt"; \
      fi; \
    fi; \
    if [ "$hash" = "md5" ] || [ "$hash" = "sha256" ]; then \
      args="$args --hash=$hash"; \
    fi; \
    if [ "$verbose" = "true" ]; then \
      args="$args --verbose"; \
    fi; \
    if [ "$progressbar" = "true" ]; then \
      args="$args --progressbar"; \
    fi; \
    /app/test-files-creator.sh --output=/data --size=$size --n_files=$n_files $args
