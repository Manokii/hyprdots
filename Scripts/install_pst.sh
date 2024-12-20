#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Script to apply post install configs |--/ /-|#
#|-/ /--| Prasanth Rangan                      |-/ /--|#
#|/ /---+--------------------------------------+/ /---|#

scrDir=$(dirname "$(realpath "$0")")
source "${scrDir}/global_fn.sh"
if [ $? -ne 0 ]; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

# sddm
if pkg_installed sddm; then

    echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m detected // sddm"
    if [ ! -d /etc/sddm.conf.d ]; then
        sudo mkdir -p /etc/sddm.conf.d
    fi

    if [ ! -f /etc/sddm.conf.d/kde_settings.t2.bkp ]; then
        echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m configuring sddm..."
        echo -e "Select sddm theme:\n[1] Candy\n[2] Corners"
        read -p " :: Enter option number : " sddmopt

        case $sddmopt in
        1) sddmtheme="Candy" ;;
        *) sddmtheme="Corners" ;;
        esac

        sudo tar -xzf ${cloneDir}/Source/arcs/Sddm_${sddmtheme}.tar.gz -C /usr/share/sddm/themes/
        sudo touch /etc/sddm.conf.d/kde_settings.conf
        sudo cp /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/kde_settings.t2.bkp
        sudo cp /usr/share/sddm/themes/${sddmtheme}/kde_settings.conf /etc/sddm.conf.d/
    else
        echo -e "\033[0;33m[SKIP]\033[0m sddm is already configured..."
    fi

    if [ ! -f /usr/share/sddm/faces/${USER}.face.icon ] && [ -f ${cloneDir}/Source/misc/${USER}.face.icon ]; then
        sudo cp ${cloneDir}/Source/misc/${USER}.face.icon /usr/share/sddm/faces/
        echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m avatar set for ${USER}..."
    fi

else
    echo -e "\033[0;33m[WARNING]\033[0m sddm is not installed..."
fi

# dolphin
if pkg_installed dolphin && pkg_installed xdg-utils; then

    echo -e "\033[0;32m[FILEMANAGER]\033[0m detected // dolphin"
    xdg-mime default org.kde.dolphin.desktop inode/directory
    echo -e "\033[0;32m[FILEMANAGER]\033[0m setting" `xdg-mime query default "inode/directory"` "as default file explorer..."

else
    echo -e "\033[0;33m[WARNING]\033[0m dolphin is not installed..."
fi

# shell
"${scrDir}/restore_shl.sh"

# flatpak
if ! pkg_installed flatpak; then

    echo -e "\033[0;32m[FLATPAK]\033[0m flatpak application list..."
    awk -F '#' '$1 != "" {print "["++count"]", $1}' "${scrDir}/.extra/custom_flat.lst"
    prompt_timer 60 "Install these flatpaks? [Y/n]"
    fpkopt=${promptIn,,}

    if [ "${fpkopt}" = "y" ]; then
        echo -e "\033[0;32m[FLATPAK]\033[0m installing flatpaks..."
        "${scrDir}/.extra/install_fpk.sh"
    else
        echo -e "\033[0;33m[SKIP]\033[0m installing flatpaks..."
    fi

else
    echo -e "\033[0;33m[SKIP]\033[0m flatpak is already installed..."
fi

# nvm
if pkg_installed nvm
    then

    echo "Adding nvm to .zshrc"
    source /usr/share/nvm/init-nvm.sh
    echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.zshrc

    if command -v node &> /dev/null
        then
        echo "Node already installed, skipping installation..."
    else
        echo "Installing node"
        nvm install 20
        nvm use 20
    fi

    if command -v pnpm &> /dev/null
        then
        echo "PNPM already installed, skipping installation..."
    else 
      echo "Installing PNPM"
      curl -fsSL https://get.pnpm.io/install.sh | sh -
    fi

else
    echo "WARNING: nvm, node, and pnpm not installed..."
fi

if command -v tmux &> /dev/null
    then
    echo "Installing TMUX Plugin Manager"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || echo "Skipping TMUX Plugin Manager Installation"
    echo "Installing TMUX Plugins"
    sh ~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi


if pkg_installed fzf 
    then
    echo "Installing fzf-git.sh"

    if [ ! -d ~/Scripts ]; then 
      echo "Creating ~/Scripts folder"
      mkdir ~/Scripts
    fi

    curl "https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh" > ~/Scripts/fzf-git.sh
    echo "source ~/Scripts/fzf-git.sh" >> ~/.zshrc
fi

if pkg_installed bob 
    then
    echo "Installing neovim nightly using bob"
    bob use stable

    echo "Setting up neovim config"
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    git clone https://github.com/manokii/nvchad ~/.config/nvim
    cd ~/.config/nvim
    git remote remove origin
    git remote add origin git@github.com:Manokii/nvchad.git
    echo "alias vim='nvim'" >> ~/.zshrc

fi

if pkg_installed git-delta 
    then
    
    echo "Updating git config for delta"
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate "true"
    git config --global delta.line-numbers "true"
    git config --global merge.conflictstyle "diff3"
    git config --global diff.colorMoved "default"
fi


if pkg_installed ags-hyprpanel-git
    then
    echo "Setting up hyprpanel"
    cp ${cloneDir}/Source/assets/tuki.png ~/.config/hyprpanel/
    hyprpanel useTheme "$HOME/.config/hyprpanel/config.json"
fi

if pkg_installed bat
    then
    echo "Setting up bat theme (catppuccin latte)"
    batDir="$(bat --config-dir)/themes"
    mkdir -p "$batDir"
    curl https://raw.githubusercontent.com/catppuccin/bat/refs/heads/main/themes/Catppuccin%20Latte.tmTheme > "$batDir/catpuccin_latte.tmTheme"
    bat cache --build
fi

