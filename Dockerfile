FROM debian:12.0-slim

# Installing required packages for neovim
RUN apt update && \
    apt-get update && \
    apt install -y \
        curl \
        git \
        tar \
        unzip \
        vim \
        wget \
        make

# Setting-up locale
RUN apt install -y locales \
 && locale-gen ja_JP.UTF-8

# Installing neovim
RUN wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.tar.gz \
 && tar -zxvf nvim-linux64.tar.gz \
 && mv nvim-linux64/bin/nvim usr/bin/nvim \
 && mv nvim-linux64/lib/nvim usr/lib/nvim \
 && mv nvim-linux64/share/nvim/ usr/share/nvim \
 && rm -rf nvim-linux64 \
 && rm nvim-linux64.tar.gz


# Installing deno for Neovim's plugin
RUN curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh
# Installing node.js for Neovim's plugin
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt install -y nodejs

# Installing myneovimrc
RUN git clone https://github.com/xkazuma/myneovimrc.git -b main \
 && cd myneovimrc \
 && make pure-lua 
RUN nvim +:q \
 && nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

ENTRYPOINT ["nvim"]
