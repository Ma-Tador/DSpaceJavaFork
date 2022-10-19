<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:mods="http://www.loc.gov/mods/v3"
                version="1.0">
<!--
                **************************************************
                MODS-2-DIM  ("DSpace Intermediate Metadata" ~ Dublin Core variant)
                For a DSpace INGEST Plug-In Crosswalk
                William Reilly wreilly@mit.edu
                INCOMPLETE
                but as Work-In-Progress, should satisfy current project with CSAIL.
                See: http://cwspace.mit.edu/docs/WorkActivity/Metadata/Crosswalks/QDC-MODS/CSAILQDC-MODSxwalkv1p0.pdf
                Last modified: November 14, 2005
http://cwspace.mit.edu/docs/WorkActivity/Metadata/Crosswalks/MODS-2-DIM/CSAILMODS.xml
http://cwspace.mit.edu/docs/WorkActivity/Metadata/Crosswalks/MODS-2-DIM/MODS-2-DIM.xslt
http://cwspace.mit.edu/docs/WorkActivity/Metadata/Crosswalks/MODS-2-DIM/CSAIL-DIMfromMODS.xml

 Author:   William Reilly
 Revision: $Revision$
 Date:     $Date$


     **************************************************
-->

        <!-- This XSLT file (temporarily, in development)
[wreilly ~/Documents/CWSpace/WorkActivityLOCAL/Metadata/Crosswalks/MODS-2-DIM ]$MODS-2-DIM.xslt

$ scp MODS-2-DIM.xslt athena.dialup.mit.edu:~/Private/

        See also mods.properties in same directory.
        e.g. dc.contributor = <mods:name><mods:namePart>%s</mods:namePart></mods:name> | mods:namePart/text()
-->

        <!-- Source XML:
                CSAIL example
                http://cwspace.mit.edu/docs/WorkActivity/Metadata/Crosswalks/QDC-MODS/CSAILQDC-MODSxwalkv1p0.pdf

        Important to See Also: "DCLib (DSpace) to MODS mapping == Dublin Core with Qualifiers==DSpace application"              http://cwspace.mit.edu/docs/WorkActivity/Metadata/Crosswalks/MODSmapping2MB.html

        See Also: e.g.  MODS Sample: "Article in a serial"
                http://www.loc.gov/standards/mods/v3/modsjournal.xml
        -->
                
        <!-- Target XML:
                http://wiki.dspace.org/DspaceIntermediateMetadata
                
                e.g. <dim:dim xmlns:dim="http://www.dspace.org/xmlns/dspace/dim">
                <dim:field mdschema="dc" element="title" lang="en_US">CSAIL Title - The Urban Question as a Scale Question</dim:field>
                <dim:field mdschema="dc" element="contributor" qualifier="author" lang="en_US">Brenner, Neil</dim:field>
                ...
        -->


        <!-- Dublin Core schema links:
                        http://dublincore.org/schemas/xmls/qdc/2003/04/02/qualifieddc.xsd
                        http://dublincore.org/schemas/xmls/qdc/2003/04/02/dcterms.xsd  -->

        <xsl:output indent="yes" method="xml"/>
        <!-- Unnecessary attribute:
                xsl:exclude-result-prefixes=""/> -->



<!-- WR_ Unnecessary, apparently.
        <xsl:template match="@* | node()">
                <xsl:copy>
                        <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
        </xsl:template>
-->
        
<!-- WR_ Unnecessary, apparently.
        <xsl:template match="/">
                <xsl:apply-templates/>
        </xsl:template>
-->

        <xsl:template match="text()">
                <!--
                                Do nothing.

                                Override, effectively, the "Built-In" rule which will
                                process all text inside elements otherwise not matched by any xsl:template.

                                Note: With this in place, be sure to then provide templates or "value-of"
                                statements to actually _get_ the (desired) text out to the result document!
                -->
        </xsl:template>


