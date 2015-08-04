<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.loc.gov/mods/v3"
        xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"
        xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>

<!-- Create Item Record for each Row, Name Record Filename after Identifier -->
    <xsl:template match="root/row">
    <xsl:variable name="filename" select="identifier[1]"/>
    <xsl:result-document method="xml" href="modsxml/{$filename}.xml" encoding="UTF-8" indent="yes">
        <mods xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd" version="3.5">
            <xsl:call-template name="record"/>
        </mods>
    </xsl:result-document>
    </xsl:template>

<!-- ITEM RECORD -->
    <xsl:template name="record">
    <!-- Item/Record Identifiers -->
        <xsl:apply-templates select="identifier"/>
        <xsl:apply-templates select="identifier_opac"/>
        <xsl:apply-templates select="identifier_isbn"/>
        <xsl:apply-templates select="filename"/>
    <!-- Names -->
        <xsl:apply-templates select="name"/>
    <!-- titleInfo -->
        <titleInfo>
            <xsl:if test="title_initial_article">
                <nonSort><xsl:value-of select="title_initial_article"/></nonSort>
            </xsl:if>
            <title><xsl:value-of select="title"/></title> 
            <xsl:if test="title_of_part">
                <partName><xsl:value-of select="title_of_part"/></partName>
            </xsl:if>
            <xsl:if test="title_part_number">
                <partNumber><xsl:value-of select="title_part_number"/></partNumber>
            </xsl:if>
        </titleInfo>
        <xsl:if test="title_2">
            <titleInfo>
                <xsl:attribute name="type"><xsl:value-of select="title_type_2" /></xsl:attribute>
                <title><xsl:value-of select="title_2"/></title>
                <xsl:if test="title_of_part_2">
                    <partName><xsl:value-of select="title_of_part_2"/></partName>
                </xsl:if>
            </titleInfo>
        </xsl:if>
    <!-- part -->
        <xsl:if test="part_detail_title">
            <part>
                <detail>
                    <title><xsl:value-of select="part_detail_title"/></title>
                </detail>
            </part>
        </xsl:if>
    <!-- Item Type (taken from MODS Type vocabulary) -->
        <xsl:apply-templates select="item_type"/>
    <!-- originInfo -->
        <originInfo>
    <!-- Place of Origin -->
            <!-- See notes in subtemplates for explanation of repeated element -->
            <xsl:apply-templates select="place_of_origin"/>
    <!-- Publisher -->
            <xsl:for-each select="publisher">
                <publisher><xsl:value-of select='.'/></publisher>
            </xsl:for-each>
    <!-- Date -->
            <dateCreated><xsl:value-of select="date_text"/></dateCreated>
            <xsl:choose>
                <xsl:when test="date_range_end">
                    <dateCreated encoding="edtf" keyDate="yes" point="start">
                        <xsl:if test="date_qualifier">
                            <xsl:attribute name="qualifier"><xsl:value-of select="date_qualifier"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="date_single_start"/>
                    </dateCreated>
                    <dateCreated encoding="edtf" keyDate="yes" point="end"><xsl:value-of select="date_range_end"/></dateCreated>
                </xsl:when>
                <xsl:otherwise>
                    <dateCreated encoding="edtf" keyDate="yes">
                        <xsl:if test="date_qualifier">
                            <xsl:attribute name="qualifier"><xsl:value-of select="date_qualifier"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="date_single_start"/>
                    </dateCreated>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="date_publication">
                <dateIssued><xsl:value-of select="date_publication"/></dateIssued>
            </xsl:if>
        </originInfo>
    <!-- physicalDescription -->
        <xsl:if test="extent | form | internet_media_type | digital_origin">
            <physicalDescription>
                <xsl:apply-templates select="extent"/>
                <xsl:apply-templates select="form"/>
                <xsl:apply-templates select="internet_media_type" />
                <xsl:apply-templates select="digital_origin" />
                <xsl:apply-templates select="physicalDescription_note" />
            </physicalDescription>
        </xsl:if>
    <!-- Genre -->
        <xsl:apply-templates select="genre"/>
    <!-- Abstract -->
        <xsl:apply-templates select="abstract"/>
    <!-- Language -->  
        <xsl:apply-templates select="language"/>
    <!-- Notes -->
        <xsl:apply-templates select="public_note"/>
        <xsl:apply-templates select="note_provenance"/>
    <!-- Location -->  
        <location>
            <physicalLocation><xsl:value-of select="repository"/></physicalLocation>
            <xsl:if test="object_context">
                <url access="object in context" usage="primary"><xsl:value-of select="object_in_context"/></url>
            </xsl:if>
            <xsl:if test="file_thumbnail_URL">
                <url access="preview"><xsl:value-of select="file_thumbnail_URL"/></url>
            </xsl:if>
            <xsl:if test="subrepository|shelf_locator">
                <holdingSimple>
                    <copyInformation>
                        <xsl:apply-templates select="subrepository"/>
                        <xsl:apply-templates select="shelf_locator"/>
                    </copyInformation>
                </holdingSimple>
            </xsl:if>
        </location>
    <!-- Subject -->  
        <xsl:apply-templates select="subject_topical"/>
        <xsl:apply-templates select="subject_local"/>
        <xsl:apply-templates select="subject_name"/>  
        <xsl:apply-templates select="subject_geographic"/>
        <xsl:call-template name="StreetAddresses"/>
        <xsl:if test="subject_temporal">
            <subject>
                <temporal><xsl:value-of select="subject_temporal"/></temporal>
            </subject>
        </xsl:if>
    <!-- relatedItems -->
        <relatedItem type="host" displayLabel="Project">
            <titleInfo>
                <xsl:if test="project_title_initial_article">
                    <nonSort><xsl:value-of select="project_title_initial_article"/></nonSort>
                </xsl:if>
                <title>The Dr. William M. Bass III Collection - The Bass Field Notes</title>
            </titleInfo>
            <xsl:if test="project_url">
                <location>
                    <url><xsl:value-of select="project_url"/></url>
                </location>
            </xsl:if>
            <xsl:if test="project_abstract">
                <abstract><xsl:value-of select="project_abstract"/></abstract>
            </xsl:if>
        </relatedItem>
        <!-- THIS IS THE PHYSICAL, ARCHIVAL Collection that holds the physical item digitized. For Digital Collections, use Project (above) -->
        <xsl:for-each select="collection">
            <relatedItem type="host" displayLabel="Collection">
                <titleInfo>
                    <title><xsl:value-of select="."/></title>
                </titleInfo>
                <xsl:if test="../collection_identifier">
                    <identifier type="local"><xsl:value-of select="../collection_identifier"/></identifier>
                </xsl:if>
            </relatedItem>
        </xsl:for-each>
        <!-- This refers to items that may have contained the physical item in some way - such as books for digitized chapters -->
        <xsl:for-each select="relatedItem_title">
            <relatedItem type="host">
                <titleInfo>
                    <title><xsl:value-of select="."/></title>
                </titleInfo>
                <xsl:if test="location_url_physicalItem">
                    <url><xsl:value-of select="location_url_physicalItem" /></url>
                </xsl:if>
            </relatedItem>
        </xsl:for-each>
        <!-- BASS HAS SOME ANNOYING RELATED PARTS / DIGITIZATION PRACTICES IN PLAY -->
        <xsl:if test="relatedItem_constituent_title|relatedItem_constituent_name">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_1|relatedItem_constituent_name_1">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_1">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_1">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_2|relatedItem_constituent_name_2">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_2">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_2">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_3|relatedItem_constituent_name_3">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_3">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_3">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_4|relatedItem_constituent_name_4">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_4">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_4">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_5|relatedItem_constituent_name_5">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_5">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_5">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_6|relatedItem_constituent_name_6">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_6">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_6">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_7|relatedItem_constituent_name_7">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title-7">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_7">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_8|relatedItem_constituent_name_8">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_8">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_8">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_9|relatedItem_constituent_name_9">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_9">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_9">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_10|relatedItem_constituent_name_10">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_10">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_10">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_11|relatedItem_constituent_name_11">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_11">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_11">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_12|relatedItem_constituent_name_12">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_12">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_12">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_13|relatedItem_constituent_name_13">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_13">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_13">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_14|relatedItem_constituent_name_14">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_14">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_14">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_15|relatedItem_constituent_name_15">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_15">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_15">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_16|relatedItem_constituent_name_16">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_16">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_16">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_17|relatedItem_constituent_name_17">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_17">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_17">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_18|relatedItem_constituent_name_18">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_18">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_18">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_19|relatedItem_constituent_name_19">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_19">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_19">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_20|relatedItem_constituent_name_20">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_20">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_20">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_21|relatedItem_constituent_name_21">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_21">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_21">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_22|relatedItem_constituent_name_22">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_22">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_22">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_23|relatedItem_constituent_name_23">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_23">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_23">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_24|relatedItem_constituent_name_24">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_24">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_24">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_25|relatedItem_constituent_name_25">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_25">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_25">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
        <xsl:if test="relatedItem_constituent_title_26|relatedItem_constituent_name_26">
            <relatedItem type="constituent">
                <xsl:for-each select="relatedItem_constituent_title_26">
                    <titleInfo>
                        <title><xsl:value-of select="."/></title>
                    </titleInfo>
                </xsl:for-each>
                <xsl:for-each select="relatedItem_constituent_name_26">
                    <name>
                        <xsl:if test="contains(., ' \|\| ')">
                            <xsl:for-each select="tokenize(., ' \|\| ')">
                                <xsl:if test="contains(., 'authorities/names')">
                                    <xsl:attribute name="authority">naf</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., 'authorities/subjects')">
                                    <xsl:attribute name="authority">lcsh</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="contains(., '| URI: ')">
                                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                                </xsl:if>
                                <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                                <xsl:if test="contains(., '| Role: ')">
                                    <role>
                                        <roleTerm type="text" authority="marcrelator">
                                            <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                            <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                        </roleTerm>
                                    </role>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="not(contains(., ' \|\| '))">
                            <xsl:if test="contains(., 'authorities/names')">
                                <xsl:attribute name="authority">naf</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., 'authorities/subjects')">
                                <xsl:attribute name="authority">lcsh</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="contains(., '| URI: ')">
                                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
                            </xsl:if>
                            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                            <xsl:if test="contains(., '| Role: ')">
                                <role>
                                    <roleTerm type="text" authority="marcrelator">
                                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                                    </roleTerm>
                                </role>
                            </xsl:if>
                        </xsl:if>
                    </name>
                </xsl:for-each>
            </relatedItem>
        </xsl:if>
  
        <!-- Part of a Series/Journal/Periodical for which we have information -->
        <xsl:for-each select="series_title">
            <relatedItem type="series">
                <titleInfo>
                    <title><xsl:value-of select="."/></title>
                </titleInfo>
                <xsl:if test="../series_volume|../series_issue">
                    <part>
                        <xsl:if test="../series_volume">
                            <detail type="volume">
                                <number><xsl:value-of select="../series_volume"/></number>
                            </detail>
                        </xsl:if>
                        <xsl:if test="../series_issue">
                            <detail type="issue">
                                <number><xsl:value-of select="../series_issue"/></number>
                            </detail>
                        </xsl:if>
                    </part>
                </xsl:if>
                <xsl:if test="../identifier_series_opac">
                    <location>
                        <url><xsl:value-of select="../identifier_series_opac"/></url>
                    </location>
                </xsl:if>
            </relatedItem>
        </xsl:for-each>
    <!-- accessCondition -->
        <accessCondition type="use and reproduction">
            <xsl:value-of select="rights"/>
        </accessCondition>
    <!-- recordInfo --> 
        <recordInfo>
            <recordIdentifier><xsl:value-of select="concat('record_', identifier[1])"/></recordIdentifier>
            <recordContentSource><xsl:value-of select="record_source"/></recordContentSource>
            <languageOfCataloging>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
            </languageOfCataloging>
            <recordOrigin>Created and edited in general conformance to MODS Guidelines (Version 3.5).</recordOrigin>
        </recordInfo>
    </xsl:template>    
