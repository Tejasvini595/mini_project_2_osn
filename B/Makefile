CC = gcc
CFLAGS = -Wall -Wextra -pthread -O2
LDFLAGS = -lpcap -lpthread

TARGET = cshark
SRC = start_scratch.c

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)
	@echo ""
	@echo "==================================="
	@echo "C-Shark compiled successfully!"
	@echo "Run with: sudo ./$(TARGET)"
	@echo "==================================="

clean:
	rm -f $(TARGET)
	@echo "Cleaned build artifacts"