cc := tcc

all: la

la: la.c
	$(cc) -o la la.c -L/usr/include -lm -ldl -lpthread  -lluajit-5.1

clean:
	rm la
