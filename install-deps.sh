#!/bin/bash
# Install nvim config dependencies on Debian/Ubuntu-based Linux
# Does NOT install nvim itself — use bob for that

set -e

echo "→ Installing JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  echo "   already installed, skipping"
else
  mkdir -p "$FONT_DIR"
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -O /tmp/JetBrainsMono.zip
  unzip -q /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  rm /tmp/JetBrainsMono.zip
  fc-cache -fv
  echo "   done — set 'JetBrainsMono Nerd Font' in your terminal preferences"
fi

echo "→ Installing system packages..."
sudo apt update
sudo apt install -y \
  gcc \
  libclang-dev \
  ripgrep \
  fd-find

echo "→ Installing fzf..."
if command -v fzf &>/dev/null && [[ $(fzf --version | cut -d' ' -f1) > "0.52" ]]; then
  echo "   already installed, skipping"
else
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --bin
  echo '' >> ~/.bashrc
  echo '# fzf' >> ~/.bashrc
  echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> ~/.bashrc
  echo "   done"
fi
# fd is installed as fdfind on Debian, fzf-lua expects fd
if ! command -v fd &>/dev/null; then
  sudo ln -sf $(which fdfind) /usr/local/bin/fd
fi

echo "→ Installing Rust toolchain..."
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

echo "→ Installing Rust tools..."
cargo install bob-nvim
cargo install tree-sitter-cli
cargo install stylua

echo "→ Installing Go tools..."
# Assumes go is already installed
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest

echo "→ Installing Node tools..."
# Assumes node/npm is already installed
npm install -g @fsouza/prettierd

echo "→ Installing Python tools..."
pip install ruff

echo "→ Done. Now:"
echo "   1. bob install stable && bob use stable"
echo "   2. Open nvim — Mason will auto-install LSP servers"
