all: la

la: la.c
	gcc -g -o la la.c -lm -ldl -lpthread -llua
