docker build \
  --build-arg GIT_USER_NAME="" \
  --build-arg GIT_USER_EMAIL="" \
  -t yocto-builder .
docker run -it --name yocto-env -v $PWD/Workspace:/oe-core yocto-builder