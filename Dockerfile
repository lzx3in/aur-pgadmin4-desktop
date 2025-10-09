FROM archlinux/archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      # Download source code
      git \
      # Required by makepkg itself
      sudo fakeroot debugedit binutils \
      # Download pgadmin4-server package
      jq wget

RUN TARGET_URL=$(curl -s https://api.github.com/repos/lzx3in/aur-pgadmin4-server/releases/tags/dev | jq -r '.assets[0].browser_download_url') && \
    wget ${TARGET_URL} && \
    pacman -U $(basename ${TARGET_URL}) --noconfirm

RUN useradd -m -u 1001 -s /bin/zsh builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /build && chown builder:builder /build && \
    mkdir /target && chown builder:builder /target

USER builder

WORKDIR /build

RUN git clone --branch dev https://github.com/lzx3in/aur-pgadmin4-desktop.git

RUN cd aur-pgadmin4-desktop && \
    makepkg -s --noconfirm

RUN mv /build/aur-pgadmin4-desktop/*.pkg.tar.zst /target/

ENTRYPOINT ["bash"]
