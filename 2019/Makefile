CC=g++
CFLAGS=-Wall

SRC_DIR=./src
BUILD_DIR=./build
SRCS=$(wildcard $(SRC_DIR)/*.cpp)
OBJS=$(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%, $(SRCS))

all: $(OBJS)

$(BUILD_DIR)/%: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(OBJS)
