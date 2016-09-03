all : index.html

index.html : 
	java  -jar saxon9he.jar -warnings:silent -s:index.xml -xsl:./convert/WebIDL-bs.xsl -o:index-pre.bs
	xsltproc --nodtdattr --param now `date +%Y%m%d` WebIDL.xsl index.xml > oldindex.html
	(node ./convert/post-process/intro.js < index-pre.bs) \
	| node ./convert/post-process/rm-blanklines.js \
	| node ./convert/post-process/empty-tags.js \
	| node ./convert/post-process/clean-attr.js \
	| node ./convert/post-process/dic.js \
	| node ./convert/post-process/indent.js --markdownify \
	| node ./convert/post-process/line-breaks.js \
	| node ./convert/post-process/air.js \
	> index.bs
	sed -e 's|\(\[[A-Z_-][A-Z_-]*\]\)|\\\1|g' ./convert/post-process/scripts.html >> index.bs
	bikeshed spec index.bs
	node ./convert/check-structure.js index.html > index.struc
	node ./convert/check-anchors.js
	node ./convert/check-dfn-contract.js
	
	# raw-index.bs
	(node ./convert/post-process/intro.js < index-pre.bs) \
	| node ./convert/post-process/rm-blanklines.js \
	| node ./convert/post-process/empty-tags.js \
	| node ./convert/post-process/clean-attr.js \
	| node ./convert/post-process/dic.js \
	| node ./convert/post-process/indent.js \
	| node ./convert/post-process/line-breaks.js \
	| node ./convert/post-process/air.js \
	> raw-index.bs
	sed -e 's|\(\[[A-Z_-][A-Z_-]*\]\)|\\\1|g' ./convert/post-process/scripts.html >> raw-index.bs
	bikeshed spec raw-index.bs >/dev/null
	node ./convert/check-structure.js raw-index.html > raw-index.struc	

	diff raw-index.struc index.struc -B
	rm -f index-pre.bs index.struc raw-index.bs raw-index.html raw-index.struc

diff.html : index.html
	sed -e 's|<\(/*\)emu-[^>]*>|<\1code>|g' index.html > html-diff.html

clean :
	rm -f index.html index-pre.bs index.bs index.struc index.ids raw-index.bs raw-index.html raw-index.struc

.PHONY : all clean
