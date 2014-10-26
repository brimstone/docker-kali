latest: Dockerfile
	docker build -t brimstone/kali .

metasploit: Dockerfile.metasploit
	docker build -t brimstone/kali:metasploit - < Dockerfile.metasploit

postgres: Dockerfile.postgres
	docker build -t brimstone/kali:postgres - < Dockerfile.postgres

big: Dockerfile.big
	docker build -t brimstone/kali:big - < Dockerfile.big
