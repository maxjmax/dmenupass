#!/bin/bash
source ~/.profile

# check if we need to first unlock GPG:
# forced pinentry to popup before you can view the list
if [[ ! -z "$PASSWORD_STORE_GPGKEY" ]]; then
	echo 'bleh' | gpg --sign --local-user $PASSWORD_STORE_GPGKEY -o /dev/null
fi

# choose the password entry
dir=${PASSWORD_STORE_DIR-~/.password-store}
chosen=$(ls $dir/**/*.gpg | sed "s#${dir}/##" | sed 's/\.gpg//' | sort | dmenu -i -l 6) 
[ -z "$chosen" ] && exit 1

# now we have the entry, show a second menu
entries=$(pass show "$chosen")
password=$(echo "$entries" | head -n1)

function getEntry() {
	echo "$entries" | grep -e "^$1" | sed "s#$1##"
}

otp=$(getEntry "otpauth://")
login=$(getEntry "login: ")

menu=$(echo "$entries" | tail +2)

if [[ ! -z "$otp" ]]; then
	otpval=$(pass otp "$chosen")
	menu="OTP: $otpval
$menu"
fi

if [[ ! -z "$login" ]]; then
	menu="<type user+pass>
$menu"
fi

menu="<type password>
$menu"

action=$(echo "$menu" | dmenu -i -l 6)
[ -z "$action" ] && exit 1

if [[ "$action" = "<type password>" ]]; then
	pass show "$chosen" | head -n1 | xdotool type --clearmodifiers --file -
elif [[ "$action" = "<type user+pass>" ]]; then
	printf '%s\t%s' "$login" "$password" | xdotool type --clearmodifiers --file -

else
	echo "$action" | cut -d: -f 2-| xargs echo -n | xclip -selection clipboard
fi

