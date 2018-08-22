FROM kong

# Install some stuff
RUN apk add --no-cache bash postgresql-client python3 py3-pip && \
    pip3 install --upgrade awscli

# Set entrypoint
COPY docker-entrypoint.sh /pre-docker-entrypoint.sh
ENTRYPOINT ["/pre-docker-entrypoint.sh"]

CMD ["kong", "docker-start"]