FROM quay.io/keycloak/keycloak:24.0.4

COPY docker-entrypoint.sh /opt/keycloak/tools

WORKDIR /opt/keycloak


