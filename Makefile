all: la

la: la.c
	gcc -g -o la la.c -L/usr/include -lm -ldl -lpthread  -lluajit-5.1
	#gcc -g -o la la.c -L/usr/include -lm -ldl -lpthread -llua -lluajit-5.1

clean:
	rm la
