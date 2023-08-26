FROM texlive/texlive:TL2022-historic

MAINTAINER xkzmdev<xkzm.dev@gmail.com>

###################################################
# Base Environment ################################
###################################################
ARG USER
ARG UID
ARG GID
# For WSL
ARG DISPLAY
ARG WAYLAND_DISPLAY
ARG NODE_VERSION=v18.17.1

# For GUI Applications 
ENV DISPLAY=$DISPLAY
ENV WAYLAND_DISPLAY=$WAYLAND_DISPLAY

# Preserving neovim config & plugins
########################
VOLUME myneovim:/home/${USER}

# Installing build tools
########################
RUN apt-get update -y \
 && apt-get install -y \
      build-essential \
      wget \
      ripgrep

# Setting-up locale ####
########################
RUN apt-get install -y locales \
 && locale-gen ja_JP.UTF-8

###################################################
# Deno & Node.js ##################################
###################################################
RUN curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh \
 && deno completions bash > /usr/share/bash-completion/completions/deno \
 && wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz \
 && tar -xJf node-${NODE_VERSION}-linux-x64.tar.xz -C /usr/local/lib/ \
 && rm node-${NODE_VERSION}-linux-x64.tar.xz \
 && chmod 755 -R /usr/local/lib/node-${NODE_VERSION}-linux-x64/bin \
 && export PATH=/usr/local/lib/node-${NODE_VERSION}-linux-x64/bin:$PATH \
 && . ~/.profile \
 && node -v \
 && npm version \
 && npx -v

###################################################
# TeXLive #########################################
###################################################
# Updating texlive, 
# and installing font collections 
# for Japanese
########################
COPY ./config/latexmkrc-qpdfview /home/${USER}/.latexmkrc
COPY ./config/qpdfview           /home/${USER}/.config/qpdfview
RUN tlmgr option repository ftp://tug.org/texlive/historic/2022/tlnet-final/ \
 && tlmgr update --all \
 && tlmgr install latexmk \ 
                  collection-langjapanese \
                  collection-fontsrecommended \
                  collection-fontutils \
                  collection-latexextra \
 && luaotfload-tool -v -vvv -u \
 && apt-get install -y \ 
      qpdfview 

###################################################
# Deno & Node.js ##################################
###################################################
RUN curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh \
 && apt-get install nodejs -y 

###################################################
# Python 3 ########################################
###################################################
RUN apt-get install -y \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    firefox-esr \
    fonts-stix \
 && wget https://www.python.org/ftp/python/3.10.1/Python-3.10.1.tgz \
 && tar -xf Python-3.10.1.tgz \
 && rm Python-3.10.1.tgz \
 && cd Python-3.10.1 \
 && ./configure --enable-optimizations \
 && make -j $(mproc) \
 && make altinstall \
 && ln -s /usr/local/bin/python3.10 /usr/local/bin/python3 \
 && ln -s /usr/local/bin/pip3.10 /usr/local/bin/pip3
# Jupynium requirements #
# - jupyter             #
# - mozilla driver      #
#########################
RUN python3 -m pip install --upgrade pip \
 && pip3 install notebook nbclassic jupyter-console \
 && wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz \
 && tar xzf geckodriver-v0.33.0-linux64.tar.gz \
 && rm geckodriver-v0.33.0-linux64.tar.gz \
 && mv geckodriver /usr/local/bin/ \
 && chmod 755 /usr/local/bin/geckodriver

###################################################
# Rust ############################################
###################################################
RUN wget -qO - https://sh.rustup.rs | RUSTUP_HOME=/opt/rust CARGO_HOME=/opt/rust sh -s -- --no-modify-path -y \
 && chmod 755 -R /opt/rust \
 && export RUSTUP_HOME=/opt/rust \
 && export PATH=/opt/rust/bin:$PATH \
 && rustup completions bash > /usr/share/bash-completion/completions/rustup \
 && rustc --version \
 && rustup --version \
 && cargo --version 
ENV RUSTUP_HOME /opt/rust 
ENV PATH        /opt/rust/bin:/home/${USER}/.cargo/bin:/usr/local/lib/node-${NODE_VERSION}-linux-x64/bin:$PATH


###################################################
# Neovim ##########################################
###################################################
RUN wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.tar.gz \
 && tar -zxvf nvim-linux64.tar.gz \
 && mv nvim-linux64/bin/nvim /usr/bin/nvim \
 && mv nvim-linux64/lib/nvim /usr/lib/nvim \
 && mv nvim-linux64/share/nvim/ /usr/share/nvim \
 && rm -rf nvim-linux64 \
 && rm nvim-linux64.tar.gz 

# Ctag requirements
#########################
RUN apt-get install -y universal-ctags

###################################################
# Before User Switch ##############################
###################################################
RUN mkdir /workspace \
 && groupadd -g ${GID} ${USER} \
 && useradd -d /home/${USER} -s /bin/bash -u ${UID} -g ${GID} ${USER} \
 && chown -R ${USER}:${USER} /workspace \
 && chown -R ${USER}:${USER} /home/${USER} \
 && chown -R ${USER}:${USER} /home/${USER}/.config \
 && apt-get clean && rm -rf /var/lib/apt/lists/*


###################################################
# Workspace Setup #################################
###################################################
USER ${USER}

WORKDIR /home/${USER}

# Treesitter install
#########################
RUN git clone https://github.com/tree-sitter/tree-sitter.git \
 && cargo install tree-sitter-cli

# Installing myneovimrc
#########################
RUN git clone https://github.com/xkazuma/myneovimrc.git -b main \
 && cd myneovimrc \
 && make install-pure-lua-for-docker \
 && nvim +:q \
 && nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

WORKDIR /workspace
