# myneovim
This repository manages my dockerfile of neovim.

## requirements
- Docker (>= version 24.0.4, build 3713ee1)

## Build & Run
This section describe the mean of building and running this dockerfile.
### Build
You execute the below command:
```
docker build -t myneovim:0.9.1 .
```

### Run
Building completely, then you open neovim editor to execute the below command:
```
docker run --rm -it myneovim:0.9.1
```

If you mount current dirctory into the docker container, you execute below command:
```
docker run --rm -it \
     --mount type=bind,source=.,target=/workspace\
     -w /workspace myneovim:0.9.1
```


