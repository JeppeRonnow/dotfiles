#
# ~/.bashrc
#

eval "$(starship init bash)"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='eza -l --icons'
alias ll='eza -lah --icons'
alias la='eza -la --icons'

alias vi='nvim'
alias vim='nvim'

alias grep='grep --color=auto'

alias theme_selecter='$HOME/dotfiles/scripts/theme_selecter.sh'

PS1='[\u@\h \W]\$ 'theme

# darktheme
export GDK_DARK_MODE=1

# GTK Theme
export GTK_THEME=Arc-Dark

# Qt Theme
export QT_QPA_PLATFORMTHEME=qt5ct

# Cursor
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

export HYPRSHOT_DIR="$HOME/pictures/screenshots"
