CC=g++
CFLAGS=-Wall
CMAKE=cmake

SRC_DIR=./src
BUILD_DIR=./build
SRCS=$(wildcard $(SRC_DIR)/*.cpp)
OBJS=$(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%, $(SRCS))

.PHONY: all build

all: $(OBJS)

$(BUILD_DIR)/% &: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	$(CMAKE) -S . -B $(@D)
	make -C $(@D)

clean:
	rm -rf $(BUILD_DIR)
