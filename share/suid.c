int main(void){
	setreuid(geteuid(), geteuid());
	setregid(geteuid(), geteuid());
	system("/bin/sh");
}
