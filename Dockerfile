FROM kong:0.14.1

# Install some stuff
RUN apk add --no-cache bash postgresql-client python3 py3-pip jq && \
    pip3 install --upgrade awscli

# Disable daemon
ENV KONG_PREFIX=/usr/local/kong
ENV KONG_NGINX_DAEMON=off

# Copy the configs/templates
COPY healthcheck.kong.conf $KONG_PREFIX/healthcheck.kong.conf

# Inform Kong to include the location in the proxy and admin servers
ENV KONG_NGINX_PROXY_INCLUDE=$KONG_PREFIX/healthcheck.kong.conf
ENV KONG_NGINX_ADMIN_INCLUDE=$KONG_PREFIX/healthcheck.kong.conf

# Set entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]