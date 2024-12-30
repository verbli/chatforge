#!/bin/bash

NAME="chatforge-build"

tagline=""
for tag in $(cat tags); do
    tagline=" -t ${NAME}:$tag"
done

docker build $tagline .
