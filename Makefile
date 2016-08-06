all : index.html

index.html : index.bs
	bikeshed spec index.bs
	node "./check-anchors.js"

index.bs : index.xml WebIDL-bs.xsl
	java  -jar saxon9he.jar -warnings:silent -s:index.xml -xsl:WebIDL-bs.xsl -o:index-pre.bs
	node "./post-process.js" > index.bs

index.ids : index.xml
	./xref.pl -d index.xml http://heycam.github.io/webidl/ > index.ids

oldindex.html : index.xml WebIDL.xsl
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL.xsl index.xml >oldindex.html

clean :
	rm -f index.html index-pre.bs index.bs index.ids

.PHONY : all clean
