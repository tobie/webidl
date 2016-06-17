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
  <xsl:param name='now'>12340506<!--
    <xsl:value-of select='translate(substring-before(substring-after(substring-after(substring-after($id, " "), " "), " "), " "), "/", "")'/>-->
  </xsl:param>

  <xsl:template match='h:*'>
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='h:span[@class="idltype"]'>
    <xsl:variable name='id' select='concat("idl-", translate(., " ", "-"))'/>
    <xsl:variable name='def' select='//*[@id=$id]'/>
    <xsl:choose>
      <xsl:when test='not(ancestor::h:a) and not(@id) and $def'>
        <a class='idltype' href='#{$id}'><xsl:apply-templates select='node()'/></a>
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
    <xsl:variable name='a-class' select='@class'/>
    <xsl:variable name='term' select='$options/x:links/x:term[@name=$name]'/>
    <xsl:if test='not($term)'>
      <xsl:message terminate='yes'>unknown term '<xsl:value-of select='$name'/>'</xsl:message>
    </xsl:if>
    <xsl:variable name='ref' select='$term/@ref'/>
    <xsl:variable name='section' select='$term/@section'/>
    <xsl:variable name='term-class' select='$term/@class'/>
    <xsl:variable name='final-class'>
      <xsl:value-of select='$a-class'/>
      <xsl:if test='$a-class and $term-class'>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:value-of select='$term-class'/>
    </xsl:variable>
    <a class="{$final-class}" href='{$term/@href}'>
      <xsl:apply-templates/>
    </a>
    <xsl:if test='not(contains($a-class, "nocite")) and $ref'>
      <xsl:if test='$section'>
        <xsl:text> (</xsl:text>
      </xsl:if>
      <a href='#ref-{$ref}'>[<xsl:value-of select='$ref'/>]</a>
      <xsl:if test='$section'>
        <xsl:text>, section </xsl:text>
        <xsl:value-of select='$section'/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name='monthName'>
    <xsl:param name='n' select='1'/>
    <xsl:param name='s' select='"January February March April May June July August September October November December "'/>
    <xsl:choose>
      <xsl:when test='string(number($n))="NaN"'>@@</xsl:when>
      <xsl:when test='$n = 1'>
        <xsl:value-of select='substring-before($s, " ")'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name='monthName'>
          <xsl:with-param name='n' select='$n - 1'/>
          <xsl:with-param name='s' select='substring-after($s, " ")'/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name='date'>
    <xsl:variable name='date'>
      <xsl:choose>
        <xsl:when test='$options/x:maturity="ED"'>
          <xsl:value-of select='$now'/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select='substring($options/x:versions/x:this/@href, string-length($options/x:versions/x:this/@href) - 8, 8)'/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select='number(substring($date, 7))'/>
    <xsl:text> </xsl:text>
    <xsl:call-template name='monthName'>
      <xsl:with-param name='n' select='number(substring($date, 5, 2))'/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:value-of select='substring($date, 1, 4)'/>
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
    <xsl:variable name='id' select='string(.)'/>
    <xsl:choose>
      <xsl:when test='preceding::h:div[@id=$id][@class="section"]'>above</xsl:when>
      <xsl:when test='following::h:div[@id=$id][@class="section"]'>below</xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='processing-instruction("slink")'>
    <xsl:variable name='id' select='string(.)'/>
    <a href='#{$id}'>
      <xsl:text>section </xsl:text>
      <xsl:variable name='s' select='//*[@id=$id]/self::h:div[@class="section"]'/>
      <xsl:choose>
        <xsl:when test='$s'>
          <xsl:call-template name='section-number'>
            <xsl:with-param name='section' select='$s'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>@@</xsl:otherwise>
      </xsl:choose>
    </a>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test='preceding::h:div[@id=$id][@class="section"]'>above</xsl:when>
      <xsl:when test='following::h:div[@id=$id][@class="section"]'>below</xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='processing-instruction("slink-nodir")'>
    <xsl:variable name='id' select='string(.)'/>
    <a href='#{$id}'>
      <xsl:text>section </xsl:text>
      <xsl:variable name='s' select='//*[@id=$id]/self::h:div[@class="section"]'/>
      <xsl:choose>
        <xsl:when test='$s'>
          <xsl:call-template name='section-number'>
            <xsl:with-param name='section' select='$s'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>@@</xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match='processing-instruction("revision-note")'>
    <xsl:if test='$options/x:maturity="ED"'>
      <div class='ednote'>
        <div class='ednoteHeader'>Editorial note</div>
        <p>This version of the document is built from source revision <xsl:text disable-output-escaping='yes'>&amp;#36;</xsl:text><xsl:value-of select='substring($id, 2)'/>.</p>
        <xsl:variable name='n' select='count(//h:div[@class="ednote"])'/>
        <xsl:if test='$n'>
          <p>
            There are <xsl:value-of select='$n'/> further editorial notes in the document.
            <xsl:if test='string(.)'>
              In addition, there is a list of <a href='{.}'>open bugs</a> on the document, some of which may be covered by editorial notes.
            </xsl:if>
          </p>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match='processing-instruction("stepref")'>
    <xsl:variable name='step' select='string(.)'/>
    <xsl:variable name='li' select='ancestor::*[@class="algorithm"]/*[@x:step=$step]'/>
    <xsl:choose>
      <xsl:when test='$li'>
        <xsl:value-of select='count($li/preceding-sibling::*) + 1'/>
      </xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='processing-instruction()|comment()'/>

  <xsl:template name='section-number'>
    <xsl:param name='section'/>
    <xsl:variable name='sections' select='//*[@id=substring-before($tocpi, " ")]'/>
    <xsl:variable name='appendices' select='//*[@id=substring-after($tocpi, " ")]'/>
    <xsl:choose>
      <xsl:when test='$section/ancestor::* = $sections'>
        <xsl:for-each select='$section/ancestor-or-self::h:div[@class="section"]'>
          <xsl:value-of select='count(preceding-sibling::h:div[@class="section"]) + 1'/>
          <xsl:if test='position() != last()'>
            <xsl:text>.</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test='$section/ancestor::* = $appendices'>
        <xsl:for-each select='$section/ancestor-or-self::h:div[@class="section"]'>
          <xsl:choose>
            <xsl:when test='position()=1'>
              <xsl:number value='count(preceding-sibling::h:div[@class="section"]) + 1' format='A'/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='count(preceding-sibling::h:div[@class="section"]) + 1'/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test='position() != last()'>
            <xsl:text>.</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='h:div[@class="section"]/h:h2 | h:div[@class="section"]/h:h3 | h:div[@class="section"]/h:h4 | h:div[@class="section"]/h:h5 | h:div[@class="section"]/h:h6'>
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:if test='$tocpi'>
        <xsl:variable name='num'>
          <xsl:call-template name='section-number'>
            <xsl:with-param name='section' select='..'/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test='$num != ""'>
          <xsl:value-of select='$num'/>
          <xsl:text>. </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match='h:div[@id="toc"] | h:head' />

  
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
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test='@language="idl" and not(ancestor::*[@class="example"])'>
          <pre class='{$lang} example'><xsl:apply-templates select='node()'/></pre>
      </xsl:when>
      <xsl:otherwise>
          <pre class='{$lang}'><xsl:apply-templates select='node()'/></pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match='h:span[@class="comment"]'>
      <xsl:apply-templates select='node()'/>
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
        <xsl:choose>
          <xsl:when test='../@links="off"'>
            <xsl:value-of select='@nt'/>
          </xsl:when>
          <xsl:otherwise>
            <a class='sym' href='#proddef-{@nt}'><xsl:value-of select='@nt'/></a>
          </xsl:otherwise>
        </xsl:choose>
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

  <xsl:template match='comment()'>
    <xsl:copy/>
  </xsl:template>

  <xsl:template match='comment()[starts-with(., "JAVA")]' />
</xsl:stylesheet>
