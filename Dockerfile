# -------- Stage 1: Build WAR using Maven --------
FROM maven:3.9.6-eclipse-temurin-17 AS maven-builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests


# -------- Stage 2: Provision EAP Server (Galleon) --------
FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest AS builder

ENV GALLEON_PROVISION_FEATURE_PACKS=org.jboss.eap:wildfly-ee-galleon-pack
ENV GALLEON_PROVISION_LAYERS=web-server
ENV GALLEON_PROVISION_CHANNELS=org.jboss.eap.channels:eap-8.0

RUN /usr/local/s2i/assemble


# -------- Stage 3: Final Runtime Image --------
FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-runtime-openshift-rhel8:latest AS runtime

COPY --from=builder --chown=jboss:root $JBOSS_HOME $JBOSS_HOME
COPY --from=maven-builder --chown=jboss:root /app/target/*.war $JBOSS_HOME/standalone/deployments/

RUN chmod -R ug+rwX $JBOSS_HOME

EXPOSE 8080
