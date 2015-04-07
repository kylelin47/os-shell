#OS SHELL README

A Linux shell written in LEX/YACC, by Kyle Lin and Joachim Jones.

Our code is contained within the node.h, shell.l, and shell.y files.

#Missing Features

- File Name Completion
- Pipe and I/O of built-in commands

#Features

- All built-in commands (setenv, printenv, unsetenv, cd, alias, unalias)
- Running commands with any number of arguments (i.e. 'ls -l'). Searches on path if '/' not present in command name.
- Environment variable expansion
- Aliasing support and checking for infinite alias expansion
- IO redirection: stdout, stderr, and stdin can all be redirected
- Pipe support for any number of pipes
- '&' support for program completion in background if desired
- Wildcard matching with the '*' and '?' characters
- Prints errors to stderr with a description of the problem and the offending line number
- Handles escaping. echo "my \"string" will output my "string
- EXTRA CREDIT: Tilde expansion also supported. ~name will expand to name's home directory, ~ will expand to current user's home if at the beginning of a word and will not occur on quoted strings. PATH will tilde expand on each colon-separated word.


#Code Structure

node.h
- Defines a linked list node for use in both shell.l and shell.y

shell.l:
- Reads in the input, defines input as WORDs, ARGs, and TERMINATORs
- Handles words in quotes and reads in as single word
- Handles '~', '*', and '?' cases (meaning wildcard matching and more)

shell.y:
- Has the bulk of our C code
- Reads in WORDs and forms a linked list of WORDs to be used as arguments
- Has various linked-list related functions, as well as string manipulation functions
- Also has the core functions:
	- alias(arg_node* args) to push an alias to the list of aliases
	- unalias(arg_node* args) to remove from list of aliases
	- arg_node* nested_alias_replace(arg_node* args) to recursively replace words with their aliases
	- cd(arg_node* args) to handle the "cd" built in command
	- set_environment(arg_node* args) to add an envrionment variable
	- remove_environment(arg_node* args) to remove an env variable
	- run_command(arg_node* args) which is the big function which will do these for every pipe:
		- call nested_alias_replace(..) on the command
		- if the command is built in, perform built-in command
		- search in the path for the command, return error if not found
		- looks in the list of arguments for the IO-redirection keywords and redirect stdout, stdin, or stderr if desired
		- calls exeve(..) on the command with the list of args
		- waits for child processes to complete if & is not present


#TO RUN SHELL
A Makefile is included with our shell project submission. Simply run 'make' and then './shell.out' to run our shell.

Tested on Ubuntu 14.04.2 64-bit and the CISE lab machines. Lex and Yacc must be installed.


#TESTS

- BUILT IN FUNCTIONALITY

	- ENVIRONMENT VARIABLE TESTING:
		- Check setting, printing, and unsetting env variables:
		> setenv myvarry happyos
		> setenv "w quotes" "works too"
		> printenv
		OUTPUT:
			... a bunch of preset environment variables like PATH, LANGUAGE, etc
			myvarry=happyos
			w quotes=works too
		> unsetenv myvarry
		> unsetenv "w quotes"
		OUTPUT:
			... a bunch of preset environment variables like PATH, LANGUAGE, etc
			... no longer has myvarry or "w quotes"

	- CHANGE DIRECTORY FUNCTIONALITY
		- Check basic cd:
		> ls
		OUTPUT:
			... files in the /shell folder, like shell.out, shell.l, etc
		> cd
		> ls
		OUTPUT:
			... files in home, like Desktop, Downloads, Documents, Public, etc

		- Check cd with tilde, should go to the OS-Shell folder:
		> cd ~/OS-Shell
		> ls
		OUTPUT:
			LICENSE.md README.md shell

		- Check cd error checking, make sure it tells user that invalid path can't be found:
		> cd asdfasdfasdf
		OUTPUT:
			error at line 18: path 'asdfasdfasdf' not found

		- More advanced functionality, check ${HOME}
		> cd ${HOME}/OS-Shell
		> ls
		OUTPUT:
			LICENSE.md README.md shell

	- ALIAS TESTING:
		- First, check basic functionality. Set an alias "lsdashl" to execute "ls -l":
		> alias lsdashl "ls -l"
		> lsdashl
		OUTPUT:
			total 277
			-rwxrwxrwx 1 root root 8543 Mar 31 17:42 lex.yy.c
			... etc

		- Next, check chaining of aliases. Set alias "chainylsl" to "lsdashl" (which is set to "ls -l"):
		> alias chainylsl "lsdashl"
		> chainylsl
		OUTPUT:
			total 277
			-rwxrwxrwx 1 root root 8543 Mar 31 17:42 lex.y.c
			... etc

		- Next, check that an infinite loop of aliases will be caught and dealt with:
		> alias bad "good"
		> alias good "bad"
		> good
		OUTPUT:
			error at line 8: infinite alias expansion

	- BYE FUNCTIONALITY:
		- Bye should quit the shell gracefully.
		> bye
		... goes back to /shell folder and the basic Linux shell

	- BASIC ERROR CHECKING:
		> e r r o r
		OUTPUT:
			error at line 28: command 'e' not found


