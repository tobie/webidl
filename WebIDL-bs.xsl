<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:h='http://www.w3.org/1999/xhtml'
                xmlns:x='http://mcc.id.au/ns/local'
                xmlns='http://www.w3.org/1999/xhtml'
                exclude-result-prefixes='h x'
                version='2.0' id='xslt'>

  <xsl:output method='xml' encoding='UTF-8'
              omit-xml-declaration='yes'
              media-type='application/xhtml+xml; charset=UTF-8'/>

  <xsl:variable name='options' select='/*/h:head/x:options'/>
  <xsl:variable name='id' select='/*/h:head/h:meta[@name="revision"]/@content'/>
  <xsl:variable name='rev' select='substring-before(substring-after(substring-after($id, " "), " "), " ")'/>
  <xsl:variable name='tocpi' />
  
<xsl:template match='processing-instruction("top")'>
<xsl:text>
</xsl:text>
<pre class="metadata">
<xsl:text>
Title: </xsl:text><xsl:value-of select='//h:title'/>
<xsl:text>
Shortname: WebIDL
Level: 2
Status: ED
Group: webplatform
ED: https://heycam.github.io/webidl/
TR: </xsl:text>
  <xsl:if test='$options/x:versions/x:latest/@href != ""'>
    <xsl:value-of select='$options/x:versions/x:latest/@href'/>
  </xsl:if>
<xsl:text>
</xsl:text>
<xsl:if test='$options/x:versions/x:previous[@href!=""]'>
  <xsl:if test='$options/x:versions/x:previous/@href != ""'>
    <xsl:for-each select='$options/x:versions/x:previous/@href'>
    <xsl:text>Previous Version: </xsl:text><xsl:value-of select='.'/><xsl:text>
</xsl:text>
    </xsl:for-each>
  </xsl:if>
</xsl:if>
  <xsl:for-each select='$options/x:editors/x:person'>
    <xsl:text>Editor: </xsl:text><xsl:value-of select='x:name'/>
    <xsl:if test='x:affiliation'>
      <xsl:text>, </xsl:text>
      <xsl:value-of select='x:affiliation'/>
      <xsl:if test='x:affiliation/@homepage'>
        <xsl:text>, </xsl:text>
        <xsl:value-of select='x:affiliation/@homepage'/>
      </xsl:if>
    </xsl:if>
    <xsl:if test='@homepage'>
      <xsl:text>, </xsl:text>
      <xsl:value-of select='@homepage'/>
    </xsl:if>
    <xsl:if test='@email'>
      <xsl:text>, </xsl:text>
      <xsl:value-of select='@email'/>
    </xsl:if>
<xsl:text>
</xsl:text>
  </xsl:for-each>
  <xsl:for-each select='tokenize(replace(//*[h:h2[text()="Abstract"]]/h:p, "^\s+|\s+$", ""), "\n")'>
<xsl:text>Abstract: </xsl:text><xsl:value-of select="normalize-space(.)" /><xsl:text>
</xsl:text>
    </xsl:for-each>
<xsl:text>Ignored Vars: callback, op, ownDesc, exampleVariableName, target
</xsl:text>
</pre>
<xsl:text>

</xsl:text>
<pre class="anchors">
<xsl:text>
</xsl:text>
    <xsl:for-each-group select='$options/x:links/x:term' group-by='replace(@href, "#.*?$", "")'>
<xsl:text>urlPrefix: </xsl:text><xsl:value-of select="current-grouping-key()"/>
<xsl:text>
    type: dfn
</xsl:text>
        <xsl:for-each-group select='current-group()' group-by='replace(@href, "^.*?#", "")'>
          <xsl:choose>
            <xsl:when test='count(current-group()) > 1'>
              <xsl:text>        url: </xsl:text>
              <xsl:value-of select="current-grouping-key()"/>
              <xsl:text>
</xsl:text>
              <xsl:for-each select='current-group()'>
                <xsl:text>            text: </xsl:text>
                <xsl:value-of select='@name' />
                <xsl:text>
