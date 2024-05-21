FROM quay.io/keycloak/keycloak:21.0.2

COPY docker-entrypoint.sh /opt/jboss/tools

WORKDIR /opt/jboss/keycloak

RUN ./bin/kc.sh start config --db=postgres
