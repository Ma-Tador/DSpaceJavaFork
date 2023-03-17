<?xml version="1.0" encoding="UTF-8" ?>
<!-- XMetaDissPlus Crosswalk for DNB deposit http://www.dspace.org/license/ 
	Developed by cjuergen 
	based on XMetaDissPlus Version 2.2 Date 2012-02-21 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://www.lyncode.com/xoai" version="1.0" xmlns:xsk="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="../templates/tub_templates.xsl" />

    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

    <xsl:template match="/">

        <xMetaDiss:xMetaDiss xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
                             xmlns:cc="http://www.d-nb.de/standards/cc/" xmlns:dc="http://purl.org/dc/elements/1.1/"
                             xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:dcterms="http://purl.org/dc/terms/"
                             xmlns:pc="http://www.d-nb.de/standards/pc/" xmlns:urn="http://www.d-nb.de/standards/urn/"
                             xmlns:hdl="http://www.d-nb.de/standards/hdl/" xmlns:doi="http://www.d-nb.de/standards/doi/"
                             xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
                             xmlns:ddb="http://www.d-nb.de/standards/ddb/"
                             xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
                             xmlns="http://www.d-nb.de/standards/subject/"
                             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/  http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">

            <!-- 1. Titel dc.title to dc:title -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
                <dc:title xsi:type="ddb:titleISO639-2">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dc:title>
            </xsl:for-each>

            <!-- 1. Translated titel dc.title.translated to dc:title -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='alternative']/doc:element/doc:field[@name='value']">
                <dc:title xsi:type="ddb:titleISO639-2" ddb:type="translated">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dc:title>
            </xsl:for-each>
                                         

            <!-- 3. Urheber dc.contributor.author to dc:creator xsi:type="pc:MetaPers" -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
                <xsl:choose>
                <xsl:when test="contains(., ',') = 'true' ">
                    <dc:creator xsi:type="pc:MetaPers">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:creator>
                </xsl:when>
                <xsl:when test="contains(., ' ') = 'true' ">
                    <dc:creator xsi:type="pc:MetaPers">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    	<xsl:value-of select="substring-before(., ' ')"/>
                                </pc:foreName>
                                <pc:surName>
                                	<xsl:value-of select="normalize-space(substring-after(., ' '))"/>                                  
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:creator>
                </xsl:when>
                <xsl:otherwise>
               <dc:creator xsi:type="pc:MetaPers">
                        <pc:person>
                            <pc:name type="otherName">
                                <pc:personEnteredUnderGivenName>
                                    	<xsl:value-of select="."/>
                                </pc:personEnteredUnderGivenName>                            
                            </pc:name>
                        </pc:person>
                    </dc:creator>
                </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            
            <!-- 3. Contributing Organization to dc:creator xsi:type="pc:MetaPers" OR dcterms.contributor -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
                    <dc:creator xsi:type="pc:MetaPers">
                        <pc:person>
                            <pc:name type="otherName" otherNameType="organisation">
                                <pc:organisationName>
                                    <xsl:value-of select="."/>
                                </pc:organisationName>                              
                            </pc:name>
                        </pc:person>
                    </dc:creator>           
            </xsl:for-each>
            


            <!-- 4. Klassifikation/Thesaurus dc.subject.ddc to dc:subject xsi:type="xMetaDiss:DDC-SG" -->
            <!--
                The DDC in DSpace is usually not just a number but a number with a description.
                Occasionally it also has the prefix 'DDC::'.
                Since the XSLT engine lyncode uses apparently doesn't support XSLT 2.0, we cannot work with regular
                expressions to get the number, thus the solution beneath.
                With XSLT 2.0 we could simply use the following: replace(.,'^(DDC:*)?(\d{3}).*$','$2')
            -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='ddc']/doc:element/doc:field[@name='value']">
                <xsl:variable name="ddcnumber">
                    <xsl:call-template name="find-ddc-recursively">
                        <xsl:with-param name="text" select="text()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="string-length(normalize-space($ddcnumber)) = 3">
                    <dc:subject xsi:type="xMetaDiss:DDC-SG">
                        <xsl:value-of select="$ddcnumber"/>
                    </dc:subject>
                </xsl:if>
            </xsl:for-each>
           
            <!-- 4. Klassifikation, free keyword -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
                <dc:subject xsi:type="xMetaDiss:noScheme">
                    <xsl:value-of select="."/>
                </dc:subject>
            </xsl:for-each>
            

            <!-- 6. Abstract dc.description.abstract to dcterms:abstract -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
                <dcterms:abstract xsi:type="ddb:contentISO639-2">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dcterms:abstract>
            </xsl:for-each>


            <!-- 7. Verbreitende Stelle - dc.publisher.universityorinstitution -->
            <xsl:variable name="publisher">
                <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
                   
            <dc:publisher xsi:type="cc:Publisher" type="dcterms:ISO3166" countryCode="DE">
                <xsl:if test="not($publisher) or $publisher != 'FAU University Press'">
                    <cc:universityOrInstitution>
                        <cc:name>Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU)</cc:name>
                        <cc:place>Erlangen</cc:place>
                    </cc:universityOrInstitution>
                    <cc:address>Universitätsstr 4</cc:address>
                </xsl:if>
                <xsl:if test="$publisher = 'FAU University Press'">
                    <cc:universityOrInstitution>
                        <cc:name>FAU University Press</cc:name>
                        <cc:place>Erlangen</cc:place>
                    </cc:universityOrInstitution>
                    <cc:address>Universitätsstr. 4</cc:address>
                </xsl:if>
            </dc:publisher>


            <!-- 8. Betreuer / Gutachter / Prüfungskommission dc.contributor.advisor to dc:contributor pc:Contributor thesis:role=advisor -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='advisor']/doc:element/doc:field[@name='value']">
            <xsl:choose>
                <xsl:when test="contains(., ',') = 'true' ">
                    <dc:contributor xsi:type="pc:Contributor" thesis:role="advisor">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:when>
                <xsl:when test="contains(., ' ') = 'true' ">
                <dc:contributor xsi:type="pc:Contributor" thesis:role="advisor">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="substring-before(., ' ')"/>
                                </pc:foreName>
                                <pc:surName>                                  
                                    <xsl:value-of select="normalize-space(substring-after(., ' '))"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:when>
                <xsl:otherwise>
                <dc:contributor xsi:type="pc:Contributor" thesis:role="advisor">
                        <pc:person>
                            <pc:name type="otherName">
                                <pc:personEnteredUnderGivenName>
                                    	<xsl:value-of select="."/>
                                </pc:personEnteredUnderGivenName>                            
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!-- 8. Betreuer / Gutachter / Prüfungskommission dc.contributor to dc:contributor pc:Contributor thesis:role=referee -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
              <xsl:choose>
                <xsl:when test="contains(., ',') = 'true' ">
                    <dc:contributor xsi:type="pc:Contributor" thesis:role="referee">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:when>
                <xsl:when test="contains(., ' ') = 'true' ">
                <dc:contributor xsi:type="pc:Contributor" thesis:role="referee">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    	<xsl:value-of select="substring-before(., ' ')"/>
                                </pc:foreName>
                                <pc:surName>
                                	<xsl:value-of select="normalize-space(substring-after(., ' '))"/>                                   
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor> 
                </xsl:when>
                <xsl:otherwise>
               <dc:contributor xsi:type="pc:Contributor" thesis:role="referee">
                        <pc:person>
                            <pc:name type="otherName">
                                <pc:personEnteredUnderGivenName>
                                    	<xsl:value-of select="."/>
                                </pc:personEnteredUnderGivenName>                            
                            </pc:name>
                        </pc:person>
                    </dc:contributor> 
                </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>

            <!-- 8. Betreuer / Gutachter / Prüfungskommission dc.contributor.editor to dc:contributor pc:Contributor thesis:role=editor -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']">
              <xsl:choose>
                <xsl:when test="contains(., ',') = 'true' ">
                    <dc:contributor xsi:type="pc:Contributor" thesis:role="editor">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:when>
                <xsl:when test="contains(., ' ') = 'true' ">
                <dc:contributor xsi:type="pc:Contributor" thesis:role="editor">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    	<xsl:value-of select="substring-before(., ' ')"/>
                                </pc:foreName>
                                <pc:surName>
                                	<xsl:value-of select="normalize-space(substring-after(., ' '))"/>                                  
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>  
                </xsl:when>
                <xsl:otherwise>
               <dc:contributor xsi:type="pc:Contributor" thesis:role="editor">
                        <pc:person>
                            <pc:name type="otherName">
                                <pc:personEnteredUnderGivenName>
                                    	<xsl:value-of select="."/>
                                </pc:personEnteredUnderGivenName>                            
                            </pc:name>
                        </pc:person>
                    </dc:contributor>  
                </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>



            <!-- 11 Datum der Promotion dc.date.accepted to dcterms:dateAccepted -->
            <xsl:for-each select="doc:metadata/doc:element[@name='local']/doc:element[@name='date']/doc:element[@name='accepted']/doc:element/doc:field[@name='value']">
                <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="."/>
                </dcterms:dateAccepted>
            </xsl:for-each>



            <!-- 12 Datum der Erstveröffentlichung online dc.date.issued to dcterms:issued -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
                <dcterms:issued xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="."/>
                </dcterms:issued>
            </xsl:for-each>


            <!-- 14 Publikationstyp dc.type to dc:type xsi:type dini:PublType -->
            <!-- Modifying dc.type to suit the DINI "Gemeinsames Vokabular fuer Publikations- und Dokumentationstypen" -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
                <dc:type xsi:type="dini:PublType">
                    <xsl:choose>
                        <xsl:when test="string(text())='movingimage'">MovingImage</xsl:when>
                        <xsl:when test="string(text())='article'">article</xsl:when>
                        <xsl:when test="string(text())='book'">book</xsl:when>
                        <xsl:when test="string(text())='bookpart'">bookPart</xsl:when>
                        <xsl:when test="string(text())='dataset'">ResearchData</xsl:when>
                        <xsl:when test="string(text())='review'">review</xsl:when>                    
                         <xsl:when test="string(text())='journalissue'">Periodical</xsl:when>
                        <xsl:when test="string(text())='preprint'">preprint</xsl:when>
                        <xsl:when test="string(text())='postprint'">Other</xsl:when>
                        <xsl:when test="string(text())='software'">Software</xsl:when>
                        <xsl:when test="string(text())='report'">report</xsl:when>
                        <xsl:when test="string(text())='studythesis'">StudyThesis</xsl:when>
                        <xsl:when test="string(text())='workingpaper'">workingPaper</xsl:when>
                        <xsl:when test="string(text())='other'">Other</xsl:when>
                        <xsl:when test="string(text())='conferenceobject'">conferenceObject</xsl:when>
                        <xsl:when test="string(text())='doctoralthesis'">doctoralThesis</xsl:when>
                        <xsl:when test="string(text())='masterthesis'">masterThesis</xsl:when>
                        <xsl:when test="string(text())='bachelorthesis'">bachelorThesis</xsl:when>        
                        <xsl:when test="string(text())='periodicalpart'">PeriodicalPart</xsl:when>
                        <xsl:when test="string(text())='habilitation'">doctoralThesis</xsl:when>
                        <xsl:otherwise>Other</xsl:otherwise>
                    </xsl:choose>
                </dc:type>
            </xsl:for-each>
            
            
            <!-- 14 Publikation representational type to dc:type xsi:type dcterms:DCMIType -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
                <dc:type xsi:type="dcterms:DCMIType">
                    <xsl:choose>
                        <xsl:when test="string(text())='movingimage'">Image</xsl:when>
                        <xsl:when test="string(text())='article'">Text</xsl:when>
                        <xsl:when test="string(text())='book'">Text</xsl:when>
                        <xsl:when test="string(text())='bookpart'">Text</xsl:when>
                        <xsl:when test="string(text())='dataset'">Dataset</xsl:when>
                        <xsl:when test="string(text())='review'">Collection</xsl:when>                    
                         <xsl:when test="string(text())='journalissue'">Text</xsl:when>
                        <xsl:when test="string(text())='preprint'">Text</xsl:when>
                        <xsl:when test="string(text())='postprint'">Text</xsl:when>
                        <xsl:when test="string(text())='software'">Software</xsl:when>
                        <xsl:when test="string(text())='report'">Text</xsl:when>
                        <xsl:when test="string(text())='studythesis'">Text</xsl:when>
                        <xsl:when test="string(text())='workingpaper'">Text</xsl:when>
                        <xsl:when test="string(text())='other'">Collection</xsl:when>
                        <xsl:when test="string(text())='conferenceobject'">Text</xsl:when>
                        <xsl:when test="string(text())='doctoralthesis'">Text</xsl:when>
                        <xsl:when test="string(text())='masterthesis'">Text</xsl:when>
                        <xsl:when test="string(text())='bachelorthesis'">Text</xsl:when>        
                        <xsl:when test="string(text())='periodicalpart'">Text</xsl:when>
                        <xsl:when test="string(text())='habilitation'">Text</xsl:when>
                        <xsl:otherwise>Collection</xsl:otherwise>
                    </xsl:choose>
                </dc:type>
            </xsl:for-each>


	<!-- DOI  new, if existent, send as ddb:identifier -->
	<xsl:variable name="doiNew">
		<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']"/>
	</xsl:variable>

            
                    
      <!-- old DOIs from Opus, are saved in created.identifier.doi, send as ddb:identifier  -->
            <xsl:variable name="doiOpus">
	<!--	<xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']"/>   -->
		<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']"/>
	</xsl:variable>
            

            
           <!-- 16 Identifier get URN --> 
            <xsl:variable name="urn">
	<!--	<xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']"/>   -->
		<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']"/>
	</xsl:variable>
            
            <!-- 16 Identifikator URN created:identifier  xsi:type="urn:nbn" -->
            <xsl:if test="$urn != ''">
                    <dc:identifier xsi:type="urn:nbn">
                    	<xsl:choose>
                    	<xsl:when test="contains($urn, 'nbn-resolving.org/')">
                       	<xsl:value-of select="substring-after($urn, 'nbn-resolving.org/')"/>
                       </xsl:when>
                       <xsl:otherwise>
                       	<xsl:value-of select="$urn"/>
                       </xsl:otherwise>
                     </xsl:choose>
                    </dc:identifier>
	    </xsl:if>	    
	    	
		
                  
       <!-- Variables needed to create ZS-Ausgabe and to check if 1st or 2nd Publication -->        
	    <xsl:variable name="citation">
	    	<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='citation']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
            
            <xsl:variable name="journalTitle">
            <!--    <xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='journal']/doc:element[@name='title']/doc:element/doc:field[@name='value']"/>   -->
            	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='title']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
         
  	    <xsl:variable name="journalVolume">
             <!--   <xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='journal']/doc:element[@name='volume']/doc:element/doc:field[@name='value']"/>   -->
             	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='volume']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
  
  	    <xsl:variable name="journalIssue">
          <!--      <xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='journal']/doc:element[@name='issue']/doc:element/doc:field[@name='value']"/>   -->
          	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='issue']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
            
     	    <xsl:variable name="articleNr">
     		<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='document']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
    
            
            <xsl:variable name="pageStart">
            	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='document']/doc:element[@name='pagestart']/doc:element/doc:field[@name='value']"/>       	
            </xsl:variable>
            
            <xsl:variable name="pageEnd">
            	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='document']/doc:element[@name='pageend']/doc:element/doc:field[@name='value']"/>  
            </xsl:variable>
            
            <xsl:variable name="seriesName">
            <!--  <xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='series']/doc:element[@name='name']/doc:element/doc:field[@name='value']"/>  -->
            	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='series']/doc:element[@name='name']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
            
            <xsl:variable name="seriesNumber">
          <!--  	<xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='series']/doc:element[@name='number']/doc:element/doc:field[@name='value']"/>   -->
          	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='series']/doc:element[@name='number']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
            
            <xsl:variable name="seriesId">
            <!--	<xsl:value-of select="doc:metadata/doc:element[@name='created']/doc:element[@name='series']/doc:element[@name='id']/doc:element/doc:field[@name='value']"/>   -->
            	<xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='series']/doc:element[@name='id']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
            
            <xsl:variable name="pType">
                <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
            
            <xsl:variable name="publisherPlace">
                <xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='publisherplace']/doc:field[@name='value']"/>
            </xsl:variable>
    
         
         
          <!-- 20 Quelle der Hochschulschrift - if there is a print version, the ISBN can be referenced here: dc.identifier.isbn -->
         <!--   <xsl:for-each select="doc:metadata/doc:element[@name='created']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">  -->
         <xsl:for-each select="doc:metadata/doc:element[@name='local']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
                <dc:source xsi:type="ddb:ISBN">
                    <xsl:value-of select="."/>
                </dc:source>
            </xsl:for-each>
            
            
            <!-- 20 Quelle der Hochschulschrift - if there is a citation, the citation showed in dc:source noSchema -->
            <xsl:if test="$citation != ''">
             <dc:source xsi:type="ddb:noScheme">         
            		<xsl:value-of select="$citation"/>           	 
            </dc:source>
            </xsl:if>
            
   
            <!-- 20.Quelle der Hochschulschrift (NOT Original Publication) - dc:source info about ParentJournal for article,periodicalPart / info about ParentSeries for bookPart,book,thesis -->
            <xsl:if test="$publisher != 'FAU University Press' and $seriesId = ''">
             <xsl:if test="contains('|article|periodicalpart|', concat('|', $pType, '|'))">   
            	<!--Publisher NOT 'FAU University Press'=> 2nd Publication => dc:source JournalTitle, JVolume, JIssue, OrigPublisher, ArtNr, PageStart, PageEnd --> 	
            	<!--IS PERIODICAL / PUBLISHER NOT FAU -->      	
            		<dc:source xsi:type="ddb:noScheme">      		
            			<xsl:if test="$journalTitle != ''">
            				<xsl:value-of select="$journalTitle"/>
            			</xsl:if>
            			<xsl:if test="$journalVolume != ''">
            				<xsl:value-of select="' '"/>
            				<xsl:value-of select="$journalVolume"/>
            			</xsl:if>
            			
            			<xsl:if test="$journalIssue != ''">            				
            				<xsl:value-of select="' : '"/>
            				<xsl:value-of select="$journalIssue"/>
            				<xsl:value-of select="' '"/>
            			</xsl:if>
            			<xsl:if test="$publisher != '' and $publisher != 'Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU)'">     
            				<xsl:value-of select="' '"/>    			        
            				<xsl:value-of select="$publisher"/>
            				<xsl:value-of select="', '"/>
            				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']"/>
            			</xsl:if>
            			<xsl:if test="$articleNr != ''">
            				<xsl:value-of select="' - Art.-No. '"/>
            				<xsl:value-of select="$articleNr"/>
            			</xsl:if>
            			<xsl:if test="$pageStart != ''">
            				<xsl:value-of select="'  - S. '"/>
            				<xsl:value-of select="$pageStart"/>
            			</xsl:if>
            			<xsl:if test="$pageEnd != ''">
            				<xsl:value-of select="'-'"/>
            				<xsl:value-of select="$pageEnd"/>
            			</xsl:if>
            		</dc:source>
            	  </xsl:if>
            	 <xsl:if test="contains('|book|bookpart|doctoralthesis|studythesis|habilitation|masterthesis|bachelorthesis|', concat('|', $pType, '|'))">
            	 	<xsl:if test="$publisher != '' and $publisher != 'Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU)'">
            		       <dc:source xsi:type="ddb:noScheme">        			           		         
	    				<xsl:value-of select="$publisher"/>
	    				<xsl:value-of select="', '"/>
	    				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']"/>
	    			        <xsl:if test="$pageStart != ''">
	    				   <xsl:value-of select="' - S. '"/>
	    				   <xsl:value-of select="$pageStart"/>
	    			        </xsl:if>
	    			        <xsl:if test="$pageEnd != ''">
	    				   <xsl:value-of select="'-'"/>
	    				   <xsl:value-of select="$pageEnd"/>
	    			        </xsl:if>
            			</dc:source>
            		</xsl:if>
            	 </xsl:if>
            	</xsl:if>
            	
                             
            
                  <!-- 21 Sprache der Hochschulschrift dc.language.iso to dc:language xsi:type="dcterms:ISO639-2" -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
                <dc:language xsi:type="dcterms:ISO639-2">
                    <xsl:call-template name="getThreeLetterCodeLanguage">
                        <xsl:with-param name="lang2" select="."/>
                    </xsl:call-template>
                </dc:language>
            </xsl:for-each>   
            
            
           
            <!-- 29 Info about Parent Journal, for a Article or periodicalPart, if 1st Published -->
            <xsl:if test="$publisher = 'FAU University Press' or $seriesId != ''">
              <xsl:if test="contains('|article|periodicalpart|', concat('|', $pType, '|'))">
             	     <dcterms:isPartOf xsi:type="ddb:ZSTitelID">           	     
                        <xsl:if test="$seriesId != ''">
                        	<xsl:value-of select="$seriesId"/>
                        </xsl:if>
                    </dcterms:isPartOf>
                    <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
            		<xsl:if test="$journalVolume != ''">
            			<xsl:value-of select="'  Journal-Volume: '"/>
            			<xsl:value-of select="$journalVolume"/>
            		</xsl:if>
            		<xsl:if test="$journalIssue != ''">
            			<xsl:value-of select="'  Journal-Issue: '"/>
            			<xsl:value-of select="$journalIssue"/>
            		</xsl:if>
            		            		
            		<xsl:if test="$seriesNumber != '' and $journalIssue = '' and $journalVolume = ''">
            			<xsl:value-of select="'  Series Issue-Nr. '"/>
            			<xsl:value-of select="$seriesNumber"/>
            		</xsl:if>
                    </dcterms:isPartOf>
             </xsl:if>
             <xsl:if test="contains('|book|bookpart|doctoralthesis|studythesis|habilitation|masterthesis|bachelorthesis|', concat('|', $pType, '|'))">
                 <xsl:if test="$seriesName != '' or $seriesNumber != ''">
             	     <dcterms:isPartOf xsi:type="ddb:noScheme">
                    	<xsl:if test="$seriesName != ''">
            			<xsl:value-of select="$seriesName"/>
            			<xsl:value-of select="' ; '"/>
            		</xsl:if>                
            		<xsl:if test="$seriesNumber != ''">
            			<xsl:value-of select="$seriesNumber"/>
            		</xsl:if>
                    </dcterms:isPartOf>
                 </xsl:if>
            </xsl:if>
            </xsl:if>
            
            <!-- 29 Info about Parent Journal, for a Article or periodicalPart -->
            <!--Publisher NOT 'FAU University Press'=> 2nd Publication => dc:source JournalTitle, JVolume, JIssue, OrigPublisher, ArtNr, PageStart, PageEnd -->
            <!-- Publisher "FAU University Press"=> 1st Publication => dcterms:isPartOf ZSTitleID, ZS-Ausgabe (Vol and Issue),dc:source=citation (mde.fau.de)
                    				   <xsl:choose>
            			    <xsl:when test="$publisherPlace != ''"/>
            			           <xsl:value-of select="' - '"/>
            			  	   <xsl:value-of select="$publisherPlace"/>
            			  	   <xsl:value-of select="' : '"/>
            			      </xsl:when>
            			      <xsl:otherwise>
            			      	   <xsl:value-of select="' - '"/>
            			  	   <xsl:value-of select="'Erlangen'"/>
            			  	   <xsl:value-of select="' : '"/>
            			      </xsl:otherwise>
            			    </xsl:choose>    
            <xsl:if test="contains('|article|periodicalpart|doctoralthesis|studythesis|habilitation|masterthesis|bachelorthesis|', concat('|', $pType, '|'))">   
            	<xsl:choose>	
            	<xsl:when test="$publisher != 'FAU University Press'">	
            		<dc:source xsi:type="ddb:noScheme">      		
            			<xsl:if test="$journalTitle != ''">
            				<xsl:value-of select="'  Journal Title: '"/>
            				<xsl:value-of select="$journalTitle"/>
            			</xsl:if>
            			<xsl:if test="$journalVolume != ''">
            				<xsl:value-of select="'  Journal Vol. '"/>
            				<xsl:value-of select="$journalVolume"/>
            			</xsl:if>
            			<xsl:if test="$journalIssue != ''">
            				<xsl:value-of select="'  Journal Issue: '"/>
            				<xsl:value-of select="$journalIssue"/>
            			</xsl:if>
            			<xsl:if test="$publisher != ''">
            				<xsl:value-of select="'  Publisher: '"/>
            				<xsl:value-of select="$publisher"/>
            			</xsl:if>
            			<xsl:if test="$articleNr != ''">
            				<xsl:value-of select="'  Article Nr: '"/>
            				<xsl:value-of select="$articleNr"/>
            			</xsl:if>
            			<xsl:if test="$pageStart != ''">
            				<xsl:value-of select="'  Page Start: '"/>
            				<xsl:value-of select="$pageStart"/>
            			</xsl:if>
            			<xsl:if test="$pageEnd != ''">
            				<xsl:value-of select="'  Page End: '"/>
            				<xsl:value-of select="$pageEnd"/>
            			</xsl:if>
            		</dc:source>
            	</xsl:when>
            	<xsl:otherwise>          	         	     
            	     <dcterms:isPartOf xsi:type="ddb:ZSTitelID">           	     
                        <xsl:if test="$publisher = 'FAU University Press'">
                        	<xsl:text>36</xsl:text>
                        </xsl:if>
                    </dcterms:isPartOf>
                    <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
            		<xsl:if test="$journalVolume != ''">
            			<xsl:value-of select="'  Journal-Volume: '"/>
            			<xsl:value-of select="$journalVolume"/>
            		</xsl:if>
            		<xsl:if test="$journalIssue != ''">
            			<xsl:value-of select="'  Journal-Issue: '"/>
            			<xsl:value-of select="$journalIssue"/>
            		</xsl:if>
            		            		
            		<xsl:if test="$seriesNumber != ''">
            			<xsl:value-of select="'  Issue-Nr. '"/>
            			<xsl:value-of select="$seriesNumber"/>
            		</xsl:if>
                    </dcterms:isPartOf>
                </xsl:otherwise>
             </xsl:choose>
            </xsl:if>
            -->
                              

            <!-- 29 Info about Serie/BookParent, for a Book/bookpart -->
            <!--Publisher NOT 'FAU University Press'=> 2nd Publication => dc:source OrigPublisher, PageStart, PageEnd -->
            <!-- Publisher "FAU University Press"=> 1st Publication => dcterms:isPartOf ddb:noScheme (Vol and Issue),dc:source=citation (mde.fau.de)
            <xsl:if test="contains('|book|bookpart|doctoralthesis|studythesis|habilitation|masterthesis|bachelorthesis|', concat('|', $pType, '|'))">   
                <xsl:choose>
            	<xsl:when test="$publisher != 'FAU University Press'">
            		<dc:source xsi:type="ddb:noScheme">        			
            			<xsl:if test="$publisher != ''">
            				<xsl:value-of select="'  Publisher: '"/>
            				<xsl:value-of select="$publisher"/>
            			</xsl:if>
            			<xsl:if test="$pageStart != ''">
            				<xsl:value-of select="'  Page Start: '"/>
            				<xsl:value-of select="$pageStart"/>
            			</xsl:if>
            			<xsl:if test="$pageEnd != ''">
            				<xsl:value-of select="'  Page End: '"/>
            				<xsl:value-of select="$pageEnd"/>
            			</xsl:if>
            		</dc:source>
            	</xsl:when>          
            	<xsl:otherwise>
                    <dcterms:isPartOf xsi:type="ddb:noScheme">
                    	<xsl:if test="$seriesName != ''">
            			<xsl:value-of select="$seriesName"/>
            			<xsl:value-of select="' ; '"/>
            		</xsl:if>                
            		<xsl:if test="$seriesNumber != ''">
            			<xsl:value-of select="$seriesNumber"/>
            		</xsl:if>
                    </dcterms:isPartOf>
                </xsl:otherwise>
             </xsl:choose>
            </xsl:if>                 
          -->
         

            <!-- 39: dc:rights uri -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
                <dc:rights xsi:type="dcterms:URI">
                    <xsl:value-of select="."/>
                </dc:rights>
            </xsl:for-each>
  

            <!-- Hochschulschriftenvermerk for Thesis, dc.type.publicationtype to thesis.degree -->
            <!-- possible xmetadissplus types thesis.doctoral, thesis.habilitation, bachelor, master, post-doctoral, Staatsexamen, Diplom, Lizentiat, M.A., other -->           
            <xsl:if test="($pType = 'doctoralthesis')	or ($pType = 'studythesis') or ($pType = 'habilitation') or ($pType = 'masterthesis') or ($pType = 'bachelorthesis')">
                <xsl:variable name="grantor">
                <!--ORG modified steli 73
                    <xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='thesis']/doc:element[@name='grantor']/doc:element/doc:field[@name='value']"/>
                    -->
                    
                    <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='provenance']/doc:element/doc:field[@name='value']"/>
                </xsl:variable>
                <xsl:variable name="grantorName">
                    <xsl:choose>
                        <xsl:when test="$grantor = ''">
                            <xsl:text>Friedrich-Alexander-Universität Erlangen-Nürnberg</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains($grantor, ',')">
                            <xsl:value-of select="substring-before($grantor, ',')"/>
                        </xsl:when>
                        <xsl:otherwise>
                        	<xsl:value-of select="$grantor"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <thesis:degree>
                    <thesis:level>
                        <xsl:choose>
                            <xsl:when test="$pType = 'bachelorthesis'">
                                <xsl:text>bachelor</xsl:text>
                            </xsl:when>
                            <xsl:when test="$pType = 'doctoralthesis'">
                                <xsl:text>thesis.doctoral</xsl:text>
                            </xsl:when>
                            <xsl:when test="$pType = 'masterthesis'">
                                <xsl:text>master</xsl:text>
                            </xsl:when>
                            <xsl:when test="$pType = 'habilitation'">
                                <xsl:text>thesis.habilitation</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </thesis:level>
                    <thesis:grantor xsi:type="cc:Corporate" type="dcterms:ISO3166" countryCode="DE">
                        <cc:universityOrInstitution>
                            <cc:name>
                            	<xsl:value-of select="$grantorName"/>
                            </cc:name>
                            <cc:place>Erlangen</cc:place>
                            <xsl:if test="substring-after($grantor, ',') != ''">
                                <cc:department>
                                    <cc:name>
                                    	<xsl:value-of select="normalize-space(substring-after($grantor, ','))"/>
                                    </cc:name>
                                    <cc:place>Erlangen</cc:place>
                                </cc:department>
                            </xsl:if>
                        </cc:universityOrInstitution>
                    </thesis:grantor>
                </thesis:degree>
            </xsl:if>


            <!-- amount of files based on the description DNB of the bitstreams in the bundle original to ddb:FileNumber -->

            <xsl:variable name="fileNumber">
                <xsl:value-of select="count(/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream'])"/>
            </xsl:variable>

            <ddb:fileNumber>
                <xsl:value-of select="$fileNumber"/>
            </ddb:fileNumber>

            <!-- 44. File properties -->
            <xsl:for-each select="/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                
                <ddb:fileProperties>
                    <xsl:attribute name="ddb:fileName">
                        <xsl:value-of select="./doc:field[@name='name']"/>
                    </xsl:attribute>
                    <xsl:attribute name="ddb:fileSize">
                        <xsl:value-of select="./doc:field[@name='size']"/>
                    </xsl:attribute>
                </ddb:fileProperties>
            </xsl:for-each>

            <!-- ddb:transfer - normal bitstream link if 1 or special retrieve link > 1 -->
            <!-- the "url" in xoai assumes that dspace is deployed as root application -->
            <xsl:variable name="bundleName">
                <!-- If there is more than only one file, get the archive, otherwise the original bundle -->
                <xsl:choose>
                    <xsl:when test="$fileNumber > '1'">ARCHIVE</xsl:when>
                    <xsl:otherwise>ORIGINAL</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