- OTHER COMMAND FUNCTIONALITY

	- COMMANDS WITH MULTIPLE ARGUMENTS
		- For example, "ls -l -h"
		> ls -l -h
		OUTPUT:
			-rwxrwxrwx 1 root root 8.4K Mar 31 17:42 lex.yy.c
			... etc, all with human readability (-h) and long listing (-l)

	- COMMANDS WITH I/O REDIRECTION
		- Check sending the output of "ls -l -h" to a file, 'mytest.txt'
		> ls -l -h > mytest.txt
		IN 'mytest.txt':
			-rwxrwxrwx 1 root root 8.4K Mar 31 17:42 lex.yy.c
			... etc, same as above

		- Check redirection of input
		'wc < mytest.txt' should have same result as 'wc mytest.txt', but one uses std input instead of just reading from the file.
		> wc < mytest.txt
		OUTPUT:
			19 164 902
		> wc mytest.txt
		OUTPUT:
			19 164 902 mytest.txt

		- Check redirection of std err
		'not_there.foo' doesn't exist and should give an error and put it in myerr.txt
		> ls -l -h not_there.foo 2>myerr.txt
		IN 'myerr.txt':
			/bin/ls: cannot access not_there.foo: No such file or directory

	- PIPE FUNCTIONALITY
		- Check one pipe, get first 3 files in directory with ls and piping
		> ls
		OUTPUT:
			built-in.test.txt fib.c hello.c hello.cpp
		> ls | head -3
		OUTPUT:
			built-in.test.txt
			fib.c
			hello.c

		- Check mulitple pipes, get only the third file
		> ls
		OUTPUT:
			built-in.test.txt fib.c hello.c hello.cpp
		> ls | head -3 | tail -1
		OUTPUT:
			hello.c

		- Check combination of pipes and I/O redirection
		> ls | head -3 | tail -2 > myresult.txt
		IN myresult.txt:
			fib.c
			hello.c

- MISC FUNCTIONALITY (&, ~, *, ?, etc)
	
	- & FUNCTIONALITY:
	Have a program, 'fibby', which takes around 10 seconds to complete.
		
		- Make sure shell waits for completion if no '&'
		> ./fibby
		OUTPUT:
			Calculating a big number! (this is printed by fibby)
		> ls
		OUTPUT:
			none, waiting for completion
		Once fibby completes, OUTPUT:
			Fib is done!!
			... ls results (means it was run after fibby completed)

		- Make sure '&' makes programs run in the background
		> ./fibby &
		OUTPUT:
			Calculating a big number! (this is printed by fibby)
		> ls
		OUTPUT:
			... ls results (done while fibby completes)
		Once fibby completes, OUTPUT:
			Fib is done!!

	- WILDCARD MATCHING * AND ?

		- * matching, 'ls *.c' should show all .c files in directory
		> ls *.c
		OUTPUT:
			lex.yy.c y.tab.c

		- ? matching, 'ls shell.?' should show all files name shell with a one character file extension
		> ls shell.?
		OUTPUT:
			shell.l shell.y






