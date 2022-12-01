<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at
    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>
	
	> http://www.openarchives.org/OAI/2.0/oai_dc.xsd
 -->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:oaire="http://namespace.openaire.eu/schema/oaire/" 
    xmlns:datacite="http://datacite.org/schema/kernel-4"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/" 
    xmlns:doc="http://www.lyncode.com/xoai"
    xmlns:rdf="http://www.w3.org/TR/rdf-concepts/" version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
		
 	  <oaire:resource xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://namespace.openaire.eu/schema/oaire/ https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd">
			
			<!-- dc.title and dc.title.* -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<datacite:titles>
				<!-- dc.title -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">				
		      				<datacite:title><xsl:value-of select="." /></datacite:title>     				
					</xsl:for-each>
				<!-- dc.title.* -->	
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:element/doc:field[@name='value']">				
		      					<datacite:title titleType="AlternativeTitle"><xsl:value-of select="." /></datacite:title>     				
					</xsl:for-each>
				</datacite:titles>
			</xsl:if>						
				
			<!-- dc.creator -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
			<datacite:creators>
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">			 
      					<datacite:creator>
         					<datacite:creatorName><xsl:value-of select="." /></datacite:creatorName>
         				</datacite:creator> 
         			</xsl:for-each>
         		<!-- dc.contributor.author -->
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
						<datacite:creator>
	         					<datacite:creatorName><xsl:value-of select="." /></datacite:creatorName>
	         				</datacite:creator> 
				</xsl:for-each>  		
			</datacite:creators>
			</xsl:if>
			
			
			<!-- dc.contributor.advisor -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='advisor']/doc:element/doc:field[@name='value']
				or doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']
				or doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
			<datacite:contributors>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='advisor']/doc:element/doc:field[@name='value']">
				 <datacite:contributor contributorType="Other">
          				<datacite:contributorName>
          					<xsl:value-of select="." />
          				</datacite:contributorName>
          			</datacite:contributor>
			</xsl:for-each>
			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<datacite:contributor contributorType="Supervisor">
          				<datacite:contributorName>
          					<xsl:value-of select="." />
          				</datacite:contributorName>
          			</datacite:contributor>
			</xsl:for-each>
			<!-- dc.contributor.editor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']">
				 <datacite:contributor contributorType="Editor">
          				<datacite:contributorName>
          					<xsl:value-of select="." />
          				</datacite:contributorName>
          			</datacite:contributor>
			</xsl:for-each>
			</datacite:contributors>
			</xsl:if>
			
			<!-- oaire:fundingRefence -->
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eugrant']/doc:element/doc:field/text()">
	       	<oaire:fundingReferences>
 			 <oaire:fundingReference>
 			  <oaire:funderName>
				<xsl:choose>
				<xsl:when test="starts-with(., 'EC')">
					 European Commission
				</xsl:when>
				<!-- in case we have something else -> Hr Putnings says it is ok to put only European Commission -->
				<xsl:otherwise>
					 European Commission	
				</xsl:otherwise>
	     			</xsl:choose>
     			 </oaire:funderName>
	     		 <oaire:awardNumber>
			 	  <xsl:value-of select="."/>
			 </oaire:awardNumber>
	       	</oaire:fundingReference>
 		      </oaire:fundingReferences>
		</xsl:for-each>
			
			<!-- dc.subject -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
			<datacite:subjects>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<datacite:subject><xsl:value-of select="." /></datacite:subject>
			</xsl:for-each>
			<!-- dc.subject.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:element/doc:field[@name='value']">
				<datacite:subject><xsl:value-of select="." /></datacite:subject>
			</xsl:for-each>
			</datacite:subjects>
			</xsl:if>
			
			<!-- dc.description.abstract -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>
			
            <!-- dc.date.* -->
            <datacite:dates>     
            	<datacite:date dateType="Issued">
            		<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']" />
            	</datacite:date>                                      
            <!-- For openAire, give dc.date.available = embargoEnd, if the item has others.openAireAccess = embargoed access (embargoEnd was set in embargo_selector.xsl, from xoai/Utils.ItemUtils.java) -->
		<xsl:if test="contains(doc:metadata/doc:element[@name='others']/doc:field[@name='openAireAccess'], 'embargoed')" >
			<datacite:date dateType="Accepted">
			<!-- Date document enters repository, but in embargo 
            			<xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']/doc:element/doc:field[@name='value'],1, 10)" />
            			-->
            			<!-- openAIRE let us use issue date and accepted date interchangeable, reffers to date creation or date available -->
            			<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']" />
            		</datacite:date> 
			<!-- in embargo till this date -->
			<datacite:date dateType="Available">
            			<xsl:value-of select="doc:metadata/doc:element[@name='others']/doc:field[@name='embargoEnd']" />
    			</datacite:date>
		</xsl:if>   		  
	     </datacite:dates>	     	    
	     
	     
	     <!-- dc.rights.uri -->        
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" >         
		<oaire:licenseCondition>
		    <xsl:attribute name="uri">
		        <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" />
		    </xsl:attribute>
		    <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" />
		</oaire:licenseCondition>
	    </xsl:if>

            
            <!-- File Location aka URL to download from -->
            <xsl:variable name="fileNumber">
                <xsl:value-of select="count(/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream'])"/>
            </xsl:variable>
            <xsl:variable name="bundleName">
                <!-- If there is more than only one file, get the archive, otherwise the original bundle -->
                <xsl:choose>
                    <xsl:when test="$fileNumber > '1'">ARCHIVE</xsl:when>
                    <xsl:otherwise>ORIGINAL</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()=$bundleName]/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
            <oaire:file>
            	<xsl:value-of select="./doc:field[@name='url']"/>
            </oaire:file>             
            </xsl:for-each>
            
	<!--dc.type from openAIRE mapped -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
			   <xsl:choose>
			    <xsl:when test=". = 'journalissue'">
				<oaire:resourceType resourceTypeGeneral="literature" uri="http://purl.org/coar/resource_type/c_3e5a">contribution to journal</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'article'">
				<oaire:resourceType resourceTypeGeneral="literature" uri="http://purl.org/coar/resource_type/c_6501">journal article</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'bachelorthesis'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_7a1f">bachelor thesis</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'book'">
				<oaire:resourceType resourceTypeGeneral="literature" uri="http://purl.org/coar/resource_type/c_2f33">book</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'bookpart'">
				<oaire:resourceType resourceTypeGeneral="literature" uri="http://purl.org/coar/resource_type/c_3248">book part</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'conferenceobject'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_c94f">conference object</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'dataset'">
				<oaire:resourceType resourceTypeGeneral="dataset" uri="http://purl.org/coar/resource_type/c_ddb1">dataset</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'doctoralthesis'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_db06">doctoral thesis</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'habilitation'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_1843">other</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'image'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_c513">image</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'coursematerial'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_8544">lecture</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'masterthesis'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_bdcc">master thesis</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'movingimage'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_8a7e">moving image</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'periodicalpart'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_1843">other</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'preprint'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_816b">preprint</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'report'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_93fc">report</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'review'">		
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_efa0">review</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'software'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_5ce6">software</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'workingpaper'">
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_8042">working paper</oaire:resourceType>
			    </xsl:when>
			    <xsl:when test=". = 'studythesis'">			
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_46ec">conference object</oaire:resourceType>
			    </xsl:when>
			    <!-- other -->
			    <xsl:otherwise>
				<oaire:resourceType resourceTypeGeneral="other research product" uri="http://purl.org/coar/resource_type/c_1843">other</oaire:resourceType>
			    </xsl:otherwise>
			    </xsl:choose>
			</xsl:for-each>



			<!-- dc.type used for openAire Version
			<xsl:if test="doc:metadata/doc:element[@name='others']/doc:field[@name='openAireAccess']
						and not(doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']/doc:element/doc:field[@name='value'])">
				<xsl:variable name="publType" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']"/>
				<xsl:if test="contains($publType, 'info:eu-repo/semantics/doctoralThesis') 
					or contains($publType, 'info:eu-repo/semantics/masterThesis') 
					or contains($publType, 'info:eu-repo/semantics/bachelorThesis')">
					<xsl:choose>
						<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
							<dc:type>info:eu-repo/semantics/publishedVersion</dc:type>
						</xsl:when>
						<xsl:otherwise>
							<dc:type>info:eu-repo/semantics/acceptedVersion</dc:type>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="contains($publType, 'info:eu-repo/semantics/book')
					and contains(doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value'], 'Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU)')">
					<dc:type>info:eu-repo/semantics/publishedVersion</dc:type>
				</xsl:if>
			</xsl:if>
			-->
			
			
			<!-- Sort identifiers - doi first, other urls of isbn etc. afterwords -->
			<!-- dc.identifier.uri and dc.identifier.doi as doi -->	
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
				<xsl:if test="contains(., 'doi.org')">
				<datacite:identifier identifierType="DOI">
					<xsl:value-of select="." />
				</datacite:identifier>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<datacite:identifier identifierType="DOI">
					<xsl:value-of select="." />
				</datacite:identifier>
			</xsl:for-each>
			
			<!-- dc.identifier.urn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">
				<datacite:identifier identifierType="URN">
					<xsl:value-of select="." />
				</datacite:identifier>
			</xsl:for-each>
			
			<!-- dc.identifier.* other than doi or urn as alternate identifier-->
			<datacite:alternateIdentifiers>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
				<xsl:if test="not(contains(., 'doi.org'))">
				<datacite:alternateIdentifier alternateIdentifierType="Handle">
					<xsl:value-of select="." />
				</datacite:alternateIdentifier>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='arxiv']/doc:element/doc:field[@name='value']">
				<datacite:alternateIdentifier alternateIdentifierType="arXiv">
					<xsl:value-of select="." />
				</datacite:alternateIdentifier>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
				<datacite:alternateIdentifier alternateIdentifierType="ISBN">
					<xsl:value-of select="." />
				</datacite:alternateIdentifier>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
				<datacite:alternateIdentifier alternateIdentifierType="ISSN">
					<xsl:value-of select="." />
				</datacite:alternateIdentifier>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='pmid']/doc:element/doc:field[@name='value']">
				<datacite:alternateIdentifier alternateIdentifierType="PMID">
					<xsl:value-of select="." />
				</datacite:alternateIdentifier>
			</xsl:for-each>
			</datacite:alternateIdentifiers>
			
			<!-- dc.language -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<dc:language><xsl:value-of select="." /></dc:language>
			</xsl:for-each>
			<!-- dc.language.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
				<dc:language><xsl:value-of select="." /></dc:language>
			</xsl:for-each>
			
			<!-- dc.relation and dc.relation.*  
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			-->
			
			<!-- dc.description.sponsorship 
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='sponsorship']/doc:element/doc:field[@name='value'][text() != '']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			-->
			
			<!-- dc.rights and dc.rights.*
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>
			-->
			
			<!-- dc.rights for openAire -->
			<xsl:for-each select="doc:metadata/doc:element[@name='others']/doc:field[@name='openAireAccess']">
				<xsl:if test="contains(doc:metadata/doc:element[@name='others']/doc:field[@name='openAireAccess'], 'embargoed')">
					<datacite:rights rightsURI="http://purl.org/coar/access_right/c_f1cf">embargoed access</datacite:rights>
				</xsl:if>	
				<xsl:if test="contains(doc:metadata/doc:element[@name='others']/doc:field[@name='openAireAccess'], 'open')">
					<datacite:rights rightsURI="http://purl.org/coar/access_right/c_abf2">open access</datacite:rights>
				</xsl:if>	
			</xsl:for-each>
			
			<!-- dc.format -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<dc:format><xsl:value-of select="." /></dc:format>
			</xsl:for-each>
			
			<!-- bitstream format from the ORIGINAL bundle -->
			<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name'][text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
				<dc:format><xsl:value-of select="." /></dc:format>
			</xsl:for-each>
					
			<!-- dc.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<dc:publisher><xsl:value-of select="." /></dc:publisher>
			</xsl:for-each>
			<!-- if dc.publisher is empty -->
			<xsl:if test="not(doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value'])">
				<dc:publisher><xsl:text>Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU)</xsl:text></dc:publisher>
			</xsl:if>			
			
			<!-- dc.source -->
			<xsl:if test="doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='title']/doc:element/doc:field[@name='value']
						or doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='volume']/doc:element/doc:field[@name='value']
						or doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='issue']/doc:element/doc:field[@name='value']
						or doc:metadata/doc:element[@name='local']/doc:element[@name='document']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']">
				<dc:source>
				<xsl:if test="doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
					<xsl:value-of select="." />
				</xsl:if>	
				<xsl:if test="doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='volume']/doc:element/doc:field[@name='value']">
					, <xsl:value-of select="." />
				</xsl:if>
				<xsl:if test="doc:metadata/doc:element[@name='local']/doc:element[@name='journal']/doc:element[@name='issue']/doc:element/doc:field[@name='value']">
					, <xsl:value-of select="." />
				</xsl:if>
				<xsl:if test="doc:metadata/doc:element[@name='local']/doc:element[@name='document']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']">
					, <xsl:value-of select="." />
				</xsl:if>
				</dc:source>
			</xsl:if>

			
		</oaire:resource>
	</xsl:template>
</xsl:stylesheet>
