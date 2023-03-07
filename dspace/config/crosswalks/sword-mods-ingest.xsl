<?xml version="1.0" encoding="utf-8"?>  

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:mods="http://www.loc.gov/mods/v3"
    version="1.0">
    
   
    
    <xsl:template match="text()">
        <dim:dim>
            <xsl:apply-templates/>  
        </dim:dim>
    </xsl:template>
    
    
    <!--   mods:/abstract   ====>   dc.description.abstract   -->
    <xsl:template match="mods:mods/mods:abstract">
        <xsl:element name="dim:field">
            <xsl:attribute name="mdschema">dc</xsl:attribute>
            <xsl:attribute name="element">description</xsl:attribute>
            <xsl:attribute name="qualifier">abstract</xsl:attribute> 
            <xsl:attribute name="lang">
                <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    
    <!--   mods:/accessCondition[@type="use and reproduction"] ====>   dc.rights  -->
    <xsl:template match="mods:mods/mods:accessCondition[@type='use and reproduction']">
        <xsl:element name="dim:field">
            <xsl:attribute name="mdschema">dc</xsl:attribute> 
            <xsl:attribute name="element">rights</xsl:attribute> 
            <xsl:if test="@description ='uri'"> 
                <xsl:attribute name="qualifier">uri</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    
    <!--   mods:/genre ====>   dc.type  -->
    <xsl:template match="mods:mods/mods:genre[.='journal article']">
        <dim:field mdschema="dc" element="type">
            article
        </dim:field>
    </xsl:template>   
    
    
    <!--   mods:/identifier[@type="doi"] ====>   dcterms.bibliographicCitation.doi, dc.identifier.pmid   -->
    <xsl:template match="mods:mods/mods:identifier">
        <xsl:choose>
            <xsl:when test="@type ='doi'">
             <!--   <dim:field mdschema="created" element="identifier" qualifier="doi">  -->
             	    <dim:field mdschema="dc" element="identifier" qualifier="doi">
                    <xsl:value-of select="."/>
                </dim:field>
            </xsl:when>
	    <xsl:when test="@type ='urn'">
               <!-- <dim:field mdschema="created" element="identifier" qualifier="urn">  -->   
               <dim:field mdschema="dc" element="identifier" qualifier="urn">                                                                                                                                               <xsl:value-of select="."/>
                </dim:field>
            </xsl:when>
            <!--  dc.identifier.* -->
            <xsl:otherwise>
            	<dim:field mdschema="dc" element="identifier" qualifier="other">
            	<xsl:value-of select="."/>
            	</dim:field>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--   mods:/language/languageTerm ====>   dc.language.iso  -->
    <xsl:template match="mods:mods/mods:language">
        <dim:field mdschema="dc" element="language" qualifier="iso">
                <xsl:value-of select="translate(mods:languageTerm,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </dim:field>
    </xsl:template>    
    

    
    <!--   mods:/note[@type='funding'] ====>   dc.description.sponsorship 
    <xsl:template match="mods:mods/mods:note[@type='funding']">
        <dim:field mdschema="dc" element="description" qualifier="sponsorship">
            <xsl:value-of select="."/>
        </dim:field>
    </xsl:template>
    -->

    
    <!--   mods:/name[@type="personal"]  ====>   dc.contributor.[author] -->
    <xsl:template match="mods:mods/mods:name/mods:role/mods:roleTerm[.='author']">
        <xsl:variable name="contributorName" select="concat(../../mods:namePart[@type='family'],', ',../../mods:namePart[@type='given'])"/>
        <xsl:element name="dim:field">
            <xsl:attribute name="mdschema">dc</xsl:attribute>
            <xsl:attribute name="element">contributor</xsl:attribute>
            <xsl:attribute name="qualifier">author</xsl:attribute>
            <xsl:value-of select="$contributorName"/>
        </xsl:element>
    </xsl:template>
    
    <!--   mods:/name[@type="personal"]  ====>   dc.contributor.[editor] -->
    <xsl:template match="mods:mods/mods:name/mods:role/mods:roleTerm[.='editor']">
        <xsl:variable name="contributorName" select="concat(../../mods:namePart[@type='family'],', ',../../mods:namePart[@type='given'])"/>
        <xsl:element name="dim:field">
            <xsl:attribute name="mdschema">dc</xsl:attribute>
            <xsl:attribute name="element">contributor</xsl:attribute>
            <xsl:attribute name="qualifier">editor</xsl:attribute>
            <xsl:value-of select="$contributorName"/>
        </xsl:element>
    </xsl:template>
    
    <!--   mods:/affiliation  (Affiliation Group) ====>   dcterms.contributor.affiliation  
    <xsl:template match="mods:mods/mods:affiliation">
        <dim:field mdschema="dcterms" element="contributor" qualifier="affiliation">
            <xsl:value-of select="."/>
        </dim:field>
    </xsl:template>
-->    

    <!--   mods:/originInfo  ====>   dcterms.bibliographicCitation.originalpublishername, dcterms.bibliographicCitation.originalpublisherplace, dc.date.issued -->
    <xsl:template match="mods:mods/mods:originInfo">
        
        <!--  dcterms.bibliographicCitation.originalpublishername -->
        <xsl:if test="mods:publisher">
            <dim:field mdschema="dc" element="publisher">
                <xsl:value-of select="mods:publisher"/>
            </dim:field>
        </xsl:if>
        
        <!--dcterms.bibliographicCitation.originalpublisherplace 
        <xsl:if test="mods:place">
            <xsl:for-each select="mods:place/mods:placeTerm">  
                <dim:field mdschema="dcterms" element="bibliographicCitation" qualifier="originalpublisherplace">
                    <xsl:value-of select="."/>
                </dim:field>
            </xsl:for-each>
        </xsl:if>
