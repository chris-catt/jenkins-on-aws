FROM jenkins/jenkins:lts-jdk11

LABEL org.opencontainers.image.source https://github.com/chris-catt/jenkins-on-aws

COPY jenkins-resources/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

COPY jenkins-resources/initialConfig.groovy /usr/share/jenkins/ref/init.groovy.d/initialConfigs.groovy
COPY jenkins-resources/jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
COPY jenkins-resources/agentsTestJob.xml /usr/share/jenkins/ref/jobs/test-default-agents/config.xml

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false