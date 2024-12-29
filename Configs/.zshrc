# Oh-my-zsh installation path
ZSH=/usr/share/oh-my-zsh/

plugins=()
source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect AUR wrapper
if pacman -Qi yay &>/dev/null; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

function cpconfig() {
    cp ~/.config/hypr/hyprland.conf ~/.config/hypr/keybindings.conf ~/.config/hypr/userprefs.conf ~/hyprdots/Configs/.config/hypr/
    cp ~/.config/kitty/userprefs.conf ~/hyprdots/Configs/.config/kitty/
    cp ~/.config/hyprpanel/config.json ~/hyprdots/Configs/.config/hyprpanel/
} 

# Helpful aliases
alias  c='clear' # clear terminal
alias  l='eza -lha  --icons=auto --sort=name --group-directories-first --no-permissions --no-user' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code' # gui code editor

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'
alias ssh='kitten ssh'

alias r='source ~/.zshrc'
alias x='clear'
alias config='cd ~/.config && vim .'
alias zshconfig='vim ~/.zshrc'
alias q='exit'
alias t='tmux'
alias repos='cd ~/Repos'
alias undogit='git reset --soft HEAD~1'
alias cleantsconfig="sed -i -r '/^[ \t]*\//d; /^[[:space:]]*$/d; s/\/\*(.*?)\*\///g; s/[[:blank:]]+$//' tsconfig.json"

alias a='git add .'
alias s='git status -s'
alias c='git commit'
alias g='git log --oneline --graph --decorate'
alias gl='git log --oneline --decorate --reverse'

alias ds='systemctl start docker'
alias dkill='sudo docker kill $(sudo docker ps -q)'
alias ld='sudo lazydocker'
alias mac='ssh $MAC_HOST'
alias pip='pyenv exec pip install'

bindkey "^H" backward-delete-word

eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"

export MAC_HOST='jasper.concepcion@PHPMACTHHPX4QJT'
export SSH_AUTH_SOCK=~/.1password/agent.sock
export EDITOR='nvim'

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"


export PATH="$PATH:/home/manok/.local/share/bob/nvim-bin"
export BAT_THEME='catpuccin_latte'

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

