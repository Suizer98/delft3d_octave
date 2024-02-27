# Use an official Ubuntu image as a parent image
FROM ubuntu:latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Set environment variables for non-interactive apt and Octave
ENV DEBIAN_FRONTEND=noninteractive \
    OCTAVE_NO_GUI=true

# Install required packages
RUN set -xe \
    && apt-get update -y --no-install-recommends \
    && apt-get install -y --no-install-recommends \
        octave \
        octave-netcdf \
        libnetcdf-dev 

# Copy the script into the container
COPY . .
