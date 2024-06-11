# delft3d_octave

[[_TOC_]]

## Description
This project is mainly to free people who don't want to convert Delft3D FLOW Output using Matlab Software running the *.m scripts.
The working targets are trim*.dat and trih*.dat generated as NEFIS structure from Delft3D software.

Tech stacks: 

![Tech stacks](https://skillicons.dev/icons?i=octave,matlab,python,docker,ubuntu,bash,)

For now the working codes are:
1. vs_trim2nc.m
2. vs_trih2nc.m
3. slicedata.py

## Changes made to the *.m files
See this [commit](https://github.com/Suizer98/delft3d_octave/commit/ce7fe84e86b2596a1729d8bb010921148964d7c1)

## Setting up Docker Ubuntu environment

- Dockerfile and docker-compose.yml are created in such a way that you don't need to build environment by yourself, all you need is to run docker's command.
- After cloning this repo, copy your desired *.dat and *.def model results from Delft3D Flow outputs into the root directory.
- In your terminal simply run:

```
docker-compose up --build
docker-compose up # If images are cached
```

- To enter docker container:
```
docker exec -it delft3d-octave-delft3d-octave-1 bash  # Attach to the container's terminal
```
```
root@7e8c9bfe1c7a:/usr/src/app# ls
root@7e8c9bfe1c7a:/usr/src/app# ./batch_convert.sh
```

## Preparing environment on Window machine

### Prerequisites

- wsl2 on window
- Docker Desktop
