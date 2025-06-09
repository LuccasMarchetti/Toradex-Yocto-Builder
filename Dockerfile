# Base Ubuntu 22.04
FROM ubuntu:22.04

ARG GIT_USER_NAME
ARG GIT_USER_EMAIL

ENV GIT_USER_NAME=${GIT_USER_NAME}
ENV GIT_USER_EMAIL=${GIT_USER_EMAIL}

ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências básicas e configura locale
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Instala dependências principais para Yocto build
RUN apt-get update && apt-get install -y --no-install-recommends \
    gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio \
    python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 python3-subunit zstd liblz4-tool file libacl1 \
    make inkscape \
    && rm -rf /var/lib/apt/lists/*

# Instala dependências para documentação (TeX e Sphinx)
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-latex-extra sphinx python3-saneyaml python3-sphinx-rtd-theme \
    && rm -rf /var/lib/apt/lists/*

# Instala curl, openssh-client e gpg
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl openssh-client gpg gnupg-agent \
    && rm -rf /var/lib/apt/lists/*

# Cria usuário normal e diretórios necessários
RUN useradd -m builder && \
    mkdir -p /oe-core/build && \
    chown -R builder:builder /oe-core

USER builder

# Instala o repo manualmente no ~/bin do builder
RUN mkdir -p /home/builder/bin && \
    curl https://commondatastorage.googleapis.com/git-repo-downloads/repo -o /home/builder/bin/repo && \
    chmod a+x /home/builder/bin/repo

ENV PATH="/home/builder/bin:${PATH}"

WORKDIR /oe-core

# Configura git e inicializa o repo sem prompts interativos e com cores habilitadas
RUN if [ -z "${GIT_USER_NAME}" ] || [ -z "${GIT_USER_EMAIL}" ]; then \
      echo "GIT_USER_NAME e GIT_USER_EMAIL devem ser definidos!"; exit 1; \
    fi && \
    git config --global user.name "${GIT_USER_NAME}" && \
    git config --global user.email "${GIT_USER_EMAIL}" && \
    git config --global color.ui true && \
    repo init -u git://git.toradex.com/toradex-manifest.git -b scarthgap-7.x.y -m tdxref/default.xml --config-name && \
    repo sync -j$(nproc)

ENTRYPOINT ["/bin/bash"]
