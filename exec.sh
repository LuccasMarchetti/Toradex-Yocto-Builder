docker build \
  --build-arg GIT_USER_NAME="" \
  --build-arg GIT_USER_EMAIL="" \
  -t yocto-builder .
docker run --rm -it -v "$(pwd):/oe-core" yocto-builder
