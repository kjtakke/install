#!/usr/bin/env bash
set -e

echo "🌟 Starting Zsh + NeoVim setup..."

# Update package lists
sudo apt update

# -----------------------------------------
# ZSH, Oh My Zsh, Starship
# -----------------------------------------
echo "🔧 Installing Zsh..."
sudo apt install zsh curl git unzip wget -y

echo "⚡ Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "🚀 Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

mkdir -p ~/.config
starship preset gruvbox-rainbow -o ~/.config/starship.toml

# Zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
echo "🔌 Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" || true
git clone https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM/plugins/zsh-autocomplete" || true

# Configure Zsh
echo "⚙️ Configuring .zshrc..."
cat << 'EOF' > ~/.zshrc
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions fast-syntax-highlighting zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# Load zsh-autocomplete LAST
source ~/.oh-my-zsh/custom/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
EOF

# Fonts
echo "🔤 Installing Nerd Fonts..."
mkdir -p ~/.fonts
cd ~/.fonts
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/DroidSansMono.zip
unzip -o DroidSansMono.zip
cd ~

# Change default shell
chsh -s /usr/bin/zsh

# -----------------------------------------
# NeoVim Installation
# -----------------------------------------
echo "📝 Installing NeoVim..."
sudo apt install ripgrep pylint shellcheck xclip pipx -y
pipx ensurepath
pipx install pynvim

curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf ./nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
echo "alias nvim='/opt/nvim-linux-x86_64/bin/nvim'" >> ~/.bashrc
echo "alias nvim='/opt/nvim-linux-x86_64/bin/nvim'" >> ~/.zshrc

# Node.js & LSP
echo "🌐 Installing Node.js and LSP servers..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pyright bash-language-server tree-sitter-cli

# Setup NeoVim config
mkdir -p ~/.config/nvim/lua/plugins
git clone https://github.com/kjtakke/neovim.git ~/nvim-clone
cp -f ~/nvim-clone/init.lua ~/.config/nvim/init.lua
cp -f ~/nvim-clone/search/nsearch.txt ~/.config/nvim/nsearch.txt
cp -f ~/nvim-clone/lazy-lock.json ~/.config/nvim/lazy-lock.json
cp -f ~/nvim-clone/lua/cmp.lua.bak ~/.config/nvim/lua/cmp.lua.bak
cp -f ~/nvim-clone/lua/init.lua ~/.config/nvim/lua/init.lua
cp -f ~/nvim-clone/lua/lsp.lua ~/.config/nvim/lua/lsp.lua
cp -f ~/nvim-clone/lua/plugins/init.lua ~/.config/nvim/lua/plugins/init.lua
git clone https://github.com/github/copilot.vim.git ~/.config/nvim/pack/github/start/copilot.vim
rm -rf ~/nvim-clone

echo "✅ Installation complete. Close and reopen your terminal, then run 'nvim' and ':Lazy' to finish plugin setup."
