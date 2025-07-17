# -------- Stage 1: Build WAR using Maven --------
FROM maven:3.9.6-eclipse-temurin-17 AS maven-builder

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Build WAR file
RUN mvn clean package -DskipTests

# -------- Stage 2: Build EAP runtime image --------
FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest AS builder

ENV GALLEON_PROVISION_FEATURE_PACKS=org.jboss.eap:wildfly-ee-galleon-pack,org.jboss.eap.cloud:eap-cloud-galleon-pack
ENV GALLEON_PROVISION_LAYERS=cloud-default-config
ENV GALLEON_PROVISION_CHANNELS=org.jboss.eap.channels:eap-8.0

RUN /usr/local/s2i/assemble

# -------- Stage 3: Runtime image --------
FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-runtime-openshift-rhel8:latest AS runtime

COPY --from=builder --chown=jboss:root $JBOSS_HOME $JBOSS_HOME

# Copy the WAR built in the first stage
COPY --from=maven-builder --chown=jboss:root /app/target/*.war $JBOSS_HOME/standalone/deployments/

EXPOSE 8080

RUN chmod -R ug+rwX $JBOSS_HOME
