#!/bin/bash

DBASE="Dockerfile.temp_branch"
TAGBASE="jivanyatra/maildump"
VERSION=1.2
AMD="amd64"
ARM="arm64"
TAGTAIL="testing"

GIT_AUTH_TOKEN=$(cat ~/path/to/token)

# build x86_64 images
docker buildx build --secret id=GIT_AUTH_TOKEN --no-cache -f $DBASE --push -t $TAGBASE:$VERSION-$AMD-$TAGTAIL .
docker buildx build --secret id=GIT_AUTH_TOKEN --no-cache -f $DBASE.alpine --push -t $TAGBASE:$VERSION-$AMD-$TAGTAIL-alpine .

# Set up arm qemu ::

# install deps, if not present / comment when done
#sudo apt-get install qemu binfmt-support qemu-user-static # Install the qemu packages

# execute registering scripts - needs to be done every reboot
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# test container to see if it's working / should return "aarch64"
#docker run --platform=linux/arm64/v8 --rm -t arm64v8/ubuntu uname -m # Testing the emulation environment

# build arm64 images
docker buildx build --secret id=GIT_AUTH_TOKEN --platform linux/arm64 --no-cache -f $DBASE.arm64 --push -t $TAGBASE:$VERSION-$ARM-$TAGTAIL .
docker buildx build --secret id=GIT_AUTH_TOKEN --platform linux/arm64 --no-cache -f $DBASE.alpine.arm64 --push -t $TAGBASE:$VERSION-$ARM-$TAGTAIL-alpine .

# build manifests for debian-based (slim) and push
docker manifest create $TAGBASE:$VERSION-$TAGTAIL \
--amend $TAGBASE:$VERSION-$AMD-$TAGTAIL \
--amend $TAGBASE:$VERSION-$ARM-$TAGTAIL
docker manifest push $TAGBASE:$VERSION-$TAGTAIL

# build manifests for alpine-based and push
docker manifest create $TAGBASE:$VERSION-$TAGTAIL-alpine \
--amend $TAGBASE:$VERSION-$AMD-$TAGTAIL-alpine \
--amend $TAGBASE:$VERSION-$ARM-$TAGTAIL-alpine
docker manifest push $TAGBASE:$VERSION-$TAGTAIL-alpine