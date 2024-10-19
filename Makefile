EXEC=vosk
ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SERVER_DIR = ${ROOT}/tmp/${EXEC}
COMMON_DIR = ${ROOT}/tmp/common

PROJECT ?=github.com/e154/smart-home-vosk
VERSION_VAR=${PROJECT}/version.Version

GO_BUILD_LDFLAGS= -s -w -linkmode external -X ${VERSION_VAR}=${RELEASE_VERSION}
GO_BUILD_FLAGS= -trimpath -buildmode=plugin -a -installsuffix cgo -v --ldflags '${GO_BUILD_LDFLAGS}'
GO_BUILD_ENV=CGO_ENABLED=1
GO_BUILD_TAGS= -tags 'production'
GO_TEST=test -tags test -v

test:
	@echo MARK: unit tests
	go ${GO_TEST} $(shell go list ./... | grep -v /tmp | grep -v /tests) -timeout 60s -race -covermode=atomic -coverprofile=coverage.out

test_without_race:
	@echo MARK: unit tests
	go ${GO_TEST} $(shell go list ./... | grep -v /tmp | grep -v /tests) -timeout 60s -covermode=atomic -coverprofile=coverage.out

lint-todo:
	@echo MARK: make lint todo

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
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-linux-arm64" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-linux-arm64" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm64:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-linux-arm64" && \
	${GO_BUILD_ENV} CC=aarch64-linux-gnu-gcc GOOS=linux GOARCH=arm64 go build ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-linux-arm64/plugin.so
	cd ${ROOT}/${EXEC}-linux-arm64 && ls -l && tar -zcf ${ROOT}/${EXEC}-linux-arm64.tar.gz .

## windows
build_windows_amd64:
	@echo MARK: build windows amd64
	rm -rf ${ROOT}/${EXEC}-windows-amd64
	mkdir -p ${ROOT}/${EXEC}-windows-amd64
	./vosk.sh win win64 ${ROOT}/${EXEC}-windows-amd64
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-windows-amd64" && \
	export CGO_LDFLAGS="-L${ROOT}/${EXEC}-windows-amd64 -lvosk -L/usr/lib/x86_64-linux-gnu -ldl -lpthread" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-windows-amd64:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-windows-amd64" && \
	${GO_BUILD_ENV} CXX=x86_64-w64-mingw32-g++ CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 go build -ldflags ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-windows-amd64/plugin.ddl
	cd ${ROOT}/${EXEC}-windows-amd64 && ls -l && tar -zcf ${ROOT}/${EXEC}-windows-amd64.tar.gz .

build_windows_x86:
	@echo MARK: build windows x86
	rm -rf ${ROOT}/${EXEC}-windows-x86
	mkdir -p ${ROOT}/${EXEC}-windows-x86
	./vosk.sh win win32 ${ROOT}/${EXEC}-windows-x86
	export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" && \
	export CGO_CFLAGS="-I${ROOT}/${EXEC}-windows-x86" && \
	export CGO_LDFLAGS="-L/usr/local/lib -L/usr/lib -L${ROOT}/${EXEC}-windows-x86 -lvosk -L/usr/lib/i386-linux-gnu -ldl -lpthread" && \
	export LD_LIBRARY_PATH="${ROOT}/${EXEC}-windows-x86:$LD_LIBRARY_PATH" && \
	export DYLD_LIBRARY_PATH="${ROOT}/${EXEC}-windows-x86" && \
	${GO_BUILD_ENV} CXX=i686-w64-mingw32-g++ CC=i686-w64-mingw32-gcc GOOS=windows GOARCH=386 go build -ldflags ${GO_BUILD_FLAGS} ${GO_BUILD_TAGS} -o ${ROOT}/${EXEC}-windows-x86/plugin.ddl
	cd ${ROOT}/${EXEC}-windows-x86 && ls -l && tar -zcf ${ROOT}/${EXEC}-windows-x86.tar.gz .