<!-- **** MODS  mods  [ROOT ELEMENT] ====> DC n/a **** -->
        <xsl:template match="*[local-name()='mods']">
                <!-- fwiw, these match approaches work:
                        <xsl:template match="mods:mods">...
                        <xsl:template match="*[name()='mods:mods']">...
                        <xsl:template match="*[local-name()='mods']">...
                        ...Note that only the latter will work on XML data that does _not_ have
                        namespace prefixes (e.g. <mods><titleInfo>... vs. <mods:mods><mods:titleInfo>...)
                -->
                <xsl:element name="dim:dim">

        <xsl:comment>IMPORTANT NOTE:
                ****************************************************************************************************
                THIS "Dspace Intermediate Metadata" ('DIM') IS **NOT** TO BE USED FOR INTERCHANGE WITH OTHER SYSTEMS.
                ****************************************************************************************************
                It does NOT pretend to be a standard, interoperable representation of Dublin Core.

                It is expressly used for transformation to and from source metadata XML vocabularies into and out of the DSpace object model.

                See http://wiki.dspace.org/DspaceIntermediateMetadata

                For more on Dublin Core standard schemata, see:
                        http://dublincore.org/schemas/xmls/qdc/2003/04/02/qualifieddc.xsd
                        http://dublincore.org/schemas/xmls/qdc/2003/04/02/dcterms.xsd

        </xsl:comment>


