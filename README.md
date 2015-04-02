#OS SHELL README

A Linux shell written in LEX/YACC, by Kyle Lin and Joachim Jones.

Our code is contained within the shell.l and shell.y files.


#Features

- All built-in commands (setenv, printenv, unsetenv, cd, alias, unalias)
- Running commands with any number of arguments (i.e. 'ls -l')
- Environment variable expansion
- Aliasing support and checking for infinite alias dependency
- IO redirection: stdout, stderr, and stdin can all be redirected
- Pipe support for any number of pipes
- '&' support for program completion in background if desired
- Wildcard matching with the '*' and '?' characters
- EXTRA CREDIT: Tilde expansion also supported


#Code Structure

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
		- if the command is built in, perfrom built-in command
		- search in the path for the command, return error if not found
		- looks in the list of arguments for the IO-redirection keywords and redirect stdout, stdin, or stderr if desired
		- calls exeve(..) on the command with the list of args
		- waits for child processes to complete if & is not present


#TO RUN SHELL
A makefile is included with our shell project submission.
Simply run 'make' and then './shell.out' to access our shell.

Tested on Ubuntu 14.04.2 64-bit
