all : index.html

index.html : 
	java  -jar saxon9he.jar -warnings:silent -s:../index.xml -xsl:./WebIDL-bs.xsl -o:index-pre.bs
	xsltproc --nodtdattr --param now `date +%Y%m%d` ../WebIDL.xsl ../index.xml > oldindex.html
	(node ./post-process/intro.js < index-pre.bs) \
	| node ./post-process/rm-blanklines.js \
	| node ./post-process/empty-tags.js \
	| node ./post-process/clean-attr.js \
	| node ./post-process/dic.js \
	| node ./post-process/indent.js --markdownify \
	| node ./post-process/line-breaks.js \
	| node ./post-process/air.js \
	> ../index.bs
	sed -e 's|\(\[[A-Z_-][A-Z_-]*\]\)|\\\1|g' ./post-process/scripts.html >> ../index.bs
	bikeshed spec ../index.bs
	node ./check-structure.js ../index.html > index.struc
	node ./check-anchors.js oldindex.html ../index.html
	node ./check-dfn-contract.js oldindex.html ../index.html
	
	# raw-index.bs
	(node ./post-process/intro.js < index-pre.bs) \
	| node ./post-process/rm-blanklines.js \
	| node ./post-process/empty-tags.js \
	| node ./post-process/clean-attr.js \
	| node ./post-process/dic.js \
	| node ./post-process/indent.js \
	| node ./post-process/line-breaks.js \
	| node ./post-process/air.js \
	> raw-index.bs
	sed -e 's|\(\[[A-Z_-][A-Z_-]*\]\)|\\\1|g' ./post-process/scripts.html >> raw-index.bs
	bikeshed spec raw-index.bs >/dev/null
	node ./check-structure.js raw-index.html > raw-index.struc	

	diff raw-index.struc index.struc -B && rm -f index-pre.bs index.struc raw-index.bs raw-index.html raw-index.struc

diff.html : index.html
	sed -e 's|<\(/*\)emu-[^>]*>|<\1code>|g' ../index.html > html-diff.html

clean :
	rm -f ../index.html index-pre.bs ../index.bs index.struc raw-index.bs raw-index.html raw-index.struc

.PHONY : all clean