<!-- WR_ NAMESPACE NOTE
        Don't "code into" this XSLT the creation of the attribute with the name 'xmlns:dim', to hold the DSpace URI for that namespace.
        NO: <dim:field mdschema="dc" element="title" lang="en_US" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim">
        Why not?
        Because it's an error (or warning, at least), and because the XML/XSLT tools (parsers, processors) will take care of it for you. ("Ta-da!")
        [fwiw, I tried this on 4 processors: Sablotron, libxslt, Saxon, and Xalan-J (using convenience of TestXSLT http://www.entropy.ch/software/macosx/ ).]
        -->
<!-- WR_ Do Not Use (see above note)
                <xsl:attribute name="xmlns:dim">http://www.dspace.org/xmlns/dspace/dim</xsl:attribute>
        -->
                        <xsl:apply-templates/>
                </xsl:element>
        </xsl:template>

<!-- **** MODS   titleInfo/title ====> DC title **** -->
        <xsl:template match="*[local-name()='titleInfo']/*[local-name()='title']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">title</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>


<!-- **** MODS   titleInfo/subTitle ====> DC title ______ (?) **** -->
        <!-- TODO No indication re: 'subTitle' from this page:
                http://cwspace.mit.edu/docs/WorkActivity/Metadata/Crosswalks/MODSmapping2MB.html
                -->
        <!-- (Not anticipated from CSAIL.) -->
<!--
        <xsl:template match="*[local-name()='titleInfo']/*[local-name()='subTitle']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">title</xsl:attribute>
                        <xsl:attribute name="qualifier">SUB-TITLE (TODO ?)</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>
-->

<!-- **** MODS   titleInfo/@type="alternative" ====> DC title.alternative **** -->
        <xsl:template match="*[local-name()='titleInfo'][@type='alternative']">
                <!-- TODO Three other attribute values:
                        http://www.loc.gov/standards/mods/mods-outline.html#titleInfo
                        -->
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">title</xsl:attribute>
                        <xsl:attribute name="qualifier">alternative</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>



<!-- **** MODS  name ====> DC  contributor.{role/roleTerm} **** -->
        <xsl:template match="*[local-name()='name']">
        <xsl:variable name="contributorFamName" select="*[local-name()='namePart'][@type='family']"/>
        <xsl:variable name="contributorGivenName" select="*[local-name()='namePart'][@type='given']"/>
        <xsl:variable name="contributorName" select="concat($contributorFamName,', ',$contributorGivenName)"/>
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">contributor</xsl:attribute>
                        <!-- Important assumption: That the string value used
                                in the MODS role/roleTerm is indeed a DC Qualifier.
                                e.g. contributor.illustrator
                                (Using this assumption, rather than coding in
                                a more controlled vocabulary via xsl:choose etc.)
                                -->
                        <xsl:attribute name="qualifier"><xsl:value-of select="*[local-name()='role']/*[local-name()='roleTerm']"/></xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
<!-- TODO: Logic (xsl:choose) re: format of names in source XML (e.g. Smith, John; or Fname and Lname in separate elements, etc.) -->
<!-- Used for CSAIL == simply:
                        <namePart>Lname, Fname</namePart>
                        <xsl:variable name="contributorName" select="concat(*[local-name()='namePart'][@type='family'],', '*[local-name()='namePart'][@type='given'])"/>
                        <xsl:value-of select="*[local-name()='namePart']"/> ORG
-->
                        
                        <xsl:value-of select="$contributorName"/>

<!-- Not Used for CSAIL
                        <namePart type="family">Lname</namePart> <namePart type="given">Fname</namePart>
-->
<!--    (Therefore, not used here)
                        <xsl:value-of select="*[local-name()='namePart'][@type='given']"/><xsl:text> </xsl:text><xsl:value-of select="*[local-name()='namePart'][@type='family']"/>
-->
        </xsl:element>
</xsl:template>


<!-- **** MODS   originInfo/dateCreated ====> DC  date.created **** -->
        <xsl:template match="*[local-name()='originInfo']/*[local-name()='dateCreated']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">date</xsl:attribute>
                        <xsl:attribute name="qualifier">created</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="."/>
                </xsl:element>
        </xsl:template>

<!-- **** MODS   originInfo/dateIssued ====> DC  date.issued **** -->
        <xsl:template match="*[local-name()='originInfo']/*[local-name()='dateIssued']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">date</xsl:attribute>
                        <xsl:attribute name="qualifier">issued</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="."/>
                </xsl:element>
        </xsl:template>
        
        
        <!-- **** MODS   originInfo/dateIssued ====> DC  date.issued **** -->
        <xsl:template match="*[local-name()='originInfo']/*[local-name()='dateOther'][@type='accepted']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">date</xsl:attribute>
                        <xsl:attribute name="qualifier">accepted</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="."/>
                </xsl:element>
        </xsl:template>


<!-- **** MODS   physicalDescription/extent ====> DC  format.extent **** -->
        <xsl:template match="*[local-name()='physicalDescription']/*[local-name()='extent']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">format</xsl:attribute>                    
                        <xsl:attribute name="qualifier">extent</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="."/>
                </xsl:element>
        </xsl:template>

<!-- **** MODS   abstract  ====> DC  description.abstract **** -->
        <xsl:template match="*[local-name()='abstract']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">description</xsl:attribute>                       
                        <xsl:attribute name="qualifier">abstract</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>


<!-- **** MODS   subject/topic ====> DC  subject **** -->
        <xsl:template match="*[local-name()='subject']/*[local-name()='topic']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">subject</xsl:attribute>                   <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>


<!-- **** MODS   subject/geographic ====> DC  coverage.spatial **** -->
        <!-- (Not anticipated for CSAIL.) 
        <xsl:template match="*[local-name()='subject']/*[local-name()='geographic']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">coverage</xsl:attribute>                                                  
                        <xsl:attribute name="qualifier">spatial</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>
        -->

<!-- **** MODS   subject/temporal ====> DC  coverage.temporal **** -->
        <!-- (Not anticipated for CSAIL.) 
        <xsl:template match="*[local-name()='subject']/*[local-name()='temporal']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">coverage</xsl:attribute>                                                  <xsl:attribute name="qualifier">temporal</xsl:attribute>
                        <xsl:attribute name="lang">en_US</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>
        -->


<!-- **** MODS   relatedItem...    **** -->
        <!-- NOTE -
                HAS *TWO* INTERPRETATIONS IN DC:
                1) DC  identifier.citation
                MODS [@type='host'] {/part/text}       ====> DC  identifier.citation
                2) DC  relation.___
                MODS [@type='____'] {/titleInfo/title} ====> DC  relation.{ series | host | other...}
        -->
        <xsl:template match="*[local-name()='relatedItem'][@type='host']">
                        <!-- 1)  DC  identifier.citation  -->
                           <!-- Note: CSAIL Assumption (and for now, generally):
                                        The bibliographic citation is _not_ parsed further,
                                        and one single 'text' element will contain it.
                                        e.g. <text>Journal of Physics, v. 53, no. 9, pp. 34-55, Aug. 15, 2004</text>
                                        -->
                        <xsl:if test="*[local-name()='part']/*[local-name()='text']">
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                                        <xsl:attribute name="element">identifier</xsl:attribute>
                                        <xsl:attribute name="qualifier">citation</xsl:attribute>
                                        <xsl:value-of select="normalize-space(*[local-name()='part']/*[local-name()='text'])"/>
                                </xsl:element>
                        </xsl:if>
                        <!-- 2)  DC  created.journal.title  
                        <xsl:if test="./@type='host'  and   *[local-name()='titleInfo']/*[local-name()='title']">
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">created</xsl:attribute>
                                        <xsl:attribute name="element">journal</xsl:attribute>
                                        <xsl:attribute name="qualifier">title</xsl:attribute>
                                        <xsl:value-of select="normalize-space(*[local-name()='titleInfo']/*[local-name()='title'])"/>
                                </xsl:element>
                        </xsl:if>
                        -->
                        <!-- 3)  DC  created.identifier.issn  -->
                        <xsl:if test="*[local-name()='identifier'][@type='issn']">
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">local</xsl:attribute>
                                        <xsl:attribute name="element">identifier</xsl:attribute>
                                        <xsl:attribute name="qualifier">issn</xsl:attribute>
                                        <xsl:value-of select="normalize-space(*[local-name()='identifier'][@type='issn'])"/>
                                </xsl:element>
                        </xsl:if>
                        
                         <!-- 4)  DC  created.identifier.isbn  -->
                        <xsl:if test="*[local-name()='identifier'][@type='isbn']">
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">local</xsl:attribute>
                                        <xsl:attribute name="element">identifier</xsl:attribute>
                                        <xsl:attribute name="qualifier">isbn</xsl:attribute>
                                        <xsl:value-of select="normalize-space(*[local-name()='identifier'][@type='isbn'])"/>
                                </xsl:element>
                        </xsl:if>
                        
                        
                         <!-- 4b)  DC  created.identifier.other  -->
                     <xsl:for-each select="*[local-name()='identifier'][@type != 'doi' and @type != 'urn' and @type != 'uri' and @type != 'issn' and @type != 'isbn']">
                     
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">local</xsl:attribute>
                                        <xsl:attribute name="element">identifier</xsl:attribute>
                                        <xsl:attribute name="qualifier">other</xsl:attribute>
                                        <xsl:value-of select="."/>
                                </xsl:element>
                     </xsl:for-each>
                        
                        <!-- 5)  DC  created.journal.volume  -->
                        <xsl:if test="*[local-name()='part']/*[local-name()='detail'][@type='volume']">
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">local</xsl:attribute>
                                        <xsl:attribute name="element">journal</xsl:attribute>
                                        <xsl:attribute name="qualifier">volume</xsl:attribute>
                                        <xsl:value-of select="normalize-space(*[local-name()='part']/*[local-name()='detail'][@type='volume'])"/>
                                </xsl:element>
                        </xsl:if>
                        
                         <!-- 6)  DC  created.journal.issue  -->
                        <xsl:if test="*[local-name()='part']/*[local-name()='detail'][@type='issue']">
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">local</xsl:attribute>
                                        <xsl:attribute name="element">journal</xsl:attribute>
                                        <xsl:attribute name="qualifier">issue</xsl:attribute>
                                  	 <xsl:value-of select="normalize-space(*[local-name()='part']/*[local-name()='detail'][@type='issue'])"/>
                                </xsl:element>
                        </xsl:if>  
                        
                        
                        <!-- 7)  mods:/relatedItem/part/extent[@unit="pages"]    ====>   local.document.pagestart/pageend -->
                        <xsl:if test="*[local-name()='part']/*[local-name()='extent'][@unit='pages']">
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">local</xsl:attribute>
                                        <xsl:attribute name="element">document</xsl:attribute>
                                        <xsl:attribute name="qualifier">pagestart</xsl:attribute>
                                        <xsl:value-of select="normalize-space(*[local-name()='part']/*[local-name()='extent']/*[local-name()='start'])"/>
                                </xsl:element>
                                <xsl:element name="dim:field">
                                        <xsl:attribute name="mdschema">local</xsl:attribute>
                                        <xsl:attribute name="element">document</xsl:attribute>
                                        <xsl:attribute name="qualifier">pageend</xsl:attribute>
                                        <xsl:value-of select="normalize-space(*[local-name()='part']/*[local-name()='extent']/*[local-name()='end'])"/>
                                </xsl:element>
                        </xsl:if>                                                                                           
        </xsl:template>
        
        
    <!--   mods:/note[@type='funding'] ====>   (dc.description.sponsorship ORG) -->
    <xsl:template match="*[local-name()='note'][@type='funding']">
        <dim:field mdschema="dc" element="description" qualifier="sponsorship">
            <xsl:value-of select="."/>
        </dim:field>
    </xsl:template>
        
        
    <!--   mods:/genre ====>   dc.type  -->
    <xsl:template match="*[local-name()='genre'][.='journal article']">
        <dim:field mdschema="dc" element="type">
            article
        </dim:field>
    </xsl:template>  
    
    
     <!--   mods:/language/languageTerm ====>   dc.language.iso  -->
    <xsl:template match="*[local-name()='language']/*[local-name()='languageTerm']">
        <dim:field mdschema="dc" element="language" qualifier="iso">
                <xsl:value-of select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </dim:field>
    </xsl:template>    



