# Use a Flutter base image
FROM cirrusci/flutter:stable AS build-env

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgtk-3-dev \
    libstdc++6 \
    openjdk-11-jdk \
    wget \
    ffmpeg \
    imagemagick \
    && apt-get clean

# Install Gotify CLI
RUN wget https://github.com/gotify/cli/releases/download/latest/gotify-linux-amd64 \
    -O /usr/local/bin/gotify && chmod +x /usr/local/bin/gotify

# Set environment variables for Flutter
ENV PATH="/flutter/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:$PATH"
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV FLUTTER_HOME="/flutter"

# Copy project files (can be overridden using volume mounts)
WORKDIR /app
COPY . /app

# Ensure the correct permissions
RUN chmod +x /app/*.sh

# Define the entry point for building
ENTRYPOINT ["/app/build.sh"]

