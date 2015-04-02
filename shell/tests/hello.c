#include <stdio.h>

main(int argc, char** argv) {
	printf("Hello shell!\n");
	printf("Here are args: \n");
	int i = 0;
	for (i = 0; i < argc; i++){
		printf("\t%s\n", argv[i]);
	}
}