# .bashrc

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load user aliases
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# Load flatpak aliases
if [[ -f ~/.flatpak_aliases ]]; then
	while read line; do
		ALIAS=`echo $line | tr -s ' ' | cut -d' ' -f1`
		PACK=`echo $line | tr -s ' ' | cut -d' ' -f2`
		if [[ -n "$ALIAS" ]] && [[ -n "$PACK" ]]; then
			alias $ALIAS="flatpak run $PACK"
		fi
	done < <(sed 's/#.*//' ~/.flatpak_aliases)
fi

# Set defaul editor
export EDITOR=vim

# Set console prompt
PS1='\[\e[1m\][\[\e[92m\]\u\[\e[0m\]@\[\e[1;92m\]\h \[\e[94m\]\W\[\e[0;1m\]]$ \[\e[0m\]'
