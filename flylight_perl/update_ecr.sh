#!/bin/bash
if [ $# -eq 0 ]; then
  REPO=`pwd | awk -F"/" '{print $NF}'`
  VERSION=0.0.1
elif [ $# -eq 1 ]; then
  REPO=$1
  VERSION=0.0.1
else
  REPO=$1
  VERSION=$2
fi
LATEST=`echo $REPO:latest`
VERSIONED=`echo $REPO:$VERSION`
read -p "Do you want to build and push $VERSIONED? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
echo "Authenticating"
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/janeliascicomp
echo  "Building $LATEST"
docker image build . --no-cache -t $REPO --platform linux/amd64
docker tag $LATEST public.ecr.aws/janeliascicomp/jenkins/$VERSIONED
echo "Pushing $VERSIONED"
docker push public.ecr.aws/janeliascicomp/jenkins/$VERSIONED
