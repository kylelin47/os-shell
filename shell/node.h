#ifndef NODE_H
#define NODE_H
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <pwd.h>
#include <glob.h>
typedef struct args_node {
    char* arg_str;
    struct args_node * next;
} arg_node;
#endif
