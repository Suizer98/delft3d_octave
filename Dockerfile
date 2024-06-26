# Use an official Ubuntu image as a parent image
FROM ubuntu:latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Set environment variables for non-interactive apt and Octave
ENV DEBIAN_FRONTEND=noninteractive \
    OCTAVE_NO_GUI=true \
    PIP_BREAK_SYSTEM_PACKAGES=1

# Install required packages
RUN set -xe \
    && apt-get update -y --no-install-recommends \
    && apt-get install -y --no-install-recommends \
        octave \
        octave-netcdf \
        libnetcdf-dev \
        python3-pip \
        python3.10

# Copy files
COPY . .

# Install Python packages
RUN pip install --upgrade pip \
    && pip install -r requirements.txt
