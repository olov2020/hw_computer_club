# Stage 1: Build the application
FROM golang:1.23 AS builder

WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o club-service cmd/app/main.go

# Stage 2: Create a minimal image
FROM debian:bullseye-slim

WORKDIR /app

# Install CA certificates for HTTPS support
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /app/club-service .

# Copy .env file if it exists
COPY .env ./.env

# Ensure the binary is executable
RUN chmod +x club-service

# Run the application
CMD ["/app/club-service"]
