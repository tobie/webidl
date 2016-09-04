all : index.html

index.html :
	bikeshed spec index.bs

clean :
	rm -f index.html

.PHONY : all clean
