latest: Dockerfile
	docker build -t brimstone/kali .

%-build:
	docker build -t brimstone/kali:$* -f Dockerfile.$* .

%-push:
	docker push brimstone/kali:$*
