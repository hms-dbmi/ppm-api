FROM kong

# Install some stuff
RUN apk add --no-cache bash postgresql-client python3 py3-pip jq && \
    pip3 install --upgrade awscli

# Set entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Disable daemon
ENV KONG_PREFIX=/usr/local/kong
ENV KONG_NGINX_DAEMON=off
ENV CREATE_SSL=true

# Copy the configs/templates
COPY healthcheck.kong.conf $KONG_PREFIX/healthcheck.kong.conf

# Inform Kong to include the location in the proxy server
ENV KONG_NGINX_PROXY_INCLUDE=$KONG_PREFIX/healthcheck.kong.conf
