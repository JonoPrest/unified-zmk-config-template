# ZMK Firmware Build Makefile
# Builds firmware locally using Docker

DOCKER_IMAGE = zmkfirmware/zmk-build-arm:stable
BOARD = nice_nano_v2
CONFIG_DIR = $(shell pwd)/config
OUTPUT_DIR = $(shell pwd)/firmware

.PHONY: all left right clean pull help

# Default target: build both halves
all: left right

# Pull the Docker image
pull:
	@echo "Pulling ZMK Docker image..."
	docker pull $(DOCKER_IMAGE)

# Build left half
left: pull
	@echo ""
	@echo "======================================"
	@echo "Building corne_left..."
	@echo "======================================"
	@mkdir -p $(OUTPUT_DIR)
	docker run --rm \
		-v $(CONFIG_DIR):/zmk-config:Z \
		$(DOCKER_IMAGE) \
		bash -c "cd /tmp && \
		         git clone https://github.com/zmkfirmware/zmk.git zmk-build && \
		         cd zmk-build && \
		         west init -l app/ && \
		         west update && \
		         west zephyr-export && \
		         west build -s app -b $(BOARD) -d build/left -- -DSHIELD=corne_left -DZMK_CONFIG=/zmk-config && \
		         cp build/left/zephyr/zmk.uf2 /zmk-config/corne_left.uf2"
	@mv $(CONFIG_DIR)/corne_left.uf2 $(OUTPUT_DIR)/ 2>/dev/null || true
	@echo "✓ Left half built successfully!"
	@echo "Firmware: $(OUTPUT_DIR)/corne_left.uf2"

# Build right half
right: pull
	@echo ""
	@echo "======================================"
	@echo "Building corne_right..."
	@echo "======================================"
	@mkdir -p $(OUTPUT_DIR)
	docker run --rm \
		-v $(CONFIG_DIR):/zmk-config:Z \
		$(DOCKER_IMAGE) \
		bash -c "cd /tmp && \
		         git clone https://github.com/zmkfirmware/zmk.git zmk-build && \
		         cd zmk-build && \
		         west init -l app/ && \
		         west update && \
		         west zephyr-export && \
		         west build -s app -b $(BOARD) -d build/right -- -DSHIELD=corne_right -DZMK_CONFIG=/zmk-config && \
		         cp build/right/zephyr/zmk.uf2 /zmk-config/corne_right.uf2"
	@mv $(CONFIG_DIR)/corne_right.uf2 $(OUTPUT_DIR)/ 2>/dev/null || true
	@echo "✓ Right half built successfully!"
	@echo "Firmware: $(OUTPUT_DIR)/corne_right.uf2"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(OUTPUT_DIR)
	rm -rf $(CONFIG_DIR)/build
	@echo "✓ Clean complete!"

# Help target
help:
	@echo "ZMK Firmware Build Targets:"
	@echo "  make          - Build both keyboard halves"
	@echo "  make left     - Build left half only"
	@echo "  make right    - Build right half only"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make pull     - Pull latest Docker image"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Output firmware files will be in: $(OUTPUT_DIR)/"
