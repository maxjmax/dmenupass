#!/bin/bash
source ~/.profile

# check if we need to first unlock GPG:
# forced pinentry to popup before you can view the list
if [[ ! -z "$PASSWORD_STORE_GPGKEY" ]]; then
	echo 'bleh' | gpg --sign --local-user $PASSWORD_STORE_GPGKEY -o /dev/null
fi

# choose the password entry
dir=${PASSWORD_STORE_DIR-~/.password-store}
password=$(ls $dir/**/*.gpg | sed "s#${dir}/##" | sed 's/\.gpg//' | sort | dmenu -i -l 6) 
[ -z "$password" ] && exit 1

# now we have the entry, show a second menu (excluding the password on the first line)
entries=$(pass show "$password" | tail -n +2)

# if there is an otp entry, then generate the otp to insert
otpre='otpauth://'
if  [[ "$entries" =~ $otpre ]]; then
	otp=$(pass otp "$password")
	entries="OTP: $otp
$entries"
fi

# add a special entry that just types the password
entries="<type password>
$entries"

# TODO; username TAB password

action=$(echo "$entries" | dmenu -i -l 6)
[ -z "$action" ] && exit 1

if [[ "$action" = "<type password>" ]]; then
	pass show "$password" | head -n1 | xdotool type --clearmodifiers --file -
else
	echo "$action" | cut -d: -f 2-| xargs echo -n | xclip -selection clipboard
fi

