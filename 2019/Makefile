CC=g++
CFLAGS=-Wall
CMAKE=cmake

BUILD_DIR=./build

.PHONY: all build

all: compile

build:
	$(CMAKE) -S . -B $(BUILD_DIR)

compile: build
	make -C $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)
