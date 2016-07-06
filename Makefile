all : index.html

index.html : index.bs
	bikeshed spec --force

index.bs : index.xml WebIDL-bs.xsl
	java  -jar saxon9he.jar -warnings:silent -s:index.xml -xsl:WebIDL-bs.xsl -o:index.bs

index.ids : index.xml
	./xref.pl -d index.xml http://heycam.github.io/webidl/ > index.ids

oldindex.html : index.xml WebIDL.xsl
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL.xsl index.xml >oldindex.html

clean :
	rm -f index.html index.bs index.ids

.PHONY : all clean
