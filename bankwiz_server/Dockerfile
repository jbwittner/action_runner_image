# Use the official GitHub Actions runner image as a base
# Pinning the digest is a good practice for reproducible builds
FROM ghcr.io/actions/actions-runner:2.334.0

LABEL org.opencontainers.image.source="https://github.com/jbwittner/action_runner_image"
LABEL org.opencontainers.image.description="Self-hosted GitHub Actions runner image for bankwiz_server (JDK 25, Maven, Docker, gh, kustomize)"
LABEL org.opencontainers.image.licenses="MIT"

# Switch to root user to install system dependencies
USER root

# Install necessary system dependencies
RUN apt-get update && apt-get upgrade -y

# Install Temurin JDK 25.0.2+10
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH
RUN apt-get install -y curl ca-certificates \
    && ARCH="$(dpkg --print-architecture)" \
    && case "$ARCH" in \
         amd64) JDK_ARCH=x64 ;; \
         arm64) JDK_ARCH=aarch64 ;; \
         *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
       esac \
    && curl -fsSL -o /tmp/jdk.tar.gz \
       "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.2%2B10/OpenJDK25U-jdk_${JDK_ARCH}_linux_hotspot_25.0.2_10.tar.gz" \
    && mkdir -p "$JAVA_HOME" \
    && tar -xzf /tmp/jdk.tar.gz -C "$JAVA_HOME" --strip-components=1 \
    && rm /tmp/jdk.tar.gz

# Install Maven 3.9.14
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH
RUN curl -fsSL -o /tmp/maven.tar.gz \
       "https://archive.apache.org/dist/maven/maven-3/3.9.14/binaries/apache-maven-3.9.14-bin.tar.gz" \
    && mkdir -p "$MAVEN_HOME" \
    && tar -xzf /tmp/maven.tar.gz -C "$MAVEN_HOME" --strip-components=1 \
    && rm /tmp/maven.tar.gz

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

# Install the github CLI
RUN apt-get install -y gh

# Install kustomize
ARG KUSTOMIZE_VERSION=5.8.1
RUN ARCH="$(dpkg --print-architecture)" \
    && case "$ARCH" in \
         amd64) KUSTOMIZE_ARCH=amd64 ;; \
         arm64) KUSTOMIZE_ARCH=arm64 ;; \
         *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
       esac \
    && curl -fsSL -o /tmp/kustomize.tar.gz \
       "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${KUSTOMIZE_ARCH}.tar.gz" \
    && tar -xzf /tmp/kustomize.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/kustomize \
    && rm /tmp/kustomize.tar.gz

# Switch back to the non-root 'runner' user for security
USER runner
