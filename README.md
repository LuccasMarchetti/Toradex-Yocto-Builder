# Toradex-Yocto-Builder

This repository provides a Dockerfile and a set of ready-to-use commands to simplify building Yocto-based system images for Toradex devices. The container includes essential tools and configurations to streamline the build process on different development environments.

---

⚠️ **This is a personal project and is not officially affiliated with or endorsed by Toradex.**

---

## What’s included

- Dockerfile to build a lightweight container with all necessary Yocto dependencies.
- Cross-compilation tools and libraries tailored for Toradex.
- A volume-based workflow to keep the Docker image small and your source code safe on the host machine.

---

## Purpose

To provide an easy-to-use, consistent, and reproducible Docker environment that helps developers build Yocto images for Toradex devices without worrying about host system differences.

---

## Getting Started

### 1. Build the Docker Image
First, build the environment image. Don't forget to replace the `GIT_USER_NAME` and `GIT_USER_EMAIL` with your own credentials, as Yocto requires Git to be configured.

```bash
docker build \
  --build-arg GIT_USER_NAME="Your Name" \
  --build-arg GIT_USER_EMAIL="your.email@example.com" \
  -t yocto-builder .
```

### 2. Run the Container
Start the container mapping your local Workspace to the internal /oe-core directory.

```bash
docker run -it --name yocto-env -v $PWD/Workspace:/oe-core yocto-builder
```

### 3. Download the Source Code (Inside the Container)
Once inside the container, initialize the Toradex repository. This setup uses the latest 7.x.y release (Yocto 5.0 Scarthgap)

Note: You only need to run this the first time.

```bash
repo init -u git://git.toradex.com/toradex-manifest.git -b scarthgap-7.x.y -m tdxref/default.xml
repo sync -j$(nproc)
```

### 4. Build the Image
To start the compilation, you need to source the environment and run bitbake. You can run these commands directly in the container's terminal:

```bash
. export
PARALLEL_MAKE="-j 4" BB_NUMBER_THREADS="6" bitbake tdx-reference-multimedia-image
```
(Adjust -j 4 and BB_NUMBER_THREADS="6" according to your host machine's CPU cores and RAM).

or execute the script "compile.sh".

Stopping and Resuming Work
When you type exit or close the terminal, the container will stop. Do not use docker run again, as it will try to create a new, completely separate container.

To resume your work exactly where you left off, simply start the existing container and attach a bash session to it:

```bash
docker start yocto-env
docker exec -it yocto-env bash
Once inside, just run . export again and you are ready to continue building or compiling your recipes!
```