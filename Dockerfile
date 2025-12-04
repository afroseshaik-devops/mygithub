FROM quay.io/wildfly/wildfly:latest

# Copy WAR to deployments folder
COPY target/demo.war /opt/jboss/wildfly/standalone/deployments/demo.war

EXPOSE 8080

# Start WildFly
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
