.PHONY: all hypr waybar kitty fish starship zellij wofi eww lightdm clean

DOTFILES := $(HOME)/dotfiles
CONFIG := $(HOME)/.config

all: hypr waybar kitty fish starship zellij wofi eww

hypr:
	stow -d $(DOTFILES) -t $(CONFIG) hypr

waybar:
	stow -d $(DOTFILES) -t $(CONFIG) waybar

kitty:
	stow -d $(DOTFILES) -t $(CONFIG) kitty

fish:
	stow -d $(DOTFILES) -t $(CONFIG) fish

starship:
	stow -d $(DOTFILES) -t $(CONFIG) starship

zellij:
	stow -d $(DOTFILES) -t $(CONFIG) zellij

wofi:
	stow -d $(DOTFILES) -t $(CONFIG) wofi

eww:
	stow -d $(DOTFILES) -t $(CONFIG) eww

lightdm:
	sudo stow -d $(DOTFILES) -t /etc/lightdm lightdm

clean:
	stow -D -d $(DOTFILES) -t $(CONFIG) hypr waybar kitty fish starship zellij wofi eww