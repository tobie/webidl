all : index.html

index.html : index.bs
	bikeshed spec index.bs
	node ./check-anchors.js

index-pre.bs : index.xml WebIDL-bs.xsl
	java  -jar saxon9he.jar -warnings:silent -s:index.xml -xsl:WebIDL-bs.xsl -o:index-pre.bs
	
index.bs : index-pre.bs
	(node ./post-process/empty-tags.js < index-pre.bs) \
	| node ./post-process/clean-attr.js \
	| node ./post-process/indent.js \
	| node ./post-process/line-breaks.js \
	| node ./post-process/air.js \
	> index.bs
	cat ./post-process/scripts.html >> index.bs
		
index.ids : index.xml
	./xref.pl -d index.xml http://heycam.github.io/webidl/ > index.ids

oldindex.html : index.xml WebIDL.xsl
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL.xsl index.xml >oldindex.html

clean :
	rm -f index.html index-pre.bs index.bs index.ids

.PHONY : all clean
