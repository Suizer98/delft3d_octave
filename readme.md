# delft3d_octave

[[_TOC_]]

## Description
This project is mainly to free people who don't want to convert Delft3D FLOW Output using Matlab Software running the *.m scripts

For now the working codes are:
1. vs_trim2nc2.m

## Setting up Docker Ubuntu environment

- Dockerfile and docker-compose.yml are created in such a way that you don't need to build environment by yourself, all you need is to run docker's command.
- After cloning this repo, copy your desired *.dat and *.def model results from Delft3D Flow outputs,
- In your terminal simply run:

```
docker-compose up --build  # Start the containers in the background
docker exec -it delft3d-octave-delft3d-octave-1 bash  # Attach to the container's terminal
```

- After entering docker container:
```
root@7e8c9bfe1c7a:/usr/src/app# ls
root@7e8c9bfe1c7a:/usr/src/app# ./batch_trim2nc.sh
```

## Preparing environment on Window machine

### Prerequisites

- wsl2 on window
- Docker Desktop
