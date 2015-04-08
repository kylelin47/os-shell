#include <stdio.h>

int Fibonacci(int n)
{
   if ( n == 0 )
      return 0;
   else if ( n == 1 )
      return 1;
   else
      return ( Fibonacci(n-1) + Fibonacci(n-2) );
} 

main(int argc, char** argv) {
	printf("Calculating a big number!\n");
	int i = 0;
	int f = 0;
	for (i = 0; i < 43; i++) {
		f = Fibonacci(i);
	}

	printf("Fib is done!!\n");
}
