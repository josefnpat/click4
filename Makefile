PROJECT_SHORTNAME=Click4

LOVE=love
LOVE_VERSION=0.10.2
SRC_DIR=src
GIT_HASH=$(shell git log --pretty=format:'%h' -n 1 ${SRC_DIR})
GIT_COUNT=$(shell git log --pretty=format:'' ${SRC_DIR} | wc -l)
GIT_TARGET=${SRC_DIR}/git.lua
WORKING_DIRECTORY=$(shell pwd)

LOVE_TARGET=${PROJECT_SHORTNAME}.love

DEPS_DATA=dev/build_data
DEPS_DOWNLOAD_TARGET=https://bitbucket.org/rude/love/downloads/
DEPS_DOWNLOAD_LINUX_TARGET=http://50.116.63.25/public/love/
DEPS_WIN32_TARGET=love-${LOVE_VERSION}\-win64.zip
DEPS_WIN64_TARGET=love-${LOVE_VERSION}\-win32.zip
DEPS_MACOS_TARGET=love-${LOVE_VERSION}\-macosx-x64.zip
DEPS_LINUX_TARGET=love-${LOVE_VERSION}\-amd64.tar.gz

BUILD_INFO=v${GIT_COUNT}-[${GIT_HASH}]
BUILD_BIN_NAME=${PROJECT_SHORTNAME}_${BUILD_INFO}
BUILD_DIR=builds
BUILD_LOVE=${PROJECT_SHORTNAME}_${BUILD_INFO}
BUILD_WIN32=${PROJECT_SHORTNAME}_win32_${BUILD_INFO}
BUILD_WIN64=${PROJECT_SHORTNAME}_win64_${BUILD_INFO}
BUILD_MACOS=${PROJECT_SHORTNAME}_macosx_${BUILD_INFO}
BUILD_LINUX=${PROJECT_SHORTNAME}_linux64_${BUILD_INFO}

BUTLER=butler
BUTLER_VERSION=${GIT_COUNT}[git:${GIT_HASH}]
BUTLER_ITCHNAME=roguecraft-squadron
BUTLER_ITCHUSERNAME=josefnpat

ICON_DIR=src/assets/objects_icon

