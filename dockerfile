# Use the official GitHub Actions runner image as a base
# Pinning the digest is a good practice for reproducible builds
FROM ghcr.io/actions/actions-runner:latest@sha256:deb54a88ead0a86beedec6ac949e8b28f77478835b9c6434ccc237390a6e3e4f

# Switch to root user to install system dependencies
USER root

# Install necessary packages in a single layer to reduce image size
# build-essential: for compiling native addons
# unzip, zip: required by sdkman
# Clean up apt cache to keep the image lean
RUN apt-get update && apt-get install -y \
    maven

# Switch back to the non-root 'runner' user for security
USER runner