-->
        
        <!--  dc.date.issued, encoding="iso8601"   -->
        <xsl:if test="mods:dateIssued[@encoding='iso8601']">
            <dim:field mdschema="dc" element="date" qualifier="issued">
                <xsl:value-of select="mods:dateIssued"/>
            </dim:field>
        </xsl:if>

<!--
      <xsl:if test="mods:dateOther[@type='accepted']">
	<dim:field mdschema="local" element="date" qualifier="accepted">
		<xsl:value-of select="mods:dateOther[@type='accepted']"/>
	</dim:field>
      </xsl:if>
   -->
   <xsl:if test="mods:dateOther[@type='accepted']">
            <dim:field mdschema="local" element="date" qualifier="accepted">
                <xsl:value-of select="mods:dateOther"/>
            </dim:field>
   </xsl:if>
   </xsl:template>
    
    
    <!--   mods relatedItem   -->
    <xsl:template match="mods:mods/mods:relatedItem[@type='host']">
         
        <!-- mods:/relatedItem[@type="host"]/titleInfo/title   ====>   journaltitle 
        <xsl:if test="mods:titleInfo/mods:title">
            	<dim:field mdschema="local" element="journal" qualifier="title">
                   <xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/>
                </dim:field>  
        </xsl:if>
        -->
        
        <xsl:for-each select="mods:titleInfo">
                <dim:field mdschema="local" element="journal" qualifier="title">
                    <xsl:value-of select="mods:title"/>
                </dim:field>
        </xsl:for-each>
        
        
        <!--   mods:/relatedItem[@type="host"]/identifier[@type="issn']  -->
        <xsl:for-each select="mods:identifier">
            <xsl:if test="@type='issn'">
                <dim:field mdschema="local" element="identifier" qualifier="issn">
                    <xsl:value-of select="."/>
                </dim:field>
            </xsl:if>
        </xsl:for-each>
        
        <!--   mods:/relatedItem[@type="host"]/identifier[@type="isbn']  -->
        <xsl:for-each select="mods:identifier">
            <xsl:if test="@type='isbn'">
                <dim:field mdschema="local" element="identifier" qualifier="isbn">
                    <xsl:value-of select="."/>
                </dim:field>
            </xsl:if>
        </xsl:for-each>

	<!--   mods:/relatedItem[@type="host"]/identifier[@type="eIssn or pIssn']  -->
	<xsl:for-each select="mods:identifier">
	     <xsl:if test="@type='eIssn' or @type='pIssn'">
	       <dim:field mdschema="local" element="identifier" qualifier="issn">
		 <xsl:value-of select="."/>
	       </dim:field>
	    </xsl:if>
	</xsl:for-each>			
        
        <!--    mods:/relatedItem/part/detail[@type="volume" | @type="issue"]    ====>   created.journal.[volume, issue] -->
        <xsl:if test="mods:part">
            <xsl:for-each select="mods:part/mods:detail">
                <xsl:element name="dim:field">
                <xsl:attribute name="mdschema">local</xsl:attribute>
                    <xsl:attribute name="element">journal</xsl:attribute>
                    <xsl:attribute name="qualifier">
                        <xsl:value-of select="@type"/>
                    </xsl:attribute>
                    <xsl:value-of select="mods:number"/>
                </xsl:element>  
            </xsl:for-each>  
            
            <!--  mods:/relatedItem/part/extent[@unit="pages"]    ====>   ddcterms.bibliographicCitation.[pagestart, pageend] -->
            <xsl:if test="mods:part/mods:extent[@unit='pages']">
                <dim:field mdschema="local" element="document" qualifier="pagestart">
                    <xsl:value-of select="mods:part/mods:extent/mods:start"/>
                </dim:field>
                <dim:field mdschema="local" element="document" qualifier="pageend">
                    <xsl:value-of select="mods:part/mods:extent/mods:end"/>
                </dim:field>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <!--  mods:/subject/topic ====>   dc.subject.other  -->
    <xsl:template match="mods:mods/mods:subject">
        <xsl:for-each select="mods:topic">
            <dim:field mdschema="dc" element="subject">
                <xsl:value-of select="."/>
            </dim:field>
        </xsl:for-each>
    </xsl:template>
    
    
    <!--   mods:/tableOfContents ====>   dc.description.tableofcontents  
    <xsl:template match="mods:mods/mods:tableOfContents">
        <dim:field mdschema="dc" element="description" qualifier="tableofcontents">
            <xsl:value-of select="."/>
        </dim:field>
    </xsl:template>
    -->
    
    <!--   mods:/titleInfo/title ====>   dc.title, dc.title.translated, dc.title.subtitle and dc.title.translatedsubtitle   -->
    <xsl:template match="mods:mods/mods:titleInfo">
        <xsl:for-each select="*">  
            <xsl:element name="dim:field">
                
                <xsl:attribute name="mdschema">dc</xsl:attribute>
                
                <!--  dc.title.subtitle and dc.titletranslatedsubtitle  
                <xsl:if test="self::mods:subTitle">
                    <xsl:attribute name="element">title</xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="@type='translated'">
                            <xsl:attribute name="qualifier">translatedsubtitle</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="qualifier">subtitle</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
-->
                
                <!-- dc.title and dc.title.translated  -->
                <xsl:if test="self::mods:title">
                    <xsl:attribute name="element">title</xsl:attribute>
                    <xsl:if test="@type='translated'"> 
                        <xsl:attribute name="qualifier">alternative</xsl:attribute>
                    </xsl:if>
                </xsl:if>
                
                <!-- Set the language if there is one -->
                <xsl:if test="@xml:lang">
                    <xsl:attribute name="lang">
                        <xsl:value-of select="@xml:lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element> 
        </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>
