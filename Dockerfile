FROM registry.redhat.io/ocp-tools-4/jenkins-rhel8:v4.12.0-1686650770

# Set the working directory
WORKDIR /app

# Copy the script file to the container
COPY roll-token.sh /app/roll-token.sh

# Set the script file as executable
#RUN chmod +x /app/roll-token.sh

# Run the script file when the container starts
ENTRYPOINT ["sh /app/roll-token.sh"]
