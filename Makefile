EXEC=vosk
ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SERVER_DIR = ${ROOT}/tmp/${EXEC}
COMMON_DIR = ${ROOT}/tmp/common

PROJECT ?=github.com/e154/smart-home-vosk
VERSION_VAR=${PROJECT}/version.Version
RELEASE_VERSION ?= v0.0.0

GO_BUILD_LDFLAGS= -s -w -linkmode external -X ${VERSION_VAR}=${RELEASE_VERSION}
GO_BUILD_FLAGS= -buildmode=plugin -a -installsuffix -trimpath -v --ldflags '${GO_BUILD_LDFLAGS}'
GO_BUILD_ENV=CGO_ENABLED=1
GO_BUILD_TAGS= -tags 'production'
GO_TEST=test -tags test -v

GOOS ?=darwin
GOARCH ?=arm64

test:
	@echo MARK: unit tests
	#go ${GO_TEST} $(shell go list ./... | grep -v /tmp) -timeout 60s -race

test_without_race:
	@echo MARK: unit tests
	go ${GO_TEST} $(shell go list ./... | grep -v /tmp) -timeout 60s

lint:
	golangci-lint run

get_deps:
	go mod tidy

# darwin
build_darwin_arm64:
	@echo MARK: build darwin arm64
	rm -rf ${ROOT}/${EXEC}-darwin-arm64
	mkdir -p ${ROOT}/${EXEC}-darwin-arm64
	./vosk.sh darwin arm64 ${ROOT}/${EXEC}-darwin-arm64
	cp stttest.pcm ${ROOT}/${EXEC}-darwin-arm64
	cp manifest.json ${ROOT}/${EXEC}-darwin-arm64
	sed -i '' 's/__VERSION__/${RELEASE_VERSION}/g' ${ROOT}/${EXEC}-darwin-arm64/manifest.json
	sed -i '' 's/__ARCH__/arm64/g' ${ROOT}/${EXEC}-darwin-arm64/manifest.json
	sed -i '' 's/__OS__/darwin/g' ${ROOT}/${EXEC}-darwin-arm64/manifest.json
	sed -i '' 's/__LIB__/libvosk.dylib/g' ${ROOT}/${EXEC}-darwin-arm64/manifest.json
	cp LICENSE ${ROOT}/${EXEC}-darwin-arm64
	export CGO_LDFLAGS_ALLOW=".*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-darwin-arm64" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-darwin-arm64" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-darwin-arm64:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-darwin-arm64" && \
	${GO_BUILD_ENV} GOOS=${GOOS} GOARCH=${GOARCH} go build ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-darwin-arm64/plugin.so
	cd ${ROOT}/${EXEC}-darwin-arm64 && ls -l && tar -zcf ${ROOT}/${EXEC}-darwin-arm64.tar.gz .

# linux
build_linux_x86:
	@echo MARK: build linux x86
	rm -rf ${ROOT}/${EXEC}-linux-x86
	mkdir -p ${ROOT}/${EXEC}-linux-x86
	./vosk.sh linux x86 ${ROOT}/${EXEC}-linux-x86
	cp stttest.pcm ${ROOT}/${EXEC}-linux-x86
	cp manifest.json ${ROOT}/${EXEC}-linux-x86
	sed -i 's/__VERSION__/${RELEASE_VERSION}/g' ${ROOT}/${EXEC}-linux-x86/manifest.json
	sed -i 's/__ARCH__/x86/g' ${ROOT}/${EXEC}-linux-x86/manifest.json
	sed -i 's/__OS__/linux/g' ${ROOT}/${EXEC}-linux-x86/manifest.json
	sed -i 's/__LIB__/libvosk.so/g' ${ROOT}/${EXEC}-linux-x86/manifest.json
	cp LICENSE ${ROOT}/${EXEC}-darwin-arm64
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-linux-x86" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-linux-x86" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-x86:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-x86" && \
	${GO_BUILD_ENV} CXX='g++ -m32' CC='gcc -m32' GOOS=linux GOARCH=386 go build ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-linux-x86/plugin.so
	cd ${ROOT}/${EXEC}-linux-x86 && ls -l && tar -zcf ${ROOT}/${EXEC}-linux-x86.tar.gz .

build_linux_amd64:
	@echo MARK: build linux amd64
	rm -rf ${ROOT}/${EXEC}-linux-amd64
	mkdir -p ${ROOT}/${EXEC}-linux-amd64
	./vosk.sh linux x86_64 ${ROOT}/${EXEC}-linux-amd64
	cp stttest.pcm ${ROOT}/${EXEC}-linux-amd64
	cp manifest.json ${ROOT}/${EXEC}-linux-amd64
	sed -i 's/__VERSION__/${RELEASE_VERSION}/g' ${ROOT}/${EXEC}-linux-amd64/manifest.json
	sed -i 's/__ARCH__/amd64/g' ${ROOT}/${EXEC}-linux-amd64/manifest.json
	sed -i 's/__OS__/linux/g' ${ROOT}/${EXEC}-linux-amd64/manifest.json
	sed -i 's/__LIB__/libvosk.so/g' ${ROOT}/${EXEC}-linux-amd64/manifest.json
	cp LICENSE ${ROOT}/${EXEC}-linux-amd64
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-linux-amd64" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-linux-amd64" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-amd64:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-amd64" && \
	${GO_BUILD_ENV} GOOS=linux GOARCH=amd64 go build ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-linux-amd64/plugin.so
	cd ${ROOT}/${EXEC}-linux-amd64 && ls -l && tar -zcf ${ROOT}/${EXEC}-linux-amd64.tar.gz .