</xsl:text>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name='url' select='replace(@href, "^.*?#", "")'/>
              <xsl:variable name='text' select='@name'/>
              <xsl:text>        text: </xsl:text>
              <xsl:value-of select='$text' />
              <xsl:if test='lower-case(replace($text, "\s+", "-")) != $url'>
                <xsl:text>; url: </xsl:text>
                <xsl:value-of select='$url' />
              </xsl:if>
              <xsl:text>
</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
    </xsl:for-each-group>
</pre>
  </xsl:template>

  <xsl:param name='now'>12340506<!--
    <xsl:value-of select='translate(substring-before(substring-after(substring-after(substring-after($id, " "), " "), " "), " "), "/", "")'/>-->
  </xsl:param>

  <xsl:template match='h:*'>
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match='h:span[@class="idltype"][@id]'>
    <dfn>
      <xsl:attribute name='id'><xsl:value-of select='@id'/></xsl:attribute>
      <xsl:attribute name='idl' />
      <xsl:apply-templates select="node()"/>
    </dfn>
  </xsl:template>

  <xsl:template match='h:span[@class="idltype"][not(@id)]'>
    <xsl:variable name='txt' select='string(.)'/>
    <xsl:variable name='generatedid' select='concat("idl-", translate(., " ", "-"))'/>
    <xsl:variable name='dfn' select='//h:dfn[.=$txt] | //*[@data-lt=$txt] | //*[@data-dfn-type][.=$txt] | //*[@id=$generatedid]'/>
    <xsl:choose>
      <xsl:when test='.[child::h:dfn[text()="Error"]]'>
        <xsl:text>{{Error}}</xsl:text>
      </xsl:when>
      <xsl:when test='$dfn and not(ancestor::h:a or child::h:dfn)'>
        <xsl:text>{{</xsl:text>
        <xsl:variable name='for' select='$dfn/@data-dfn-for'/>
        <xsl:if test="$for">
          <xsl:value-of select='$for' /><xsl:text>/</xsl:text>
        </xsl:if>
        <xsl:value-of select='$txt' />
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
          <xsl:apply-templates select='node()'/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='h:a[not(@href)]'>
    <xsl:variable name='name' select='string(.)'/>
    <xsl:variable name='escaped-name' select='replace($name, "\[\[", "\\[[")'/>
    <xsl:variable name='term' select='$options/x:links/x:term[@name=$name]'/>
    <xsl:if test='not($term)'>
      <xsl:message terminate='yes'>unknown term '<xsl:value-of select='$name'/>'</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test='@class'>
        <a class="{@class}"><xsl:value-of select='$escaped-name'/></a>
      </xsl:when>
      <xsl:otherwise>
        <a><xsl:value-of select='$escaped-name'/></a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match='h:a[@class="xattr"]'>
    <xsl:text>[{{</xsl:text><xsl:value-of select='replace(., "^\[|\]$", "")' /><xsl:text>}}]</xsl:text>
  </xsl:template>
  
  <xsl:template match='h:a[@class="xattr"][text()="[TreatNullAs=EmptyString]"]'>
    <xsl:text>[{{TreatNullAs}}]</xsl:text>
  </xsl:template>
  
  <xsl:template match='h:a[@class="idltype"]'>
    <xsl:text>{{</xsl:text><xsl:value-of select='replace(string(.), "\s*\n\s*", " ")'/><xsl:text>}}</xsl:text>
  </xsl:template>
  
  <xsl:template match='h:a[@class="dfnref"]'>
    <xsl:variable name='id' select='substring-after(@href, "#")'/>
    <xsl:variable name='dfn' select='//*[@id=$id]'/>
    <xsl:if test='$dfn/name() = "dfn" or $dfn/@dfn'>
      <xsl:call-template name='link-to-dfn'>
        <xsl:with-param name='dfn' select='$dfn'/>
        <xsl:with-param name='a' select='.'/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match='h:a[@class="dfnref"][@href="#create-frozen-array-from-iterable"] | h:a[@class="dfnref"][@href="create-sequence-from-iterable"] | h:a[@class="dfnref"][@href="#es-exception-objects"] | h:a[@class="dfnref"][@href="#getownproperty-guts"] | h:a[@class="dfnref"][@href="#idl-callback-function"] | h:a[@class="dfnref"][@href="#idl-dictionary"] | h:a[@class="dfnref"][@href="#idl-interface"]'>
    <xsl:variable name='id' select='substring-after(@href, "#")'/>
    <xsl:call-template name='link-to-dfn'>
      <xsl:with-param name='dfn' select='//*[@id=$id]/*[1]'/>
      <xsl:with-param name='a' select='.'/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name='link-to-dfn'>
    <xsl:param name="a" />
    <xsl:param name="dfn" />
    <xsl:variable name='txt' select='replace(string($a), "\s*\n\s*", " ")'/>
    <xsl:variable name='singular' select='lower-case(replace($txt, "s$", ""))'/>
    <xsl:variable name='plural' select='lower-case(concat($singular, "s"))'/>
    <xsl:variable name='lt' select='$dfn/@data-lt'/>
    <xsl:variable name='dfntxt' select='lower-case($dfn)'/>
    <xsl:choose>
      <xsl:when test='lower-case($txt) = $dfntxt or contains($lt, $txt) or $singular = $dfntxt or contains($lt, $singular) or $plural = $dfntxt or contains($lt, $plural)'>
        <xsl:text>[=</xsl:text><xsl:value-of select='$txt'/><xsl:text>=]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[=</xsl:text><xsl:value-of select='$dfn'/><xsl:text>|</xsl:text><xsl:value-of select='$txt'/><xsl:text>=]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match='processing-instruction("productions")'>
    <xsl:variable name='id' select='substring-before(., " ")'/>
    <xsl:variable name='names' select='concat(" ", substring-after(., " "), " ")'/>
    <table class='grammar'>
      <xsl:call-template name='proddef'>
        <xsl:with-param name='prods' select='//*[@id=$id]/x:prod[contains($names, concat(" ", @nt, " "))]'/>
        <xsl:with-param name='pi' select='.'/>
      </xsl:call-template>
    </table>
  </xsl:template>

  <xsl:template match='*[processing-instruction("sref")]'>
      <xsl:text>[[</xsl:text><xsl:value-of select='./@href'/><xsl:text>]]</xsl:text>
  </xsl:template>

  <xsl:template match='processing-instruction("sdir")'>
    <xsl:text></xsl:text>
  </xsl:template>
  
  <xsl:template match='*[processing-instruction("sdir")]/text()[following-sibling::processing-instruction("sdir")][last()]'>
    <xsl:value-of select='replace(., "\s+$", "")'/>
  </xsl:template>

  <xsl:template match='processing-instruction()|comment()'/>

  <xsl:template match='h:div[@id="toc"] | h:head' />
  
  <xsl:template match='h:dfn'>
    <xsl:copy copy-namespaces="no">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select='@id' />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@data-dfn-for">
        <xsl:attribute name="for">
          <xsl:value-of select='@data-dfn-for' />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@data-dfn-type">
        <xsl:attribute name='{@data-dfn-type}' />
      </xsl:if>
      <xsl:if test="@data-export">
        <xsl:attribute name="export" />
      </xsl:if>
      <xsl:if test="@data-lt and text() != @data-lt">
        <xsl:attribute name="lt">
          <xsl:value-of select='@data-lt' />
        </xsl:attribute>
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test='./*[1]'>
          <xsl:apply-templates select="node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select='replace(., "\s*\n\s*", " ")'/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match='h:span[@class="esvalue"]'>
    <emu-val><xsl:apply-templates select="node()"/></emu-val>
  </xsl:template>
  
  <xsl:template match='h:var'>
    <xsl:text>|</xsl:text><xsl:apply-templates select="node()"/><xsl:text>|</xsl:text>
  </xsl:template>
  
  <xsl:template match='text()'>
    <xsl:value-of select='replace(., "\[\[", "\\[[")' />
  </xsl:template>
  
  <xsl:template match='h:span[@class="rfc2119"]'>
    <xsl:value-of select='lower-case(text())'/>
  </xsl:template>
  
  <xsl:template match='*[matches(name(), "h[1-6]")][parent::h:div[@class="section"][@id]]'>
    <xsl:variable name='parent-id' select='parent::h:div[@class="section"]/@id' />
    <xsl:copy copy-namespaces="no">
      <xsl:if test="@id">
        <xsl:attribute name="oldids">
          <xsl:value-of select='@id' />
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="id">
        <xsl:value-of select='$parent-id' />
      </xsl:attribute>
      <xsl:if test="@data-dfn-type">
        <xsl:attribute name="{@data-dfn-type}" />
      </xsl:if>
      <xsl:if test="name() = 'h4' and ancestor::*/@id = 'es-extended-attributes'">
        <xsl:attribute name="extended-attribute" />
        <xsl:attribute name="lt"><xsl:value-of select='replace(., "\[|\]", "")' /></xsl:attribute>
      </xsl:if>
      <xsl:if test='$parent-id="create-frozen-array-from-iterable" or $parent-id="create-sequence-from-iterable" or $parent-id="es-exception-objects" or $parent-id="getownproperty-guts" or $parent-id="idl-callback-function" or $parent-id="idl-dictionary" or $parent-id="idl-interface"'>
        <xsl:attribute name="dfn" />
      </xsl:if>
      <xsl:if test="@data-lt and text() != @data-lt">
        <xsl:attribute name="lt">
          <xsl:value-of select='@data-lt' />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match='h:div[@class="section"] | h:div[@id="sections"] | h:body'>
    <xsl:apply-templates select='node()'/>
  </xsl:template>
  
  <xsl:template match='h:div[@class="section"][h:h2[text()="Abstract"]]'/>
  
  <xsl:template name='markdown-note-issue-advisement'>
    <xsl:text>    </xsl:text>
    <xsl:choose>
      <xsl:when test='@class="note"'>
          <xsl:text>Note</xsl:text>
      </xsl:when>
      <xsl:when test='@class="warning"'>
          <xsl:text>Advisement</xsl:text>
      </xsl:when>
      <xsl:when test='@class="ednote"'>
          <xsl:text>Issue</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>: </xsl:text>
    <xsl:for-each select="h:p/node()">
      <xsl:choose>
        <xsl:when test="position()=1">
            <xsl:value-of select='replace(., "^\s+", "")'/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select='.'/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="wrapped-note-issue-advisement">
    <xsl:variable name='class'>
      <xsl:choose>
        <xsl:when test='@class="warning"'>advisement</xsl:when>
        <xsl:when test='@class="ednote"'>issue</xsl:when>
        <xsl:otherwise><xsl:value-of select='@class'/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class='{$class}'><xsl:apply-templates select='node()'/></div>
  </xsl:template>
  
  <xsl:template match='h:div[@class="note" or @class="warning" or @class="ednote"]'>
    <xsl:choose>
      <xsl:when test='.[parent::h:li] or .[count(h:p)&gt;1] or .[not(h:p)]'>
        <xsl:call-template name="wrapped-note-issue-advisement"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="markdown-note-issue-advisement"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='x:codeblock'>
    <xsl:variable name='lang'>
      <xsl:choose>
        <xsl:when test='@language="idl"'>idl</xsl:when>
        <xsl:when test='@language="es"'>js</xsl:when>
        <xsl:when test='@language="java"'>java</xsl:when>
        <xsl:when test='@language="c"'>c</xsl:when>
        <xsl:when test='@language="html"'>html</xsl:when>
        <xsl:otherwise>
          <xsl:message terminate='yes'>Unexpected codeblock language attribute '<xsl:value-of select='@language'/>'</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test='$lang="idl"'>
        <xsl:choose>
          <xsl:when test='ancestor::*[@class="example"]'>
              <pre class='idl-example'><xsl:apply-templates select='node()'/></pre>
          </xsl:when>
          <xsl:otherwise>
              <pre class='idl-example example'><xsl:apply-templates select='node()'/></pre>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
          <pre highlight='{$lang}'><xsl:apply-templates select='node()'/></pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match='h:span[@class="comment"]'>
      <xsl:apply-templates select='node()'/>
  </xsl:template>
  
  <xsl:template match='h:div[@id="references"]' />
  <xsl:template match='h:a[starts-with(@href, "#ref-")]'>
    <xsl:choose>
      <xsl:when test='text()="[TYPEDARRAYS]"'>
        <xsl:text>[[!TYPEDARRAY]]</xsl:text>
      </xsl:when>
      <xsl:when test='text()="[DOM3CORE]"'>
        <xsl:text>[[DOM-LEVEL-3-CORE]]</xsl:text>
      </xsl:when>
      <xsl:when test='text()="[XMLNS]"'>
        <xsl:text>[[XML-NAMES]]</xsl:text>
      </xsl:when>
      <xsl:when test='matches(text(), "\[(ECMA-262|IEEE\-754|PERLRE|RFC2119|RFC2781|RFC3629|SECURE\-CONTEXTS|UNICODE|HTML)\]")'>
        <xsl:value-of select='replace(., "\[", "[[!")'/><xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[</xsl:text><xsl:value-of select='.'/><xsl:text>]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match='h:a[@class="placeholder"]'>
    <xsl:choose>
      <xsl:when test='text()="[WEBIDL]"'>
        <xsl:text>\[WEBIDL]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate='yes'>Unexpected placeholder link '<xsl:value-of select='.'/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 
  
  <xsl:template match='x:grammar'>
    <table class='grammar'>
      <xsl:apply-templates select='x:prod'/>
    </table>
  </xsl:template>

  <xsl:template name='proddef'>
    <xsl:param name='prods'/>
    <xsl:param name='pi'/>
    <xsl:for-each select='$prods'>
      <xsl:variable name='nt' select='@nt'/>
      <tr>
        <xsl:if test='not($pi/preceding::processing-instruction("productions")[contains(concat(" ", substring-after(., " "), " "), concat(" ", $nt, " "))])'>
          <xsl:attribute name='id'>proddef-<xsl:value-of select='@nt'/></xsl:attribute>
        </xsl:if>
        <td><span class='prod-number'>[<xsl:value-of select='count(preceding-sibling::x:prod) + 1'/>]</span></td>
        <td>
          <a class='sym' href='#prod-{@nt}'><xsl:value-of select='@nt'/></a>
          <xsl:if test='@whitespace="explicit"'>
            <sub class='nt-attr'>explicit</sub>
          </xsl:if>
        </td>
        <td class='prod-mid'>→</td>
        <td class='prod-rhs'>
          <span class='prod-lines'>
            <xsl:call-template name='bnf'>
              <xsl:with-param name='s' select='string(.)'/>
            </xsl:call-template>
          </span>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='x:prod'>
    <tr id='prod-{@nt}'>
      <td><span class='prod-number'>[<xsl:value-of select='count(preceding-sibling::x:prod) + 1'/>]</span></td>
      <td>
        <xsl:value-of select='@nt'/>
        
        <xsl:if test='@whitespace="explicit"'>
          <sub class='nt-attr'>explicit</sub>
        </xsl:if>
      </td>
      <td class='prod-mid'>→</td>
      <td class='prod-rhs'>
        <span class='prod-lines'>
          <xsl:call-template name='bnf'>
            <xsl:with-param name='s' select='string(.)'/>
            <xsl:with-param name='links' select='../@links'/>
          </xsl:call-template>
        </span>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name='bnf'>
    <xsl:param name='s'/>
    <xsl:param name='mode' select='0'/>
    <xsl:param name='links'/>
    <xsl:if test='$s != ""'>
      <xsl:variable name='c' select='substring($s, 1, 1)'/>
      <xsl:choose>
        <xsl:when test='$mode = 0 and contains("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", $c)'>
          <xsl:variable name='nt'>
            <xsl:value-of select='$c'/>
            <xsl:call-template name='bnf-nt'>
              <xsl:with-param name='s' select='substring($s, 2)'/>
            </xsl:call-template>
          </xsl:variable>
            <!--
          <xsl:choose>
            <xsl:when test='$links="off"'>
              <xsl:value-of select='$nt'/>
            </xsl:when>
            <xsl:otherwise>
            -->
              <a class='sym' href='#prod-{$nt}'><xsl:value-of select='$nt'/></a>
            <!--
            </xsl:otherwise>
          </xsl:choose>
            -->
          <xsl:call-template name='bnf'>
            <xsl:with-param name='s' select='substring($s, string-length($nt) + 1)'/>
            <xsl:with-param name='links' select='$links'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test='$mode = 0 and $c = "|"'>
          <!--div class='prod-line-subsequent'--><br/> |
            <xsl:call-template name='bnf'>
              <xsl:with-param name='s' select='substring($s, 2)'/>
              <xsl:with-param name='links' select='$links'/>
            </xsl:call-template>
          <!--/div-->
        </xsl:when>
        <xsl:when test='$c = &#39;"&#39;'>
          <xsl:value-of select='$c'/>
          <xsl:variable name='newMode'>
            <xsl:choose>
              <xsl:when test='$mode = 1'>0</xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name='bnf'>
            <xsl:with-param name='s' select='substring($s, 2)'/>
            <xsl:with-param name='mode' select='$newMode'/>
            <xsl:with-param name='links' select='$links'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$c = &#34;'&#34;">
          <xsl:value-of select='$c'/>
          <xsl:variable name='newMode'>
            <xsl:choose>
              <xsl:when test='$mode = 2'>0</xsl:when>
              <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name='bnf'>
            <xsl:with-param name='s' select='substring($s, 2)'/>
            <xsl:with-param name='mode' select='$newMode'/>
            <xsl:with-param name='links' select='$links'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$c = '[' and $mode = 0">
          <xsl:value-of select='$c'/>
          <xsl:choose>
            <xsl:when test='substring($s, 2, 1) = "]"'>
              <xsl:text>]</xsl:text>
              <xsl:call-template name='bnf'>
                <xsl:with-param name='s' select='substring($s, 3)'/>
                <xsl:with-param name='links' select='$links'/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name='newMode'>
                <xsl:choose>
                  <xsl:when test='$mode = 3'>0</xsl:when>
                  <xsl:otherwise>3</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:call-template name='bnf'>
                <xsl:with-param name='s' select='substring($s, 2)'/>
                <xsl:with-param name='mode' select='$newMode'/>
                <xsl:with-param name='links' select='$links'/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$c = ']' and $mode = 3">
          <xsl:value-of select='$c'/>
          <xsl:call-template name='bnf'>
            <xsl:with-param name='s' select='substring($s, 2)'/>
            <xsl:with-param name='links' select='$links'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select='$c'/>
          <xsl:call-template name='bnf'>
            <xsl:with-param name='s' select='substring($s, 2)'/>
            <xsl:with-param name='mode' select='$mode'/>
            <xsl:with-param name='links' select='$links'/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name='bnf-nt'>
    <xsl:param name='s'/>
    <xsl:if test='$s != ""'>
      <xsl:variable name='c' select='substring($s, 1, 1)'/>
      <xsl:if test='contains("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz", $c)'>
        <xsl:value-of select='$c'/>
        <xsl:call-template name='bnf-nt'>
          <xsl:with-param name='s' select='substring($s, 2)'/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match='*'/>

  <xsl:template match='comment()' />

  <xsl:template match='comment()[starts-with(., "JAVA")]' />
  
  <xsl:template match='h:a[@href="#dfn-values-to-iterate-over"]'>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="href">#</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match='h:a[@href="#dfn-flattened-union-member-type"]'>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="href">#dfn-flattened-union-member-types</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match='h:a[@href="#dfn-supported-indexed-properties"]'>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="href">#dfn-support-indexed-properties</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match='h:a[@href="#dfn-convert-idl-to-ecmascript"]'>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="href">#dfn-convert-idl-to-ecmascript-value</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