<!-- **** MODS   identifier/@type=DOI  ====> DC created.identifier.doi  **** -->
        <xsl:template match="*[local-name()='identifier'][@type='doi']"> 
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">local</xsl:attribute>
                        <xsl:attribute name="element">identifier</xsl:attribute>
                        <xsl:attribute name="qualifier">doi</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>    
        
        <!-- **** MODS   identifier/@type=urn  ====> DC created.identifier.urn  **** -->
        <xsl:template match="*[local-name()='identifier'][@type='urn']"> 
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">local</xsl:attribute>
                        <xsl:attribute name="element">identifier</xsl:attribute>
                        <xsl:attribute name="qualifier">urn</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>    
        
             <!-- **** MODS   identifier/@type=urn  ====> DC created.identifier.uri  **** -->
        <xsl:template match="*[local-name()='identifier'][@type='uri']"> 
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">local</xsl:attribute>
                        <xsl:attribute name="element">identifier</xsl:attribute>
                        <xsl:attribute name="qualifier">uri</xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>  
                                                    


<!-- **** MODS   originInfo/publisher  ====> DC  publisher  **** -->
        <xsl:template match="*[local-name()='originInfo']/*[local-name()='publisher']">
                <xsl:element name="dim:field">
                        <xsl:attribute name="mdschema">dc</xsl:attribute>
                        <xsl:attribute name="element">publisher</xsl:attribute>                 
                        <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
        </xsl:template>


	    <!--   mods:/accessCondition[@type="use and reproduction"] ====>   dc.rights  -->
	    <xsl:template match="*[local-name()='accessCondition'][@type='use and reproduction']">
		<xsl:element name="dim:field">
		    <xsl:attribute name="mdschema">dc</xsl:attribute> 
		    <xsl:attribute name="element">rights</xsl:attribute> 
		    <xsl:if test="@description ='uri'"> 
		        <xsl:attribute name="qualifier">uri</xsl:attribute>
		    </xsl:if>
		    <xsl:value-of select="."/>
		</xsl:element>
	    </xsl:template>



</xsl:stylesheet>
