FROM quay.io/keycloak/keycloak:24.0.4

COPY docker-entrypoint.sh /opt/keycloak/tools

WORKDIR /opt/keycloak

# Configure Keycloak to use PostgreSQL
RUN /opt/keycloak/bin/kc.sh config --db=postgres
