#!/bin/bash

AWS_ACCOUNT_ID="775763617068"
AWS_DEFAULT_REGION="us-east-1"
REPOSITORY_NAME="build-test"
REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPOSITORY_NAME}"

COMMIT_HASH=$(echo $1 | cut -c 1-7)
IMAGE_TAG=${COMMIT_HASH:=latest}

# build docker image based on VERSION
docker build -t $REPOSITORY_URI:latest .

CODE=$?
[ $CODE -ne 0 ] && { echo "Docker image build error"; exit $CODE; }

docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG

# test VERSION property pattern (d or d.d or d.d.d where d equals digit)
VERSION=$(grep '"version":' package.json | awk -F'"' '{print $4}' | grep -Po "^(\d+\.)+\d+$" )

CODE=$?
[ $CODE -ne 0 ] && { echo "Version $VERSION: pattern matching error"; exit $CODE; }

# push version release to git if it do not exists and push docker image to docker repository
git ls-remote --heads 2>/dev/null | grep "refs/heads/$VERSION"

if [ $? -ne 0 ];
then
  docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$VERSION
#  docker push $REPOSITORY_URI:$VERSION

  git checkout -b $VERSION
  echo "git checkout: $?"

  git push origin $VERSION
  echo "git push: $?"
fi

#docker push $REPOSITORY_URI:latest
#docker push $REPOSITORY_URI:$IMAGE_TAG

exit 0