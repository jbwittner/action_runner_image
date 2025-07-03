# Use the official GitHub Actions runner image as a base
# Pinning the digest is a good practice for reproducible builds
FROM ghcr.io/actions/actions-runner:2.325.0

# Switch to root user to install system dependencies
USER root

# Install necessary system dependencies
RUN apt-get update && apt-get upgrade -y

# Install maven
RUN apt-get install -y maven

# Add Docker's official GPG key:
RUN apt-get update
RUN apt-get install ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's official repository to the sources list
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install necessary system dependencies
RUN apt-get update

RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Switch back to the non-root 'runner' user for security
USER runner