all: setup
	alias nvim=$(pwd)/nvim 

setup:
	docker volume create myneovim

clear: setup
	docker volume rm myneovim
	docker volume prune
	docker builder prune

build-nocache: clear setup
	docker build -t myneovim \
		--build-arg USER=$(shell whoami) \
		--build-arg UID=$(shell id -u) \
		--build-arg GID=$(shell id -g) \
		--build-arg DISPLAY=${DISPLAY} \
		--build-arg WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
		--no-cache .

build:
	docker build -t myneovim \
		--build-arg USER=$(shell whoami) \
		--build-arg UID=$(shell id -u) \
		--build-arg GID=$(shell id -g) \
		--build-arg DISPLAY=${DISPLAY} \
		--build-arg WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
		.

