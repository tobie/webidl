all : index.html

index.html : index.xml WebIDL.xsl
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL.xsl index.xml >index.html
	
index.bs : index.xml WebIDL-bs.xsl
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL-bs.xsl index.xml >index.bs

index.ids : index.xml
	./xref.pl -d index.xml http://heycam.github.io/webidl/ > index.ids

java.html : java.xml WebIDL.xsl index.ids
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL.xsl java.xml | ./xref.pl -t - index.ids > java.html

clean :
	rm -f index.html java.html index.ids

.PHONY : all clean
