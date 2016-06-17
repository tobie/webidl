all : index.html

index.html : index.xml WebIDL.xsl
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL.xsl index.xml >index.html
	
index.bs : index.xml WebIDL-bs.xsl
	java  -jar saxon9he.jar -warnings:silent -s:index.xml -xsl:WebIDL-bs.xsl -o:index.bs

index.ids : index.xml
	./xref.pl -d index.xml http://heycam.github.io/webidl/ > index.ids

clean :
	rm -f index.html index.bs index.ids

.PHONY : all clean