<!--
<xsl:if test="$bundleName = 'ARCHIVE'"> <xsl:text>arhiva</xsl:text></xsl:if>
<xsl:if test="$bundleName = 'ORIGINAL'"> <xsl:text>originala</xsl:text></xsl:if>
<xsl:if test="$bundleName = ''"> <xsl:text>empty</xsl:text></xsl:if>
-->
            <xsl:for-each select="/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()=$bundleName]/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                <!-- 45. Checksum -->
                <ddb:checksum>
                    <xsl:attribute name="ddb:type">
                        <xsl:value-of select="./doc:field[@name='checksumAlgorithm']"/>
                    </xsl:attribute>
                    <xsl:value-of select="./doc:field[@name='checksum']"/>
                </ddb:checksum>

                <!-- 46. Transfer-URL, created in xoai/ItemUtils.java -->
                <ddb:transfer ddb:type="dcterms:URI">
                    <xsl:value-of select="./doc:field[@name='url']"/>
                </ddb:transfer>
            </xsl:for-each>



            <!-- 47. Further Identifier: ISSN -->
          <!--  <xsl:for-each select="doc:metadata/doc:element[@name='created']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">  -->
          <xsl:for-each select="doc:metadata/doc:element[@name='local']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
                <ddb:identifier ddb:type="ISSN">
                    <xsl:value-of select="."/>
                </ddb:identifier>
            </xsl:for-each>
            
            
              <!-- 47. Further Identifier: DOI -->
            <xsl:if test="$doiNew != ''">
                    <ddb:identifier ddb:type="DOI">
                      <xsl:choose>
                    	<xsl:when test="contains($doiNew, 'doi.org/')">
                       	<xsl:value-of select="substring-after($doiNew, 'doi.org/')"/>
                       </xsl:when>
                       <xsl:otherwise>
                       	<xsl:value-of select="$doiNew"/>
                       </xsl:otherwise>
                     </xsl:choose>
                   </ddb:identifier>
            </xsl:if>
            
            
                 <xsl:if test="$doiOpus != ''">
                    <ddb:identifier ddb:type="DOI">
                      <xsl:choose>
                    	<xsl:when test="contains($doiOpus, 'doi.org/')">
                       	<xsl:value-of select="substring-after($doiOpus, 'doi.org/')"/>
                       </xsl:when>
                       <xsl:otherwise>
                       	<xsl:value-of select="$doiOpus"/>
                       </xsl:otherwise>
                     </xsl:choose>
                    </ddb:identifier>
            </xsl:if>
         


            <!-- 48. ddb:rights from local.sendToDnb -->
            <xsl:variable name="accessrights" select="doc:metadata/doc:element[@name='local']/doc:element[@name='sendToDnb']/doc:element/doc:field[@name='value']"/>
            <ddb:rights>
                <xsl:attribute name="ddb:kind">
                <xsl:choose>
                    <xsl:when test="$accessrights">
                        <xsl:value-of select="$accessrights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'unknown'"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </ddb:rights>


            <!-- 50. ddb:server - default FAU Erlangen -->
            <ddb:server>
                <xsl:text>FAU Erlangen</xsl:text>
            </ddb:server>

        </xMetaDiss:xMetaDiss>
    </xsl:template>

</xsl:stylesheet>
