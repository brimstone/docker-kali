if [ ! -e /root/.ssh/auth.sock ]; then
	eval $(ssh-agent -s) >/dev/null
	ln -s $SSH_AUTH_SOCK "/root/.ssh/auth.sock"
	echo $SSH_AGENT_PID > "/root/.ssh/auth.pid"
else
	export SSH_AUTH_SOCK=/root/.ssh/auth.sock
	export SSH_AGENT_PID="$(< "/root/.ssh/auth.pid")"
fi