build_linux_armv6:
	@echo MARK: build linux armv6
	rm -rf ${ROOT}/${EXEC}-linux-arm-6
	mkdir -p ${ROOT}/${EXEC}-linux-arm-6
	./vosk.sh linux armv7l ${ROOT}/${EXEC}-linux-arm-6
	cp stttest.pcm ${ROOT}/${EXEC}-linux-arm-6
	cp manifest.json ${ROOT}/${EXEC}-linux-arm-6
	sed -i 's/__VERSION__/${RELEASE_VERSION}/g' ${ROOT}/${EXEC}-linux-arm-6/manifest.json
	sed -i 's/__ARCH__/arm/g' ${ROOT}/${EXEC}-linux-arm-6/manifest.json
	sed -i 's/__OS__/linux/g' ${ROOT}/${EXEC}-linux-arm-6/manifest.json
	sed -i 's/__LIB__/libvosk.so/g' ${ROOT}/${EXEC}-linux-arm-6/manifest.json
	cp LICENSE ${ROOT}/${EXEC}-linux-arm-6
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-linux-arm-6" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-linux-arm-6" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm-6:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm-6" && \
	${GO_BUILD_ENV} CC=arm-linux-gnueabihf-gcc GOOS=linux GOARCH=arm GOARM=6 go build ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-linux-arm-6/plugin.so
	cd ${ROOT}/${EXEC}-linux-arm-6 && ls -l && tar -zcf ${ROOT}/${EXEC}-linux-arm-6.tar.gz .

build_linux_armv7l:
	@echo MARK: build linux armv7l
	rm -rf ${ROOT}/${EXEC}-linux-arm-7
	mkdir -p ${ROOT}/${EXEC}-linux-arm-7
	./vosk.sh linux armv7l ${ROOT}/${EXEC}-linux-arm-7
	cp stttest.pcm ${ROOT}/${EXEC}-linux-arm-7
	cp manifest.json ${ROOT}/${EXEC}-linux-arm-7
	sed -i 's/__VERSION__/${RELEASE_VERSION}/g' ${ROOT}/${EXEC}-linux-arm-7/manifest.json
	sed -i 's/__ARCH__/arm/g' ${ROOT}/${EXEC}-linux-arm-7/manifest.json
	sed -i 's/__OS__/linux/g' ${ROOT}/${EXEC}-linux-arm-7/manifest.json
	sed -i 's/__LIB__/libvosk.so/g' ${ROOT}/${EXEC}-linux-arm-7/manifest.json
	cp LICENSE ${ROOT}/${EXEC}-linux-arm-7
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-linux-arm-7" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-linux-arm-7" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm-7:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm-7" && \
	${GO_BUILD_ENV} CC=arm-linux-gnueabihf-gcc GOOS=linux GOARCH=arm GOARM=7 go build ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-linux-arm-7/plugin.so
	cd ${ROOT}/${EXEC}-linux-arm-7 && ls -l && tar -zcf ${ROOT}/${EXEC}-linux-arm-7.tar.gz .

build_linux_arm64:
	@echo MARK: build linux arm64
	rm -rf ${ROOT}/${EXEC}-linux-arm64
	mkdir -p ${ROOT}/${EXEC}-linux-arm64
	./vosk.sh linux aarch64 ${ROOT}/${EXEC}-linux-arm64
	cp stttest.pcm ${ROOT}/${EXEC}-linux-arm64
	cp manifest.json ${ROOT}/${EXEC}-linux-arm64
	sed -i 's/__VERSION__/${RELEASE_VERSION}/g' ${ROOT}/${EXEC}-linux-arm64/manifest.json
	sed -i 's/__ARCH__/arm64/g' ${ROOT}/${EXEC}-linux-arm64/manifest.json
	sed -i 's/__OS__/linux/g' ${ROOT}/${EXEC}-linux-arm64/manifest.json
	sed -i 's/__LIB__/libvosk.so/g' ${ROOT}/${EXEC}-linux-arm64/manifest.json
	cp LICENSE ${ROOT}/${EXEC}-linux-arm64
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-linux-arm64" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-linux-arm64" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm64:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm64" && \
	${GO_BUILD_ENV} CC=aarch64-linux-gnu-gcc GOOS=linux GOARCH=arm64 go build ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-linux-arm64/plugin.so
	cd ${ROOT}/${EXEC}-linux-arm64 && ls -l && tar -zcf ${ROOT}/${EXEC}-linux-arm64.tar.gz .

