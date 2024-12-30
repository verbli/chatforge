# Use a Flutter base image
FROM ghcr.io/cirruslabs/flutter:3.27.1 AS build-env

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgtk-3-dev \
    libstdc++6 \
    clang cmake ninja-build curl git unzip xz-utils zip libglu1-mesa pkg-config \
    android-sdk \
    wget \
    ffmpeg \
    imagemagick \
    && apt-get clean

# Install Gotify CLI
RUN wget https://github.com/gotify/cli/releases/download/v2.3.2/gotify-cli-linux-amd64 \
    -O /usr/local/bin/gotify && chmod +x /usr/local/bin/gotify

# Set environment variables
ENV PATH="/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:$PATH"
ENV ANDROID_SDK_ROOT="/opt/android-sdk-linux"

# Copy build scripts and assets
COPY scripts/ /build-scripts/
COPY assets/ /build-assets/
RUN mkdir -p /etc/gotify
COPY cli.json /etc/gotify/cli.json

# Set permissions
RUN chmod +x /build-scripts/*.sh

# Make flutter work with my paths until I fix this
RUN ln -s /sdks/flutter /opt/flutter

# Create mount point for app source
WORKDIR /app

# Set entrypoint to use scripts from their new location
ENTRYPOINT ["/build-scripts/build.sh"]