IMAGE_FILES := $(wildcard src/assets/objects/*.png)

-include Makefile.config

.PHONY: clean
clean:
	#Remove generated `${GIT_TARGET}`
	rm -f ${GIT_TARGET}

.PHONY: cleanlove
cleanlove:
	rm -f ${LOVE_TARGET}

.PHONY: love
love: clean
	#Writing ${GIT_TARGET}
	echo "git_hash,git_count = '${GIT_HASH}',${GIT_COUNT}" > ${GIT_TARGET}
	#Make love file
	cd ${SRC_DIR};\
	zip --filesync -x "*.swp" -r ../${LOVE_TARGET} *;\
	cd ..

.PHONY: run
run: love
	exec ${LOVE} --fused ${LOVE_TARGET} ${loveargs}

.PHONY: debug
debug: love
	exec ${LOVE} --fused ${SRC_DIR} --debug

.PHONY: cleandeps
cleandeps:
	rm -rf ${DEPS_DATA}

.PHONY: deps
deps:
	# Download binaries, and unpack
	mkdir -p ${DEPS_DATA}; \
	cd ${DEPS_DATA}; \
	\
	wget -t 2 -c ${DEPS_DOWNLOAD_TARGET}${DEPS_WIN32_TARGET};\
	unzip -o ${DEPS_WIN32_TARGET};\
	\
	wget -t 2 -c ${DEPS_DOWNLOAD_TARGET}${DEPS_WIN64_TARGET};\
	unzip -o ${DEPS_WIN64_TARGET};\
	\
	wget -t 2 -c ${DEPS_DOWNLOAD_TARGET}${DEPS_MACOS_TARGET};\
	unzip -o ${DEPS_MACOS_TARGET};\
	\
	wget -t 2 -c ${DEPS_DOWNLOAD_LINUX_TARGET}${DEPS_LINUX_TARGET};\
	tar xvf ${DEPS_LINUX_TARGET};\
	cd -

.PHONY: build_love
build_love: love
	mkdir -p ${BUILD_DIR}
	cp ${LOVE_TARGET} ${BUILD_DIR}/${BUILD_LOVE}.love

.PHONY: build_win32
build_win32: love
	mkdir -p ${BUILD_DIR}
	$(eval TMP := $(shell mktemp -d))
	cat ${DEPS_DATA}/love-${LOVE_VERSION}\-win32/love.exe ${LOVE_TARGET} > ${TMP}/${BUILD_BIN_NAME}.exe
	cp ${DEPS_DATA}/love-${LOVE_VERSION}\-win32/*.dll ${TMP}
	zip -rj ${BUILD_DIR}/${BUILD_WIN32} $(TMP)/*
	rm -rf $(TMP)

.PHONY: build_win64
build_win64: love
	mkdir -p ${BUILD_DIR}
	$(eval TMP := $(shell mktemp -d))
	cat ${DEPS_DATA}/love-${LOVE_VERSION}\-win64/love.exe ${LOVE_TARGET} > ${TMP}/${BUILD_BIN_NAME}.exe
	cp ${DEPS_DATA}/love-${LOVE_VERSION}\-win64/*.dll ${TMP}
	zip -rj ${BUILD_DIR}/${BUILD_WIN64} $(TMP)/*
	rm -rf $(TMP)

.PHONY: build_macos
build_macos: love
	mkdir -p ${BUILD_DIR}
	$(eval TMP := $(shell mktemp -d))
	cp ${DEPS_DATA}/love.app/ ${TMP}/${BUILD_BIN_NAME}.app -Rv
	cp ${LOVE_TARGET} ${TMP}/${BUILD_BIN_NAME}.app/Contents/Resources/${BUILD_BIN_NAME}.love
	cd ${TMP}; \
	zip -ry ${WORKING_DIRECTORY}/${BUILD_DIR}/${BUILD_MACOS}.zip ${BUILD_BIN_NAME}.app/
	cd ${WORKING_DIRECTORY}
	rm -rf $(TMP)

.PHONY: build_linux64
build_linux64: love
	mkdir -p ${BUILD_DIR}
	$(eval TMP := $(shell mktemp -d))
	cp -r ${DEPS_DATA}/love-${LOVE_VERSION}\-amd64/* ${TMP}
	mv ${TMP}/love ${TMP}/${BUILD_BIN_NAME}
	cp ${TMP}/usr/bin/love ${TMP}/usr/bin/love_bin
	cat ${TMP}/usr/bin/love_bin ${LOVE_TARGET} > ${TMP}/usr/bin/love
	cd ${TMP}; \
	zip -ry ${WORKING_DIRECTORY}/${BUILD_DIR}/${BUILD_LINUX}.zip *
	rm -rf $(TMP)

.PHONY: all
all: build_love build_win32 build_win64 build_macos build_linux64

.PHONY: deploy
deploy: all
	${BUTLER} login
	${BUTLER} push ${BUILD_DIR}/${BUILD_LOVE}.love ${BUTLER_ITCHUSERNAME}/${BUTLER_ITCHNAME}:love\
		--userversion ${BUTLER_VERSION}
	${BUTLER} push ${BUILD_DIR}/${BUILD_WIN32}.zip ${BUTLER_ITCHUSERNAME}/${BUTLER_ITCHNAME}:win32\
		--userversion ${BUTLER_VERSION}
	${BUTLER} push ${BUILD_DIR}/${BUILD_WIN64}.zip ${BUTLER_ITCHUSERNAME}/${BUTLER_ITCHNAME}:win64\
		--userversion ${BUTLER_VERSION}
	${BUTLER} push ${BUILD_DIR}/${BUILD_MACOS}.zip ${BUTLER_ITCHUSERNAME}/${BUTLER_ITCHNAME}:macosx\
		--userversion ${BUTLER_VERSION}
	${BUTLER} push ${BUILD_DIR}/${BUILD_LINUX}.zip ${BUTLER_ITCHUSERNAME}/${BUTLER_ITCHNAME}:linux64\
		--userversion ${BUTLER_VERSION}
	${BUTLER} status ${BUTLER_ITCHUSERNAME}/${BUTLER_ITCHNAME}

.PHONY: status
status:
	#VERSION: ${BUILD_INFO}
	butler status ${BUTLER_ITCHUSERNAME}/${BUTLER_ITCHNAME}
