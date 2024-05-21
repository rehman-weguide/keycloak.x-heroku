FROM quay.io/keycloak/keycloak:24.0.4

COPY docker-entrypoint.sh /opt/jboss/tools

WORKDIR /opt/jboss/keycloak

RUN ./bin/kc.sh config --db=postgres
