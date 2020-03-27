export VERSION=1.0.0
export ENV=prod
export PROJECT=gitlab-ci-local

TOPDIR=$(shell pwd)
OBJ_DIR=$(OUTPUT)/$(PROJECT)
SOURCE_BINARY_DIR=$(TOPDIR)/bin
SOURCE_BINARY_FILE=$(SOURCE_BINARY_DIR)/$(PROJECT)
SOURCE_MAIN_FILE=$(TOPDIR)/cmd/main.go

BUILD_TIME=`date +%Y%m%d%H%M%S`
BUILD_FLAG=-ldflags "-X main.version=$(VERSION) -X main.buildTime=$(BUILD_TIME)"

all: build pack
	@echo "\n\rALL DONE"
	@echo "Program:       "  $(PROJECT)
	@echo "Version:       "  $(VERSION)
	@echo "Env:           "  $(ENV)

build:
	@echo "start go build...."
	@go env | grep GOPROXY
	@go env -w  GOPROXY=https://goproxy.cn
	@rm -rf $(SOURCE_BINARY_DIR)/*
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(BUILD_FLAG) -o $(SOURCE_BINARY_FILE) $(SOURCE_MAIN_FILE)

pack:
	@echo "\n\rpacking...."
	@ls -lh $(SOURCE_BINARY_DIR)
	@docker build -t $(PROJECT) .