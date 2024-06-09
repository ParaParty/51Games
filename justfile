IMAGE_NAME := "51games-web"
TAR_FILE := "51games-web.tar"
TARGET_SERVER := "ubuntu@51games.minecraft.kim"
DEST_PATH := "/home/ubuntu/51games"
REGISTRY := "registry.cn-hangzhou.aliyuncs.com/nicognaw/nk"
VERSION := `git rev-parse HEAD`
CONTAINER_NAME := "51games"


build:
    docker build -t {{IMAGE_NAME}} .

tag:
    docker tag {{IMAGE_NAME}} {{REGISTRY}}:{{VERSION}}

push: tag
    docker push {{REGISTRY}}:{{VERSION}}

run:
    ssh {{TARGET_SERVER}} ' \
    docker stop {{CONTAINER_NAME}} || true; \
    docker rm {{CONTAINER_NAME}} || true; \
    docker run -d --name {{CONTAINER_NAME}} -p 80:80 -p 443:443 {{REGISTRY}}:{{VERSION}}'

run-local: tag
    docker stop {{CONTAINER_NAME}};
    docker rm {{CONTAINER_NAME}};
    docker run -d --name {{CONTAINER_NAME}} -p 80:80 -p 443:443 {{REGISTRY}}:{{VERSION}}

deploy: build push run
