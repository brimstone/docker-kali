if [ ! -e /root/.ssh/auth.sock ]; then
	eval $(ssh-agent -s) >/dev/null
	ln -s $SSH_AUTH_SOCK "/root/.ssh/auth.sock"
	echo $SSH_AGENT_PID > "/root/.ssh/auth.pid"
else
	export SSH_AUTH_SOCK=/root/.ssh/auth.sock
	export SSH_AGENT_PID="$(< "/root/.ssh/auth.pid")"
fi

urlencode () {
        old_lc_collate=$LC_COLLATE
        LC_COLLATE=C
        local length="${#1}"
        for ((i = 0; i < length; i++ )) do
                local c="${1:$i:1}"
                case $c in
                        ([a-zA-Z0-9.~_-]) printf "$c" ;;
                        (*) printf '%%%02X' "'$c" ;;
                esac
        done
        LC_COLLATE=$old_lc_collate
}

urldecode () {
        local url_encoded="${1//+/ }"
        printf '%b' "${url_encoded//\%/\\x}"
}

#TODO make this work:
#curl -A "Mozilla" https://user-agents.net/browsers/chrome -s | grep '/chrome/versions/' -m 1
alias nmap='nmap -g53 --randomize-hosts --script-args http.useragent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.0 Safari/537.36"'