<!-- End Item Record Template -->
    
<!-- SUBTEMPLATES -->
    <xsl:template match="identifier">
        <identifier type="local"><xsl:value-of select="." /></identifier>
    </xsl:template>
    <xsl:template match="identifier_opac">
        <identifier type="opac"><xsl:value-of select="."/></identifier>
    </xsl:template>
    <xsl:template match="identifier_isbn">
        <identifier type="isbn"><xsl:value-of select="."/></identifier>
    </xsl:template>
    <xsl:template match="filename">
        <identifier type="filename"><xsl:value-of select="."/></identifier>
    </xsl:template>
    <!-- Name data structure: Name [Value only] | URI:  | Role:  | Role URI:  | Type:  -->
    <xsl:template match="name">
        <name>
            <xsl:if test="contains(., 'Type: ')">
                <xsl:attribute name="type"><xsl:value-of select="substring-after(., 'Type: ')"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="contains(., 'authorities/names')">
                <xsl:attribute name="authority">naf</xsl:attribute>
            </xsl:if>
            <xsl:if test="contains(., 'authorities/subjects')">
                <xsl:attribute name="authority">lcsh</xsl:attribute>
            </xsl:if>
            <xsl:if test="contains(., '| URI: ')">
                <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., '| URI: '))+8, (string-length(substring-before(., '| Role:')))-(string-length(substring-before(., '| URI: '))+8))"/></xsl:attribute>
            </xsl:if>
            <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
            <xsl:if test="contains(., '| Role: ')">
                <role>
                    <roleTerm type="text" authority="marcrelator">
                        <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., 'Role URI:'))+11, (string-length(substring-before(., 'Role URI:'))+12))"/></xsl:attribute>
                        <xsl:value-of select="substring(., string-length(substring-before(., 'Role: '))+7, string-length(substring-before(., '| Role URI:'))-(string-length(substring-before(., 'Role: '))+7))"/>                        
                    </roleTerm>
                </role>
            </xsl:if>
        </name>
    </xsl:template>
    <xsl:template match="place_of_origin">
        <place supplied="yes">
            <placeTerm type="text">
                <!-- No authority attribute - currently not available in MODS 3.5 for anything other than country codes - CMH, 3/2015 -->
                <!-- Place of Origin repeated used to record locations without URIs but the next biggest immediate geographical area does contain a URI and is recorded in first Place of Origin -CMH 3/2015 --> 
                <xsl:if test="contains(., '| URI: ')">
                    <xsl:attribute name="valueURI"><xsl:value-of select="substring(., string-length(substring-before(., ' | URI: '))+9, string-length(substring-before(., ' | Coordinates: '))-(string-length(substring-before(., ' | URI: '))+8))"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="substring-before(., ' | ')"/>
            </placeTerm>
        </place>
    </xsl:template>
    <xsl:template match="item_type">
        <typeOfResource><xsl:value-of select="."/></typeOfResource>
    </xsl:template>
    <xsl:template match="form">
        <form authority="aat">
            <xsl:attribute name="valueURI"><xsl:value-of select="substring-after(., '| ')"/></xsl:attribute>
            <xsl:value-of select="substring-before(., ' | ')"/>
        </form>
    </xsl:template>
    <xsl:template match="genre">
        <genre>
            <xsl:if test="contains(., 'authorities/subjects')">
                <xsl:attribute name="authority">lcsh</xsl:attribute>
            </xsl:if>
            <xsl:if test="contains(., 'genreForms')">
                <xsl:attribute name="authority">lcgft</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="valueURI">
                <xsl:value-of select="substring-after(., '| ')"/>
            </xsl:attribute>
            <xsl:value-of select="substring-before(., ' | ')"/>
        </genre>
    </xsl:template>
    <xsl:template match="internet_media_type">
        <internetMediaType><xsl:value-of select="."/></internetMediaType>
    </xsl:template>
    <xsl:template match="digital_origin">
        <digitalOrigin><xsl:value-of select="."/></digitalOrigin>
    </xsl:template>
    <xsl:template match="extent">
        <extent><xsl:value-of select="."/></extent>
    </xsl:template>
    <xsl:template match="abstract">
        <abstract><xsl:value-of select="."/></abstract>
    </xsl:template>
    <xsl:template match="language">
        <language>
            <languageTerm type="code" authority="iso639-2b"><xsl:value-of select="."/></languageTerm>
        </language>
    </xsl:template>
    <xsl:template match="physicalDescription_note">
        <note><xsl:value-of select="."/></note>
    </xsl:template>
    <xsl:template match="public_note">
        <note><xsl:value-of select="."/></note>
    </xsl:template>
    <xsl:template match="note_provenance">
        <note type="ownership"><xsl:value-of select="."/></note>
    </xsl:template>
    <xsl:template match="subrepository">
        <subLocation><xsl:value-of select="."/></subLocation>
    </xsl:template>
    <xsl:template match="shelf_locator">
        <shelfLocator><xsl:value-of select='.'/></shelfLocator>
    </xsl:template>
    <xsl:template match="subject_topical">
        <xsl:choose>
            <xsl:when test="contains(., ' | ')">
                <subject>
                    <xsl:if test="contains(., 'authorities/names')">
                        <xsl:attribute name="authority">naf</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="contains(., 'authorities/subjects') or contains(., 'lcsh')">
                        <xsl:attribute name="authority">lcsh</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="contains(., 'agrovoc')">
                        <xsl:attribute name="authority">agrovoc</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="contains(., '/fast/')">
                        <xsl:attribute name="authority">fast</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="contains(., 'DOTS')">
                        <xsl:attribute name="authority">dots</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="contains(., '| http://')">
                        <xsl:attribute name="valueURI"><xsl:value-of select="substring-after(., '| ')"/></xsl:attribute>
                    </xsl:if>
                    <topic><xsl:value-of select="substring-before(., ' | ')"/></topic>
                </subject>
            </xsl:when>
            <xsl:otherwise>
                <subject>
                    <topic><xsl:value-of select="."/></topic>
                </subject>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="subject_local">
        <subject authority="local">
            <topic><xsl:value-of select="."/></topic>
        </subject>
    </xsl:template>
    <xsl:template match="subject_name">
        <xsl:choose>
            <xsl:when test="contains(., ' | ')">
                <subject>
                    <name>
                        <xsl:if test="contains(., 'authorities/names')">
                            <xsl:attribute name="authority">naf</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="contains(., 'authorities/subjects')">
                            <xsl:attribute name="authority">lcsh</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="contains(., 'DOTS')">
                            <xsl:attribute name="authority">dots</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="contains(., '| http://')">
                            <xsl:attribute name="valueURI"><xsl:value-of select="substring-after(., '| ')"/></xsl:attribute>
                        </xsl:if>
                        <namePart><xsl:value-of select="substring-before(., ' | ')"/></namePart>
                    </name>
                </subject>
            </xsl:when>
            <xsl:otherwise>
                <subject>
                    <name>
                        <namePart><xsl:value-of select="."/></namePart>
                    </name>
                </subject>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="subject_geographic">
        <xsl:choose>
            <xsl:when test="contains(., ' | ')">
                <subject>
                    <geographic>
                        <xsl:if test="contains(., 'authorities/names')">
                            <xsl:attribute name="authority">naf</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="contains(., 'authorities/subjects')">
                            <xsl:attribute name="authority">lcsh</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="contains(., 'DOTS')">
                            <xsl:attribute name="authority">dots</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="contains(., '| URI: ')">
                            <xsl:attribute name="valueURI">
                                <xsl:value-of select="substring(., string-length(substring-before(., ' | URI: '))+9, string-length(substring-before(., ' | Coordinates: '))-(string-length(substring-before(., ' | URI: '))+8))"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="substring-before(., ' | ')"/>
                    </geographic>
                    <xsl:if test="contains(., '| Coordinates: ')">
                        <cartographics>
                            <coordinates><xsl:value-of select="substring-after(., ' | Coordinates: ')"/></coordinates>
                        </cartographics>
                    </xsl:if>
                </subject>  
            </xsl:when>
            <xsl:otherwise>
                <subject>
                    <geographic><xsl:value-of select="."/></geographic>
                </subject>  
            </xsl:otherwise> 
        </xsl:choose>
    </xsl:template>
    <xsl:template name="StreetAddresses">
        <xsl:if test="subject_geographic_hierarchical_street">
            <subject>
                <hierarchicalGeographic>
                    <xsl:apply-templates select="subject_geographic_hierarchical_country"/>
                    <xsl:apply-templates select="subject_geographic_hierarchical_province"/>
                    <xsl:apply-templates select="subject_geographic_hierarchical_state"/>
                    <xsl:apply-templates select="subject_geographic_hierarchical_city"/>
                    <xsl:apply-templates select="subject_geographic_hierarchical_borough"/>
                    <xsl:apply-templates select="subject_geographic_hierarchical_street"/>
                </hierarchicalGeographic>
            </subject>
        </xsl:if>
    </xsl:template>
    <xsl:template match="subject_geographic_hierarchical_country">
        <country><xsl:value-of select="."/></country>
    </xsl:template>
    <xsl:template match="subject_geographic_hierarchical_province">
        <province><xsl:value-of select="."/></province>
    </xsl:template>
    <xsl:template match="subject_geographic_hierarchical_state">
        <state><xsl:value-of select="."/></state>
    </xsl:template>
    <xsl:template match="subject_geographic_hierarchical_city">
        <city><xsl:value-of select="."/></city>
    </xsl:template>
    <xsl:template match="subject_geographic_hierarchical_borough">
        <city><xsl:value-of select='concat("Borough: ", .)'/></city>
    </xsl:template>
    <xsl:template match="subject_geographic_hierarchical_street">
        <citySection><xsl:value-of select='concat("Street: ", .)'/></citySection>
    </xsl:template>
</xsl:stylesheet>