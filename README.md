# kali
Docker images for various bits of Kali linux

## Requirements
* Docker

## Installation
* Nope

## Usage
1. First start a postgres container: `docker run --name postgres --rm -i brimstone/kali:postgres`
1. Then start a metasploit container: `docker run --rm --link postgres:postgres -t -i brimstone/kali:metasploit`
