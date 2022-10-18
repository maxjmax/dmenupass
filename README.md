# dmenupass

Bash script to use pass with dmenu

Requires:
- xdotool
- xclip
- pass
- pass otp (optional)

First shows a list of entries, then prompts again for an action:
- type the password
- copy one of the other fields
- copy an OTP token

If you have `PASSWORD_STORE_GPGKEY` set, the script will check if your gpg agent is unlocked, and prompt for password if not.
