FROM quay.io/wildfly/wildfly:latest

# Copy WAR file to WildFly deployments folder
COPY target/demo.war /opt/jboss/wildfly/standalone/deployments/demo.war

# Add .dodeploy marker so WildFly auto-deploys the WAR
RUN touch /opt/jboss/wildfly/standalone/deployments/demo.war.dodeploy

# WildFly exposes 8080
EXPOSE 8080

# Start WildFly
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
