<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:saxon="http://saxon.sf.net/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:hix-core="http://hix.cms.gov/0.1/hix-core" xmlns:hix-ee="http://hix.cms.gov/0.1/hix-ee" xmlns:hix-pm="http://hix.cms.gov/0.1/hix-pm" xmlns:i="http://niem.gov/niem/appinfo/2.0" xmlns:nc="http://niem.gov/niem/niem-core/2.0" xmlns:s="http://niem.gov/niem/structures/2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exch="http://at.dsh.cms.gov/exchange/1.0" xmlns:ext="http://at.dsh.cms.gov/extension/1.0" xmlns:scr="http://niem.gov/niem/domains/screening/2.1" version="2.0">
    <!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
    
    <xsl:param name="archiveDirParameter"/>
    <xsl:param name="archiveNameParameter"/>
    <xsl:param name="fileNameParameter"/>
    <xsl:param name="fileDirParameter"/>
    <xsl:variable name="document-uri">
        <xsl:value-of select="document-uri(/)"/>
    </xsl:variable>
    
    <!--PHASES-->
    
    <!--PROLOG-->
    
    <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>
    
    <!--XSD TYPES FOR XSLT2-->
    
    <!--KEYS AND FUNCTIONS-->
    
    <!--DEFAULT RULES-->
    
    <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
    
    <!--This mode can be used to generate an ugly though full XPath for locators-->
    
    <xsl:template match="*" mode="schematron-select-full-path">
        <xsl:apply-templates select="." mode="schematron-get-full-path"/>
    </xsl:template>
    
    <!--MODE: SCHEMATRON-FULL-PATH-->
    
    <!--This mode can be used to generate an ugly though full XPath for locators-->
    
    <xsl:template match="*" mode="schematron-get-full-path">
        <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()=''">
                <xsl:value-of select="name()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>*:</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>[namespace-uri()='</xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text>']</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="1+ $preceding"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="@*" mode="schematron-get-full-path">
        <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()=''">
                @
                <xsl:value-of select="name()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>@*[local-name()='</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>' and namespace-uri()='</xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text>']</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--MODE: SCHEMATRON-FULL-PATH-2-->
    
    <!--This mode can be used to generate prefixed XPath for humans-->
    
    <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
        <xsl:for-each select="ancestor-or-self::*">
            <xsl:text>/</xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:if test="not(self::*)">
            <xsl:text/>
            /@
            <xsl:value-of select="name(.)"/>
        </xsl:if>
    </xsl:template>
    <!--MODE: SCHEMATRON-FULL-PATH-3-->
    
    <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
    
    <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
        <xsl:for-each select="ancestor-or-self::*">
            <xsl:text>/</xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:if test="parent::*">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:if test="not(self::*)">
            <xsl:text/>
            /@
            <xsl:value-of select="name(.)"/>
        </xsl:if>
    </xsl:template>
    
    <!--MODE: GENERATE-ID-FROM-PATH -->
    
    <xsl:template match="/" mode="generate-id-from-path"/>
    <xsl:template match="text()" mode="generate-id-from-path">
        <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
    </xsl:template>
    <xsl:template match="comment()" mode="generate-id-from-path">
        <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
    </xsl:template>
    <xsl:template match="processing-instruction()" mode="generate-id-from-path">
        <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
    </xsl:template>
    <xsl:template match="@*" mode="generate-id-from-path">
        <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <xsl:value-of select="concat('.@', name())"/>
    </xsl:template>
    <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
        <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
    </xsl:template>
    
    <!--MODE: GENERATE-ID-2 -->
    
    <xsl:template match="/" mode="generate-id-2">U</xsl:template>
    <xsl:template match="*" mode="generate-id-2" priority="2">
        <xsl:text>U</xsl:text>
        <xsl:number level="multiple" count="*"/>
    </xsl:template>
    <xsl:template match="node()" mode="generate-id-2">
        <xsl:text>U.</xsl:text>
        <xsl:number level="multiple" count="*"/>
        <xsl:text>n</xsl:text>
        <xsl:number count="node()"/>
    </xsl:template>
    <xsl:template match="@*" mode="generate-id-2">
        <xsl:text>U.</xsl:text>
        <xsl:number level="multiple" count="*"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="string-length(local-name(.))"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="translate(name(),':','.')"/>
    </xsl:template>
    <!--Strip characters-->
    <xsl:template match="text()" priority="-1"/>
    
    <!--SCHEMA SETUP-->
    
    <xsl:template match="/">
        <svrl:schematron-output title="Account Transfer Constraints" schemaVersion="" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
            <xsl:comment>
                <xsl:value-of select="$archiveDirParameter"/>
                   
		 
                <xsl:value-of select="$archiveNameParameter"/>
                  
		 
                <xsl:value-of select="$fileNameParameter"/>
                  
		 
                <xsl:value-of select="$fileDirParameter"/>
            </xsl:comment>
            <svrl:ns-prefix-in-attribute-values uri="http://hix.cms.gov/0.1/hix-core" prefix="hix-core"/>
            <svrl:ns-prefix-in-attribute-values uri="http://hix.cms.gov/0.1/hix-ee" prefix="hix-ee"/>
            <svrl:ns-prefix-in-attribute-values uri="http://hix.cms.gov/0.1/hix-pm" prefix="hix-pm"/>
            <svrl:ns-prefix-in-attribute-values uri="http://niem.gov/niem/appinfo/2.0" prefix="i"/>
            <svrl:ns-prefix-in-attribute-values uri="http://niem.gov/niem/niem-core/2.0" prefix="nc"/>
            <svrl:ns-prefix-in-attribute-values uri="http://niem.gov/niem/structures/2.0" prefix="s"/>
            <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
            <svrl:ns-prefix-in-attribute-values uri="http://at.dsh.cms.gov/exchange/1.0" prefix="exch"/>
            <svrl:ns-prefix-in-attribute-values uri="http://at.dsh.cms.gov/extension/1.0" prefix="ext"/>
            <svrl:ns-prefix-in-attribute-values uri="http://niem.gov/niem/domains/screening/2.1" prefix="scr"/>
            <svrl:active-pattern>
                <xsl:attribute name="document">
                    <value-of select="document-uri(/)"/>
                </xsl:attribute>
                <xsl:attribute name="id">all-rules</xsl:attribute>
                <xsl:attribute name="name">all-rules</xsl:attribute>
                <xsl:apply-templates/>
            </svrl:active-pattern>
            <xsl:apply-templates select="/" mode="M21"/>
            <svrl:active-pattern>
                <xsl:attribute name="document">
                    <value-of select="document-uri(/)"/>
                </xsl:attribute>
                <xsl:attribute name="id">Generic</xsl:attribute>
                <xsl:attribute name="name">Generic</xsl:attribute>
                <xsl:apply-templates/>
            </svrl:active-pattern>
            <xsl:apply-templates select="/" mode="M22"/>
        </svrl:schematron-output>
    </xsl:template>
    
    <!--SCHEMATRON PATTERNS-->
    
    <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Account Transfer Constraints</svrl:text>
    <xsl:param name="allLetters" select="&quot;^(\p{L}|\s|'|\-|\.)+$&quot;"/>
    <xsl:param name="threedigits" select="&quot;^(\d){3}$&quot;"/>
    <xsl:param name="threechars" select="&quot;^([A-Z]){3}$&quot;"/>
    <xsl:param name="ApplicantPersonID" select="/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-core:RoleOfPersonReference/@s:ref"/>
    <xsl:param name="ContactPersonID" select="/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:SSFPrimaryContact/hix-core:RoleOfPersonReference/@s:ref"/>
    <xsl:param name="RepresentativePerson" select="/exch:AccountTransferRequest/hix-ee:AuthorizedRepresentative/hix-core:RolePlayedByPerson"/>
    <xsl:param name="HouseholdPersonIDs" select="/exch:AccountTransferRequest/ext:PhysicalHousehold/hix-ee:HouseholdMemberReference/@s:ref"/>
    <xsl:param name="is-inbound" select="/exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:RecipientTransferActivityCode='Exchange'"/>
    <xsl:param name="is-inbound-not-OBR" select="(/exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:RecipientTransferActivityCode='Exchange') and (not(substring(/exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/nc:ActivityIdentification/nc:IdentificationID,1,3)='FFM'))"/>
    <xsl:param name="ExchangeEligibilityIDs" select="//hix-ee:ExchangeEligibility/@s:id"/>
    
    <!--PATTERN all-rules-->
    	
    <!--RULE -->
    
    <xsl:template match="*[@xsi:nil = true()]" priority="1121" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@xsi:nil = true()]"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$is-inbound"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-inbound">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                    The xsi:nil attribute (on 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        ) is not allowed for outbound transactions.
         
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="exch:AccountTransferRequest" priority="1120" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="exch:AccountTransferRequest"/>
        <xsl:variable name="quantity" select="ext:TransferHeader/ext:TransferActivity/ext:TransferActivityReferralQuantity"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="($quantity &gt; 0)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($quantity &gt; 0)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            The value of ext:TransferActivityReferralQuantity must be greater than 0.
            [exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:TransferActivityReferralQuantity].  
         </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$quantity = count(hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:ReferralActivity)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$quantity = count(hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:ReferralActivity)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            The value of ext:TransferActivityReferralQuantity must equal the number of hix-ee:ReferralActivity elements in the payload.
            [exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:TransferActivityReferralQuantity].  
         </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplication" priority="1119" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplication"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-ee:SSFSigner/hix-ee:Signature/hix-core:SignatureDate"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-ee:SSFSigner/hix-ee:Signature/hix-core:SignatureDate">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:SignatureDate is required
                [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:SSFSigner/hix-ee:Signature/hix-core:SignatureDate].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:ApplicationSubmission[@xsi:nil=true() or nc:ActivityDate]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:ApplicationSubmission[@xsi:nil=true() or nc:ActivityDate]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:ApplicationSubmission is required (and it must be nilled or contain an nc:ActivityDate) [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-core:ApplicationSubmission/nc:ActivityDate].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:ApplicationCreation[@xsi:nil=true() or nc:ActivityDate]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:ApplicationCreation[@xsi:nil=true() or nc:ActivityDate]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:ApplicationCreation is required (and it must be nilled or contain an nc:ActivityDate)                [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-core:ApplicationCreation/nc:ActivityDate].  
         </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-ee:SSFSigner/hix-ee:SSFAttestation"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-ee:SSFSigner/hix-ee:SSFAttestation">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:SSFAttestation is required in hix-ee:SSFSigner [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:SSFSigner/hix-ee:SSFAttestation].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:InsuranceApplicationTaxReturnAccessIndicator[not(@xsi:nil=true())] = true()) or hix-ee:InsuranceApplicationCoverageRenewalYearQuantity"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:InsuranceApplicationTaxReturnAccessIndicator[not(@xsi:nil=true())] = true()) or hix-ee:InsuranceApplicationCoverageRenewalYearQuantity">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:InsuranceApplicationCoverageRenewalYearQuantity is required in hix-ee:InsuranceApplication if hix-ee:InsuranceApplicationTaxReturnAccessIndicator is true [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicationCoverageRenewalYearQuantity].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(count(hix-core:ApplicationIdentification) = 2) or (hix-core:ApplicationIdentification[1]/nc:IdentificationCategoryText != hix-core:ApplicationIdentification[2]/nc:IdentificationCategoryText)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(count(hix-core:ApplicationIdentification) = 2) or (hix-core:ApplicationIdentification[1]/nc:IdentificationCategoryText != hix-core:ApplicationIdentification[2]/nc:IdentificationCategoryText)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            When two hix-core:ApplicationIdentification elements are present, they must both have values for nc:IdentificationCategoryText and they must be different (to distinguish Application ID from State Application ID) [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-core:ApplicationIdentification].  
         </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="ext:TransferActivity" priority="1118" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ext:TransferActivity"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:ActivityIdentification/nc:IdentificationID"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:ActivityIdentification/nc:IdentificationID">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:ActivityIdentification/nc:IdentificationID is required
                [exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/nc:ActivityIdentification/nc:IdentificationID].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:ActivityDate/nc:DateTime"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:ActivityDate/nc:DateTime">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:ActivityDate/nc:DateTime is required
                [exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/nc:ActivityDate/nc:DateTime].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="ext:RecipientTransferActivityCode = 'Exchange' or ext:RecipientTransferActivityStateCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ext:RecipientTransferActivityCode = 'Exchange' or ext:RecipientTransferActivityStateCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                ext:RecipientTransferActivityStateCode is required if ext:RecipientTransferActivityCode is not "Exchange" [exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:RecipientTransferActivityStateCode].  
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:ReferralActivity" priority="1117" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:ReferralActivity"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:ActivityIdentification"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:ActivityIdentification">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:ActivityIdentification is required in hix-ee:ReferralActivity [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:ReferralActivity/nc:ActivityIdentification].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:ActivityDate/nc:DateTime"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:ActivityDate/nc:DateTime">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:ActivityDate/nc:DateTime is required in hix-ee:ReferralActivity [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:ReferralActivity/nc:ActivityDate/nc:DateTime].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode is required in hix-ee:ReferralActivity [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:ReferralActivity/hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-inbound) or not(hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode = 'Initiated') or hix-ee:ReferralActivityEligibilityReasonReference"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-inbound) or not(hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode = 'Initiated') or hix-ee:ReferralActivityEligibilityReasonReference">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-ee:ReferralActivityEligibilityReasonReference is required in hix-ee:ReferralActivity if the hix-ee:ReferralActivityStatusCode is "Initiated" and the transfer is sent from the state to the FFE. [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:ReferralActivity/hix-ee:ReferralActivityEligibilityReasonReference].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-inbound) or not(hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode = 'Initiated') or not(hix-ee:ReferralActivityEligibilityReasonReference[not(@s:ref = $ExchangeEligibilityIDs)])"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-inbound) or not(hix-ee:ReferralActivityStatus/hix-ee:ReferralActivityStatusCode = 'Initiated') or not(hix-ee:ReferralActivityEligibilityReasonReference[not(@s:ref = $ExchangeEligibilityIDs)])">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>Every hix-ee:ReferralActivityEligibilityReasonReference must refer to an ExchangeEligibility element if the hix-ee:ReferralActivityStatusCode is "Initiated" and the transfer is sent from the state to the FFE.
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:Sender" priority="1116" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:Sender"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:InformationExchangeSystemCategoryCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:InformationExchangeSystemCategoryCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:InformationExchangeSystemCategoryCode is required in hix-core:Sender [exch:AccountTransferRequest/hix-core:Sender/hix-core:InformationExchangeSystemCategoryCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-core:InformationExchangeSystemStateCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-core:InformationExchangeSystemStateCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:InformationExchangeSystemStateCode is required in hix-core:Sender if hix-core:InformationExchangeSystemCategoryCode is not "Exchange". [exch:AccountTransferRequest/hix-core:Sender/hix-core:InformationExchangeSystemStateCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-inbound) or hix-core:InformationExchangeSystemStateCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-inbound) or hix-core:InformationExchangeSystemStateCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:InformationExchangeSystemStateCode is required in hix-core:Sender if ext:RecipientTransferActivityCode is "Exchange". [exch:AccountTransferRequest/hix-core:Sender/hix-core:InformationExchangeSystemStateCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:Receiver" priority="1115" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:Receiver"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:InformationExchangeSystemCategoryCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:InformationExchangeSystemCategoryCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:InformationExchangeSystemCategoryCode is required in hix-core:Receiver [exch:AccountTransferRequest/hix-core:Receiver/hix-core:InformationExchangeSystemCategoryCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-core:InformationExchangeSystemStateCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-core:InformationExchangeSystemStateCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:InformationExchangeSystemStateCode is required in hix-core:Receiver if hix-core:InformationExchangeSystemCategoryCode is not "Exchange" [exch:AccountTransferRequest/hix-core:Receiver/hix-core:InformationExchangeSystemStateCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:SSFSignerAuthorizedRepresentativeAssociation" priority="1114" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:SSFSignerAuthorizedRepresentativeAssociation"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-ee:Signature/hix-core:SignatureDate"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-ee:Signature/hix-core:SignatureDate">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:SignatureDate is required for the authorized representative [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:SSFSigner/hix-ee:SSFSignerAuthorizedRepresentativeAssociation/hix-ee:Signature/hix-core:SignatureDate].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:AuthorizedRepresentative" priority="1113" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:AuthorizedRepresentative"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:RolePlayedByPerson/nc:PersonName/nc:PersonSurName"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:RolePlayedByPerson/nc:PersonName/nc:PersonSurName">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:PersonSurName is required for the authorized representative [exch:AccountTransferRequest/hix-ee:AuthorizedRepresentative/hix-core:RolePlayedByPerson/nc:PersonName/nc:PersonSurName].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplicationAssisterAssociation" priority="1112" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplicationAssisterAssociation"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:AssociationBeginDate"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:AssociationBeginDate">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:AssociationBeginDate is required in hix-ee:InsuranceApplicationAssisterAssociation [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicationAssisterAssociation/nc:AssociationBeginDate].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:Assister" priority="1111" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:Assister"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:RolePlayedByPerson/nc:PersonName/nc:PersonSurName"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:RolePlayedByPerson/nc:PersonName/nc:PersonSurName">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:PersonSurName is required for the assister [exch:AccountTransferRequest/hix-ee:Assister/hix-core:RolePlayedByPerson/nc:PersonName/nc:PersonSurName].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:SSFAttestation" priority="1110" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:SSFAttestation"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(//hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:MedicaidMAGIEligibility/hix-ee:EligibilityIndicator = true()) or hix-ee:SSFAttestationMedicaidObligationsIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(//hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:MedicaidMAGIEligibility/hix-ee:EligibilityIndicator = true()) or hix-ee:SSFAttestationMedicaidObligationsIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:SSFAttestationMedicaidObligationsIndicator is required if MedicaidMAGIEligibility/hix-ee:EligibilityIndicator is true [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:SSFSigner/hix-ee:SSFAttestation/hix-ee:SSFAttestationMedicaidObligationsIndicator].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(//hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantAbsentParentOrSpouseCode = 'Yes') or not(//hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:MedicaidMAGIEligibility/hix-ee:EligibilityIndicator = true()) or hix-ee:SSFAttestationCollectionsAgreementIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(//hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantAbsentParentOrSpouseCode = 'Yes') or not(//hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:MedicaidMAGIEligibility/hix-ee:EligibilityIndicator = true()) or hix-ee:SSFAttestationCollectionsAgreementIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:SSFAttestationCollectionsAgreementIndicator is required in hix-ee:SSFAttestation if InsuranceApplicantAbsentParentOrSpouseCode equals 'Yes' and MedicaidMAGIEligibility/hix-ee:EligibilityIndicator is true [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:SSFSigner/hix-ee:SSFAttestation/hix-ee:SSFAttestationCollectionsAgreementIndicator].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplicant" priority="1109" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplicant"/>
        <xsl:variable name="ThisApplicantPersonID" select="hix-core:RoleOfPersonReference/@s:ref"/>
        <xsl:variable name="ThisApplicantPerson" select="/exch:AccountTransferRequest/hix-core:Person[@s:id = $ThisApplicantPersonID]"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-ee:InsuranceApplicantFixedAddressIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-ee:InsuranceApplicantFixedAddressIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:InsuranceApplicantFixedAddressIndicator is required in hix-ee:InsuranceApplicant [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($ThisApplicantPerson/nc:PersonUSCitizenIndicator[not(@xsi:nil=true())] = false()) or hix-ee:InsuranceApplicantLawfulPresenceStatus/hix-ee:LawfulPresenceStatusEligibility[@xsi:nil=true() or hix-ee:EligibilityIndicator]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($ThisApplicantPerson/nc:PersonUSCitizenIndicator[not(@xsi:nil=true())] = false()) or hix-ee:InsuranceApplicantLawfulPresenceStatus/hix-ee:LawfulPresenceStatusEligibility[@xsi:nil=true() or hix-ee:EligibilityIndicator]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-ee:LawfulPresenceStatusEligibility is required (and it must be nilled or contain hix-ee:EligibilityIndicator) if nc:PersonUSCitizenIndicator = false [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantLawfulPresenceStatus/hix-ee:LawfulPresenceStatusEligibility].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:CHIPEligibility/hix-ee:EligibilityIndicator = false() and hix-ee:MedicaidMAGIEligibility/hix-ee:EligibilityIndicator = false()) or hix-ee:InsuranceApplicantNonESICoverageIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:CHIPEligibility/hix-ee:EligibilityIndicator = false() and hix-ee:MedicaidMAGIEligibility/hix-ee:EligibilityIndicator = false()) or hix-ee:InsuranceApplicantNonESICoverageIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:InsuranceApplicantNonESICoverageIndicator is required if Applicant CHIP Eligible Status Indicator = N and Applicant Medicaid Eligible Status Indicator = N            [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantNonESICoverageIndicator]
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:Person" priority="1108" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:Person"/>
        <xsl:variable name="is-contact" select="@s:id=$ContactPersonID"/>
        <xsl:variable name="is-applicant" select="@s:id=$ApplicantPersonID"/>
        <xsl:variable name="is-household" select="@s:id=$HouseholdPersonIDs"/>
        <xsl:variable name="id" select="@s:id"/>
        <xsl:variable name="ThisInsuranceApplicant" select="/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant[hix-core:RoleOfPersonReference/@s:ref = $id]"/>
        <xsl:variable name="ThisPrimaryContact" select="/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:SSFPrimaryContact[hix-core:RoleOfPersonReference/@s:ref = $id]"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="(not($is-household) and not($is-contact) and not($is-applicant)) or nc:PersonName/nc:PersonGivenName[not(@xsi:nil=true())]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(not($is-household) and not($is-contact) and not($is-applicant)) or nc:PersonName/nc:PersonGivenName[not(@xsi:nil=true())]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:PersonGivenName is required for the applicant and primary contact person [exch:AccountTransferRequest/hix-core:Person/nc:PersonName/nc:PersonGivenName].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="(not($is-household) and not($is-contact) and not($is-applicant)) or nc:PersonName/nc:PersonSurName[not(@xsi:nil=true())]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(not($is-household) and not($is-contact) and not($is-applicant)) or nc:PersonName/nc:PersonSurName[not(@xsi:nil=true())]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:PersonSurName is required (and non-nillable) for the applicant [exch:AccountTransferRequest/hix-core:Person/nc:PersonName/nc:PersonSurName].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($ThisPrimaryContact/hix-ee:SSFPrimaryContactPreferenceCode='Email') or hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactEmailID"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($ThisPrimaryContact/hix-ee:SSFPrimaryContactPreferenceCode='Email') or hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactEmailID">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:ContactEmailID is required if the person is a primary contact whose contact preference is Email. [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactEmailID].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="(not($is-household) and not($is-applicant)) or nc:PersonBirthDate"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(not($is-household) and not($is-applicant)) or nc:PersonBirthDate">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:PersonBirthDate is required for the applicant [exch:AccountTransferRequest/hix-core:Person/nc:PersonBirthDate].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or nc:PersonSexText"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or nc:PersonSexText">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:PersonSexText is required for the applicant [exch:AccountTransferRequest/hix-core:Person/nc:PersonSexText].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="contact-info" select="hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformationCategoryCode = ('Home','Mailing')]/hix-core:ContactInformation"/>
        <xsl:variable name="PersonAddress" select="$contact-info/nc:ContactMailingAddress/nc:StructuredAddress"/>
        <xsl:variable name="PersonHomeAddress" select="hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformationCategoryCode='Home']/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress"/>
        <xsl:variable name="PersonOtherAddressTypes" select="hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[exists(hix-core:ContactInformation/nc:ContactMailingAddress)]/hix-core:ContactInformationCategoryCode"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                A home address is required for the applicant if hix-ee:InsuranceApplicantFixedAddressIndicator is true [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformationCategoryCode='Home']/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or count($PersonAddress)&gt; 0"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or count($PersonAddress)&gt; 0">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                An address (either home or mailing) is required for the applicant [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonAddress)&gt; 0"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonAddress)&gt; 0">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            An address (either home or mailing) is required for the Primary Contact [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonHomeAddress) &lt; 2"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonHomeAddress) &lt; 2">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            No more than one home address is allowed for the Primary Contact [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformationCategoryCode='Home']/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonOtherAddressTypes[.='Mailing']) &lt; 2"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonOtherAddressTypes[.='Mailing']) &lt; 2">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            No more than one Mailing address is allowed for the Primary Contact [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformationCategoryCode='Mailing']/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress].  
         </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonOtherAddressTypes[.='Residency']) &lt; 2"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonOtherAddressTypes[.='Residency']) &lt; 2">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            No more than one Residency address is allowed for the Primary Contact [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformationCategoryCode='Residency']/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress].  
         </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationStreet[@xsi:nil=true() or nc:StreetFullText]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationStreet[@xsi:nil=true() or nc:StreetFullText]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationStreet is required for the applicant (and it must be nilled or contain nc:StreetFullText) if hix-ee:InsuranceApplicantFixedAddressIndicator is true [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationStreet].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationCityName"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationCityName">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationCityName is required for the applicant if hix-ee:InsuranceApplicantFixedAddressIndicator is true [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationCityName].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationStateUSPostalServiceCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationStateUSPostalServiceCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationStateUSPostalServiceCode is required for the applicant if hix-ee:InsuranceApplicantFixedAddressIndicator is true [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationStateUSPostalServiceCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationPostalCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or not($ThisInsuranceApplicant/hix-ee:InsuranceApplicantFixedAddressIndicator[not(@xsi:nil=true())] = true()) or $PersonHomeAddress/nc:LocationPostalCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationPostalCode is required for the applicant if hix-ee:InsuranceApplicantFixedAddressIndicator is true [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationPostalCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or nc:PersonUSCitizenIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or nc:PersonUSCitizenIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:PersonUSCitizenIndicator is required for the applicant [exch:AccountTransferRequest/hix-core:Person/nc:PersonUSCitizenIndicator].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="TaxHousehold" select="/exch:AccountTransferRequest/hix-ee:TaxReturn/hix-ee:TaxHousehold[hix-ee:TaxDependent/hix-core:RoleOfPersonReference/@s:ref= $id]"/>
        <xsl:variable name="PrimaryTaxFilers" select="$TaxHousehold/hix-ee:PrimaryTaxFiler/hix-core:RoleOfPersonReference/@s:ref"/>
        <xsl:variable name="RelToTaxFiler" select="hix-core:PersonAugmentation/hix-core:PersonAssociation[nc:PersonReference/@s:ref = $PrimaryTaxFilers]"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or not($TaxHousehold) or $RelToTaxFiler/hix-core:FamilyRelationshipCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or not($TaxHousehold) or $RelToTaxFiler/hix-core:FamilyRelationshipCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:FamilyRelationshipCode is required in the association from an applicant to a primary tax filer if the applicant is a tax dependent [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonAssociation/hix-core:FamilyRelationshipCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-applicant) or hix-core:TribalAugmentation/hix-core:PersonAmericanIndianOrAlaskaNativeIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-applicant) or hix-core:TribalAugmentation/hix-core:PersonAmericanIndianOrAlaskaNativeIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:PersonAmericanIndianOrAlaskaNativeIndicator is required in hix-core:TribalAugmentation [exch:AccountTransferRequest/hix-core:Person/hix-core:TribalAugmentation/hix-core:PersonAmericanIndianOrAlaskaNativeIndicator].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="iswages" select="exists(hix-core:PersonAugmentation/hix-core:PersonIncome[hix-core:IncomeCategoryCode='Wages'])"/>
        <xsl:variable name="Employer" select="hix-core:PersonAugmentation/hix-core:PersonEmploymentAssociation/hix-core:Employer"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformationCategoryCode[not(@xsi:nil=true())]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformationCategoryCode[not(@xsi:nil=true())]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:ContactInformationCategoryCode is required (and cannot be nilled) for the primary contact person [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformationCategoryCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonAddress/nc:LocationStreet/nc:StreetFullText[not(@xsi:nil=true())])=count($PersonAddress)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonAddress/nc:LocationStreet/nc:StreetFullText[not(@xsi:nil=true())])=count($PersonAddress)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationStreet/nc:StreetFullText is required (and cannot be nilled) in the home and/or mailing address of the primary contact person [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationStreet/nc:StreetFullText].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonAddress/nc:LocationCityName[not(@xsi:nil=true())])=count($PersonAddress)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonAddress/nc:LocationCityName[not(@xsi:nil=true())])=count($PersonAddress)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationCityName is required (and cannot be nilled) in the home and/or mailing address of the primary contact person [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationCityName].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonAddress[nc:LocationCountryISO3166Alpha3Code = 'USA' or not(nc:LocationCountryISO3166Alpha3Code)][nc:LocationStateUSPostalServiceCode[not(@xsi:nil=true())]])=count($PersonAddress[nc:LocationCountryISO3166Alpha3Code = 'USA' or not(nc:LocationCountryISO3166Alpha3Code)])"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonAddress[nc:LocationCountryISO3166Alpha3Code = 'USA' or not(nc:LocationCountryISO3166Alpha3Code)][nc:LocationStateUSPostalServiceCode[not(@xsi:nil=true())]])=count($PersonAddress[nc:LocationCountryISO3166Alpha3Code = 'USA' or not(nc:LocationCountryISO3166Alpha3Code)])">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationStateUSPostalServiceCode is required (and cannot be nilled) in the home and/or mailing address of the primary contact person if the country code is USA or if country code is absent [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationStateUSPostalServiceCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or count($PersonAddress[(nc:LocationCountryISO3166Alpha3Code = 'USA') or not(nc:LocationCountryISO3166Alpha3Code)][nc:LocationPostalCode[not(@xsi:nil=true())]]) = count($PersonAddress[(nc:LocationCountryISO3166Alpha3Code = 'USA') or not(nc:LocationCountryISO3166Alpha3Code)])"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or count($PersonAddress[(nc:LocationCountryISO3166Alpha3Code = 'USA') or not(nc:LocationCountryISO3166Alpha3Code)][nc:LocationPostalCode[not(@xsi:nil=true())]]) = count($PersonAddress[(nc:LocationCountryISO3166Alpha3Code = 'USA') or not(nc:LocationCountryISO3166Alpha3Code)])">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:LocationPostalCode is required (and cannot be nilled) in the home and/or mailing address of the primary contact person if the country code is USA or if country code is absent [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationPostalCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-contact) or not( hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformation/nc:ContactTelephoneNumber][not(nc:ContactInformationIsPrimaryIndicator)])"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-contact) or not( hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation[hix-core:ContactInformation/nc:ContactTelephoneNumber][not(nc:ContactInformationIsPrimaryIndicator)])">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                    nc:ContactInformationIsPrimaryIndicator is required in hix-core:PersonContactInformationAssociation when it is a telephone number group of the primary contact person [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/nc:ContactInformationIsPrimaryIndicator].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($ThisPrimaryContact/hix-ee:SSFPrimaryContactPreferenceCode='TextMessage') or  hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactTelephoneNumber"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($ThisPrimaryContact/hix-ee:SSFPrimaryContactPreferenceCode='TextMessage') or hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactTelephoneNumber">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:ContactTelephoneNumber is required for the primary contact person if the Contact Preference Code is TextMessage [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactTelephoneNumber].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="(not($is-household) and not($is-contact)) or not($is-inbound) or hix-core:PersonAugmentation/hix-core:PersonMedicaidIdentification or hix-core:PersonAugmentation/hix-core:PersonCHIPIdentification"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(not($is-household) and not($is-contact)) or not($is-inbound) or hix-core:PersonAugmentation/hix-core:PersonMedicaidIdentification or hix-core:PersonAugmentation/hix-core:PersonCHIPIdentification">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:PersonMedicaidIdentification or hix-core:PersonCHIPIdentification is required if sent from state to FFE [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/(hix-core:PersonMedicaidIdentification|hix-core:PersonCHIPIdentification)].                 </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-household) or not($is-applicant) or hix-core:PersonAugmentation/hix-core:PersonMarriedIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-household) or not($is-applicant) or hix-core:PersonAugmentation/hix-core:PersonMarriedIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:PersonMarriedIndicator is required for a Household Member if they are also an Applicant [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonMarriedIndicator].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="age" select="if (nc:PersonBirthDate/nc:Date) then (days-from-duration(current-date() - xs:date(nc:PersonBirthDate/nc:Date)) div 365) else ()"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-household) or not($age) or ($age &lt; 9) or ($age &gt; 66) or not(nc:PersonSexText='Female') or hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus[@xsi:nil=true() or hix-core:StatusIndicator]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-household) or not($age) or ($age &lt; 9) or ($age &gt; 66) or not(nc:PersonSexText='Female') or hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus[@xsi:nil=true() or hix-core:StatusIndicator]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:PersonPregnancyStatus is required (and it must be nilled or contain hix-core:StatusIndicator) if a household member is between the ages of 9 and 66 and female [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-household) or not(nc:PersonSexText='Male' and hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator = true())"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-household) or not(nc:PersonSexText='Male' and hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator = true())">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                The hix-core:PersonPregnancyStatus/hix-core:StatusIndicator cannot be true if the household member is male. [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="primaryContactCount" select="count(hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/nc:ContactInformationIsPrimaryIndicator[not(@xsi:nil=true())][. = true()])"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$primaryContactCount &lt;= 1"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$primaryContactCount &lt;= 1">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                        A Person can only have a single "ContactInformationIsPrimaryIndicator" whose value of 'true' [
                        <xsl:text/>
                        <xsl:value-of select="$primaryContactCount"/>
                        <xsl:text/>
                        ].
         
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:LawfulPresenceStatusImmigrationDocument" priority="1107" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:LawfulPresenceStatusImmigrationDocument"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:LawfulPresenceDocumentCategoryCode = 'UnexpiredForeignPassport') or hix-ee:LawfulPresenceDocumentPersonIdentification[@xsi:nil=true() or nc:IdentificationJurisdictionISO3166Alpha3Code]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:LawfulPresenceDocumentCategoryCode = 'UnexpiredForeignPassport') or hix-ee:LawfulPresenceDocumentPersonIdentification[@xsi:nil=true() or nc:IdentificationJurisdictionISO3166Alpha3Code]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                nc:IdentificationJurisdictionISO3166Alpha3Code is required in hix-ee:LawfulPresenceDocumentPersonIdentification if the document type is UnexpiredForeignPassport [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantLawfulPresenceStatus/hix-ee:LawfulPresenceStatusImmigrationDocument/hix-ee:LawfulPresenceDocumentPersonIdentification/nc:IdentificationJurisdictionISO3166Alpha3Code].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:LawfulPresenceDocumentNumber/nc:IdentificationID) or  hix-ee:LawfulPresenceDocumentPersonIdentification"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:LawfulPresenceDocumentNumber/nc:IdentificationID) or hix-ee:LawfulPresenceDocumentPersonIdentification">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:LawfulPresenceDocumentPersonIdentification is required if the document number is present [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantLawfulPresenceStatus/hix-ee:LawfulPresenceStatusImmigrationDocument/hix-ee:LawfulPresenceDocumentPersonIdentification].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:LawfulPresenceDocumentNumber/nc:IdentificationID) or hix-ee:LawfulPresenceDocumentPersonIdentification[@xsi:nil=true() or nc:IdentificationCategoryText]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:LawfulPresenceDocumentNumber/nc:IdentificationID) or hix-ee:LawfulPresenceDocumentPersonIdentification[@xsi:nil=true() or nc:IdentificationCategoryText]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:LawfulPresenceDocumentPersonIdentification/nc:IdentificationCategoryText is required if the document number is present [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantLawfulPresenceStatus/hix-ee:LawfulPresenceStatusImmigrationDocument/hix-ee:LawfulPresenceDocumentPersonIdentification/nc:IdentificationCategoryText].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="ext:PhysicalHousehold" priority="1106" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ext:PhysicalHousehold"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-ee:HouseholdMemberReference"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-ee:HouseholdMemberReference">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                At least one reference hix-ee:HouseholdMemberReference is required in ext:PhysicalHousehold
                [exch:AccountTransferRequest/ext:PhysicalHousehold/hix-ee:HouseholdMemberReference].
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:PersonIncome" priority="1105" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:PersonIncome"/>
        <xsl:variable name="is-pay-period" select="exists(hix-core:IncomeDate/nc:Date)"/>
        <xsl:variable name="is-SSA-verified" select=".//@s:metadata = /exch:AccountTransferRequest/hix-core:VerificationMetadata[hix-core:VerificationAuthorityTDS-FEPS-AlphaCode = 'SSA']/@s:id"/>
        <xsl:variable name="is-current" select="not(hix-core:IncomeDate) and not($is-SSA-verified)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeAmount[not(@xsi:nil=true())] &gt; 0) or hix-core:IncomeCategoryCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeAmount[not(@xsi:nil=true())] &gt; 0) or hix-core:IncomeCategoryCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeCategoryCode is required if hix-core:IncomeAmount is not null for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeCategoryCode].  
                 </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeAmount[not(@xsi:nil=true())] &gt; 0) or  hix-core:IncomeFrequency"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeAmount[not(@xsi:nil=true())] &gt; 0) or hix-core:IncomeFrequency">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeFrequency is required if hix-core:IncomeAmount is not null for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeFrequency].  
                 </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or hix-core:IncomeFrequency"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or hix-core:IncomeFrequency">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeFrequency is required if hix-core:IncomeCategoryCode is Wages for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeFrequency].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or hix-core:IncomeAmount"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or hix-core:IncomeAmount">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeAmount is required if hix-core:IncomeCategoryCode is Wages for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeAmount].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or hix-core:IncomeFrequency"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or hix-core:IncomeFrequency">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeFrequency is required if hix-core:IncomeCategoryCode is Wages for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeFrequency].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or not(hix-core:IncomeFrequency/hix-core:FrequencyCode = 'Hourly') or hix-core:IncomeHoursPerWeekMeasure"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or not(hix-core:IncomeFrequency/hix-core:FrequencyCode = 'Hourly') or hix-core:IncomeHoursPerWeekMeasure">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeHoursPerWeekMeasure is required in hix-core:PersonIncome if hix-core:IncomeCategoryCode is Wages and income frequency type name is hourly for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeHoursPerWeekMeasure].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or not(hix-core:IncomeFrequency/hix-core:FrequencyCode = 'Daily') or hix-core:IncomeDaysPerWeekMeasure"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeCategoryCode = 'Wages') or not(hix-core:IncomeFrequency/hix-core:FrequencyCode = 'Daily') or hix-core:IncomeDaysPerWeekMeasure">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeDaysPerWeekMeasure is required in hix-core:PersonIncome if hix-core:IncomeCategoryCode is Wages and hix-core:IncomeFrequency/hix-core:FrequencyCode is 'Daily' for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeDaysPerWeekMeasure].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-pay-period) or hix-core:IncomeHoursPerPayPeriodMeasure"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-pay-period) or hix-core:IncomeHoursPerPayPeriodMeasure">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeHoursPerPayPeriodMeasure is required for Pay Period Information (i.e. PersonIncome elements that contain a hix-core:IncomeDate/nc:Date [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeHoursPerPayPeriodMeasure].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeCategoryCode ='SelfEmployment') or hix-core:IncomeEmploymentDescriptionText"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeCategoryCode ='SelfEmployment') or hix-core:IncomeEmploymentDescriptionText">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeEmploymentDescriptionText is required if hix-core:IncomeCategoryCode is SelfEmployment for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeEmploymentDescriptionText].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-current) or not(hix-core:IncomeCategoryCode ='Unemployment') or hix-core:IncomeUnemploymentSourceText"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-current) or not(hix-core:IncomeCategoryCode ='Unemployment') or hix-core:IncomeUnemploymentSourceText">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:IncomeUnemploymentSourceText is required if hix-core:IncomeCategoryCode is Unemployment for payment information [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeEmploymentDescriptionText].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:PersonExpense" priority="1104" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:PersonExpense"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-core:ExpenseAmount &gt; 0) or hix-core:ExpenseFrequency"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-core:ExpenseAmount &gt; 0) or hix-core:ExpenseFrequency">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:ExpenseFrequency is required if hix-core:ExpenseAmount is not null [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonExpense/hix-core:ExpenseFrequency].
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:VerificationMetadata" priority="1103" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:VerificationMetadata"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemCategoryCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemCategoryCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:InformationExchangeSystemCategoryCode is required in hix-core:VerificationRequestingSystem [exch:AccountTransferRequest/hix-core:VerificationMetadata/hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemCategoryCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemStateCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemStateCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:InformationExchangeSystemStateCode is required in hix-core:VerificationRequestingSystem if hix-core:InformationExchangeSystemCategoryCode is not Exchange [exch:AccountTransferRequest/hix-core:VerificationMetadata/hix-core:VerificationRequestingSystem/hix-core:InformationExchangeSystemStateCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="(hix-core:DHS-SAVEVerificationCode|hix-core:DHS-G845VerificationCode) or not(hix-core:VerificationAuthorityTDS-FEPS-AlphaCode='DHS')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(hix-core:DHS-SAVEVerificationCode|hix-core:DHS-G845VerificationCode) or not(hix-core:VerificationAuthorityTDS-FEPS-AlphaCode='DHS')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:DHS-SAVEVerificationCode or hix-core:DHS-G845VerificationCode is required in hix-core:VerificationMetadata if hix-core:VerificationAuthorityTDS-FEPS-AlphaCode is DHS  [exch:AccountTransferRequest/hix-core:VerificationMetadata/(hix-core:DHS-SAVEVerificationCode|hix-core:DHS-G845VerificationCode)].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-core:DHS-SAVEVerificationCode|hix-core:DHS-G845VerificationCode) or hix-core:VerificationAuthorityTDS-FEPS-AlphaCode='DHS'"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-core:DHS-SAVEVerificationCode|hix-core:DHS-G845VerificationCode) or hix-core:VerificationAuthorityTDS-FEPS-AlphaCode='DHS'">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-core:VerificationAuthorityTDS-FEPS-AlphaCode in hix-core:VerificationMetadata must be DHS if hix-core:DHS-SAVEVerificationCode or hix-core:DHS-G845VerificationCode is present  [exch:AccountTransferRequest/hix-core:VerificationMetadata/hix-core:VerificationAuthorityTDS-FEPS-AlphaCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="hix-core:VerificationIndicator or not(hix-core:VerificationAuthorityTDS-FEPS-AlphaCode='SSA')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="hix-core:VerificationIndicator or not(hix-core:VerificationAuthorityTDS-FEPS-AlphaCode='SSA')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
         hix-core:VerificationIndicator is required in hix-core:VerificationMetadata if hix-core:VerificationAuthorityTDS-FEPS-AlphaCode is SSA  [exch:AccountTransferRequest/hix-core:VerificationMetadata/hix-core:VerificationIndicator].  
         </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:RefugeeMedicalAssistanceEligibility|hix-ee:EmergencyMedicaidEligibility|hix-ee:CHIPEligibility|hix-ee:CSREligibility|hix-ee:APTCEligibility|hix-ee:MedicaidNonMAGIEligibility|hix-ee:MedicaidMAGIEligibility|hix-ee:ExchangeEligibility" priority="1102" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:RefugeeMedicalAssistanceEligibility|hix-ee:EmergencyMedicaidEligibility|hix-ee:CHIPEligibility|hix-ee:CSREligibility|hix-ee:APTCEligibility|hix-ee:MedicaidNonMAGIEligibility|hix-ee:MedicaidMAGIEligibility|hix-ee:ExchangeEligibility"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:EligibilityEstablishingSystem) or  hix-ee:EligibilityEstablishingSystem/hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-ee:EligibilityEstablishingSystem/hix-core:InformationExchangeSystemStateCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:EligibilityEstablishingSystem) or hix-ee:EligibilityEstablishingSystem/hix-core:InformationExchangeSystemCategoryCode = 'Exchange' or hix-ee:EligibilityEstablishingSystem/hix-core:InformationExchangeSystemStateCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                        hix-core:InformationExchangeSystemStateCode is required in hix-ee:EligibilityEstablishingSystem if hix-core:InformationExchangeSystemCategoryCode is not Exchange [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        /hix-ee:EligibilityEstablishingSystem/hix-core:InformationExchangeSystemStateCode].  
            
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:EligibilityIndicator = true()) or  hix-ee:EligibilityDateRange/nc:StartDate"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:EligibilityIndicator = true()) or hix-ee:EligibilityDateRange/nc:StartDate">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                    hix-ee:EligibilityDateRange/nc:StartDate is required if hix-ee:EligibilityIndicator is true [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        /hix-ee:EligibilityDateRange/nc:StartDate].  
            
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:CHIPMedicaidResidencyEligibilityBasis|hix-ee:EmergencyMedicaidResidencyEligibilityBasis|hix-ee:ExchangeQHPResidencyEligibilityBasis|hix-ee:MedicaidMAGIResidencyEligibilityBasis|hix-ee:CHIPIncomeEligibilityBasis|hix-ee:EmergencyMedicaidIncomeEligibilityBasis|hix-ee:MedicaidMAGIIncomeEligibilityBasis|hix-ee:HouseholdSizeEligibilityBasis|hix-ee:CHIPMedicaidCitizenOrImmigrantEligibilityBasis|hix-ee:EmergencyMedicaidCitizenOrImmigrantEligibilityBasis|hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis|hix-ee:MedicaidMAGI-CHIPRA214EligibilityBasis|hix-ee:MedicaidMAGISevenYearLimitEligibilityBasis|hix-ee:CHIPTitleIIWorkQuartersMetEligibilityBasis|hix-ee:CHIPTraffickingVictimCategoryEligibilityBasis|hix-ee:MedicaidMAGIFiveYearBarEligibilityBasis|hix-ee:CHIPPregnancyCategoryEligibilityBasis|hix-ee:CHIPTargetedLowIncomeChildEligibilityBasis|hix-ee:CHIPUnbornChildCategoryEligibilityBasis|hix-ee:CHIPStateHealthBenefitsEligibilityBasis|hix-ee:CHIPWaitingPeriodEligibilityBasis|hix-ee:CHIP-SSNVerificationEligibilityBasis|hix-ee:MedicaidMAGIParentCaretakerCategoryEligibilityBasis|hix-ee:MedicaidMAGIPregnancyCategoryEligibilityBasis|hix-ee:MedicaidMAGIChildCategoryEligibilityBasis|hix-ee:MedicaidMAGIAdultGroupCategoryEligibilityBasis|hix-ee:MedicaidMAGIAdultGroupXXCategoryEligibilityBasis|hix-ee:MedicaidMAGIOptionalTargetedLowIncomeChildEligibilityBasis|hix-ee:MedicaidMAGIFormerFosterCareCategoryEligibilityBasis|hix-ee:MedicaidMAGIDependentChildCoverageEligibilityBasis|hix-ee:MedicaidMAGISSNVerificationEligibilityBasis|hix-ee:RefugeeMedicalAssistanceEligibilityBasis|hix-ee:ExchangeVerifiedCitizenshipOrLawfulPresenceEligibilityBasis|hix-ee:ExchangeIncarcerationEligibilityBasis" priority="1101" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:CHIPMedicaidResidencyEligibilityBasis|hix-ee:EmergencyMedicaidResidencyEligibilityBasis|hix-ee:ExchangeQHPResidencyEligibilityBasis|hix-ee:MedicaidMAGIResidencyEligibilityBasis|hix-ee:CHIPIncomeEligibilityBasis|hix-ee:EmergencyMedicaidIncomeEligibilityBasis|hix-ee:MedicaidMAGIIncomeEligibilityBasis|hix-ee:HouseholdSizeEligibilityBasis|hix-ee:CHIPMedicaidCitizenOrImmigrantEligibilityBasis|hix-ee:EmergencyMedicaidCitizenOrImmigrantEligibilityBasis|hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis|hix-ee:MedicaidMAGI-CHIPRA214EligibilityBasis|hix-ee:MedicaidMAGISevenYearLimitEligibilityBasis|hix-ee:CHIPTitleIIWorkQuartersMetEligibilityBasis|hix-ee:CHIPTraffickingVictimCategoryEligibilityBasis|hix-ee:MedicaidMAGIFiveYearBarEligibilityBasis|hix-ee:CHIPPregnancyCategoryEligibilityBasis|hix-ee:CHIPTargetedLowIncomeChildEligibilityBasis|hix-ee:CHIPUnbornChildCategoryEligibilityBasis|hix-ee:CHIPStateHealthBenefitsEligibilityBasis|hix-ee:CHIPWaitingPeriodEligibilityBasis|hix-ee:CHIP-SSNVerificationEligibilityBasis|hix-ee:MedicaidMAGIParentCaretakerCategoryEligibilityBasis|hix-ee:MedicaidMAGIPregnancyCategoryEligibilityBasis|hix-ee:MedicaidMAGIChildCategoryEligibilityBasis|hix-ee:MedicaidMAGIAdultGroupCategoryEligibilityBasis|hix-ee:MedicaidMAGIAdultGroupXXCategoryEligibilityBasis|hix-ee:MedicaidMAGIOptionalTargetedLowIncomeChildEligibilityBasis|hix-ee:MedicaidMAGIFormerFosterCareCategoryEligibilityBasis|hix-ee:MedicaidMAGIDependentChildCoverageEligibilityBasis|hix-ee:MedicaidMAGISSNVerificationEligibilityBasis|hix-ee:RefugeeMedicalAssistanceEligibilityBasis|hix-ee:ExchangeVerifiedCitizenshipOrLawfulPresenceEligibilityBasis|hix-ee:ExchangeIncarcerationEligibilityBasis"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-core:StatusIndicator) or hix-ee:EligibilityBasisStatusCode[.='Complete']"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-core:StatusIndicator) or hix-ee:EligibilityBasisStatusCode[.='Complete']">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                    hix-ee:EligibilityBasisStatusCode with a value of Complete is required if hix-core:StatusIndicator is present [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/*/
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        /hix-ee:EligibilityBasisStatusCode].  
         
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:EligibilityBasisStatusCode[.='Complete']) or  hix-core:StatusIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:EligibilityBasisStatusCode[.='Complete']) or hix-core:StatusIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                    hix-core:StatusIndicator is required if hix-ee:EligibilityBasisStatusCode is Complete [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/*/
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        /hix-core:StatusIndicator].
            
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:MedicaidHouseholdSizeEligibilityBasis" priority="1100" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:MedicaidHouseholdSizeEligibilityBasis"/>
        <xsl:variable name="MedicaidHouseholdReference" select="preceding-sibling::hix-ee:MedicaidHouseholdReference/@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-core:StatusIndicator) or /exch:AccountTransferRequest/hix-ee:MedicaidHousehold[@s:id=$MedicaidHouseholdReference]/hix-ee:MedicaidHouseholdEffectivePersonQuantity"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-core:StatusIndicator) or /exch:AccountTransferRequest/hix-ee:MedicaidHousehold[@s:id=$MedicaidHouseholdReference]/hix-ee:MedicaidHouseholdEffectivePersonQuantity">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            hix-ee:MedicaidHouseholdEffectivePersonQuantity is required in hix-ee:MedicaidHousehold if hix-core:StatusIndicator is present in hix-ee:MedicaidHouseholdSizeEligibilityBasis [exch:AccountTransferRequest/hix-ee:MedicaidHousehold/hix-ee:MedicaidHouseholdEffectivePersonQuantity].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-core:StatusIndicator) or hix-ee:EligibilityBasisStatusCode[.='Complete']"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-core:StatusIndicator) or hix-ee:EligibilityBasisStatusCode[.='Complete']">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                    hix-ee:EligibilityBasisStatusCode with a value of Complete is required if hix-core:StatusIndicator is present [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/*/
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        /hix-ee:EligibilityBasisStatusCode].  
         
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:EligibilityBasisStatusCode[.='Complete']) or  hix-core:StatusIndicator"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:EligibilityBasisStatusCode[.='Complete']) or hix-core:StatusIndicator">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                    hix-core:StatusIndicator is required if hix-ee:EligibilityBasisStatusCode is Complete [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/*/
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        /hix-core:StatusIndicator].
            
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplicantNonESIPolicy" priority="1099" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplicantNonESIPolicy"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:InsurancePlan/hix-pm:InsurancePlanProgramCode = 'QHP') or hix-ee:InsurancePlan/hix-pm:ActuarialValueMetallicTierCode"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:InsurancePlan/hix-pm:InsurancePlanProgramCode = 'QHP') or hix-ee:InsurancePlan/hix-pm:ActuarialValueMetallicTierCode">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                 hix-ee:InsurancePlan/hix-pm:ActuarialValueMetallicTierCode is required in hix-ee:InsuranceApplicantNonESIPolicy if hix-pm:InsurancePlanProgramCode is QHP [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantNonESIPolicy/hix-ee:InsurancePlan/hix-pm:ActuarialValueMetallicTierCode].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:InsurancePlan/hix-pm:InsurancePlanProgramCode = 'QHP') or hix-ee:InsurancePlan/hix-pm:Issuer/hix-pm:IssuerIdentification"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:InsurancePlan/hix-pm:InsurancePlanProgramCode = 'QHP') or hix-ee:InsurancePlan/hix-pm:Issuer/hix-pm:IssuerIdentification">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:InsurancePlan/hix-pm:Issuer/hix-pm:IssuerIdentification is required in hix-ee:InsuranceApplicantNonESIPolicy if hix-pm:InsurancePlanProgramCode is QHP Type  is QHP [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantNonESIPolicy/hix-ee:InsurancePlan/hix-pm:Issuer/hix-pm:IssuerIdentification].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(hix-ee:InsurancePlan/hix-pm:InsurancePlanProgramCode = 'QHP') or hix-ee:InsurancePlan/hix-pm:InsurancePlanIdentification"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(hix-ee:InsurancePlan/hix-pm:InsurancePlanProgramCode = 'QHP') or hix-ee:InsurancePlan/hix-pm:InsurancePlanIdentification">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-ee:InsurancePlan/hix-pm:InsurancePlanIdentification is required in hix-ee:InsuranceApplicantNonESIPolicy if hix-pm:InsurancePlanProgramCode is QHP [exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant/hix-ee:InsuranceApplicantNonESIPolicy/hix-ee:InsurancePlan/hix-pm:InsurancePlanIdentification].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonGivenName" priority="1098" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonGivenName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 45"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 45">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonGivenName must be between 1 and 45 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,$allLetters)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,$allLetters)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonGivenName must contain only letters, hyphens, apostrophes and spaces.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'\p{L}')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\p{L}')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonGivenName must contain at least one letter.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonMiddleName" priority="1097" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonMiddleName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 45"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 45">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonMiddleName must be between 1 and 45 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,$allLetters)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,$allLetters)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonMiddleName must contain only letters, hyphens, apostrophes and spaces.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'\p{L}')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\p{L}')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonMiddleName must contain at least one letter.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonSurName" priority="1096" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonSurName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 45"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 45">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonSurName must be between 1 and 45 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,$allLetters)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,$allLetters)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonSurName must contain only letters, hyphens, apostrophes and spaces.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'\p{L}')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\p{L}')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonSurName must contain at least one letter.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonNameSuffixText" priority="1095" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonNameSuffixText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonNameSuffixText must be between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonSexText" priority="1094" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonSexText"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test=". = ('Male','Female')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = ('Male','Female')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                Invalid value for nc:PersonSexText; valid values are: Male, Female. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:StreetFullText" priority="1093" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:StreetFullText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 88"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 88">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:StreetFullText must be between 1 and 88 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:AddressSecondaryUnitText" priority="1092" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:AddressSecondaryUnitText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 75"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 75">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:AddressSecondaryUnitText must be between 1 and 75 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:LocationCityName" priority="1091" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:LocationCityName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 100"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 100">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:LocationCityName must be between 1 and 100 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:LocationPostalCode" priority="1090" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:LocationPostalCode"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^\d{5}(-?\d{4})?$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{5}(-?\d{4})?$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                For a zip code (nc:LocationPostalCode), 5 digits are required but 9 are permitted. [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonContactInformationAssociation/hix-core:ContactInformation/nc:ContactMailingAddress/nc:StructuredAddress/nc:LocationPostalCode].  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:LocationCountyName" priority="1089" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:LocationCountyName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:LocationCountyName must be between 1 and 256 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="ext:TransferActivityReferralQuantity" priority="1088" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ext:TransferActivityReferralQuantity"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 2"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 2">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>ext:TransferActivityReferralQuantity must be between 1 and 2 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:TelephoneNumberFullID" priority="1087" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:TelephoneNumberFullID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 10 and $len &lt;= 20"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 10 and $len &lt;= 20">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:TelephoneNumberFullID must be between 10 and 20 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$is-inbound or matches(., '^[\d\-]+$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-inbound or matches(., '^[\d\-]+$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:TelephoneNumberFullID must contain only numbers and hyphens.  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-inbound-not-OBR) or matches(., '^\d+$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-inbound-not-OBR) or matches(., '^\d+$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
            nc:TelephoneNumberFullID must contain only numbers.  
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:TelephoneSuffixID" priority="1086" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:TelephoneSuffixID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^\d{1,6}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{1,6}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:TelephoneSuffixID must be between 1 and 6 digits long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:SignatureName/nc:PersonFullName" priority="1085" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:SignatureName/nc:PersonFullName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 100"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 100">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonFullName must be between 1 and 100 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:LanguageName" priority="1084" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:LanguageName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:LanguageName must be between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:ContactEmailID" priority="1083" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:ContactEmailID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 5 and $len &lt;= 63"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 5 and $len &lt;= 63">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:ContactEmailID must be between 5 and 63 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="contains(.,'@')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'@')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>An email address (nc:ContactEmailID) must contain "@".</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(contains(.,' '))"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(contains(.,' '))">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>An email address may not contain spaces.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(starts-with(.,'-') or ends-with(.,'-') or contains(.,'--'))"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(.,'-') or ends-with(.,'-') or contains(.,'--'))">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>An email address may not start/end with a hyphen or contain two hyphens together.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:OrganizationName" priority="1082" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:OrganizationName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:OrganizationName must be between 1 and 256 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:TINIdentification/nc:IdentificationID" priority="1081" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:TINIdentification/nc:IdentificationID"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^\d{9}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{9}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:TINIdentification/nc:IdentificationID must be 9 digits.
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:OrganizationIdentification/nc:IdentificationID" priority="1080" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:OrganizationIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 20"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 20">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:OrganizationIdentification/nc:IdentificationID must be between 1 and 20 characters long.
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:ApplicationIdentification/nc:IdentificationID" priority="1079" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:ApplicationIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 64"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 64">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:ApplicationIdentification/nc:IdentificationID must be between 1 and 64 characters long. 
             </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonSSNIdentification/nc:IdentificationID" priority="1078" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonSSNIdentification/nc:IdentificationID"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^([1-57-8][0-9]{2}|0([1-9][0-9]|[0-9][1-9])|6([0-57-9][0-9]|[0-9][0-57-9]))([1-9][0-9]|[0-9][1-9])([1-9]\d{3}|\d[1-9]\d{2}|\d{2}[1-9]\d|\d{3}[1-9])$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^([1-57-8][0-9]{2}|0([1-9][0-9]|[0-9][1-9])|6([0-57-9][0-9]|[0-9][0-57-9]))([1-9][0-9]|[0-9][1-9])([1-9]\d{3}|\d[1-9]\d{2}|\d{2}[1-9]\d|\d{3}[1-9])$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonSSNIdentification/nc:IdentificationID must be 9 characters long and 
                - Cannot be all 0's
                - Cannot start with 000
                - Cannot start with 666
                - Cannot start with 9 (i.e. 900-999*)
                - Cannot contain XXX-00-XXXX (0's in middle piece)
                - Cannot contain XXX-XX-0000 (0's in the end piece)
                
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsurancePolicyIdentification/nc:IdentificationID" priority="1077" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsurancePolicyIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 5 and $len &lt;= 100"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 5 and $len &lt;= 100">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 5 and 100 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:PersonIdentification/nc:IdentificationID" priority="1076" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:PersonIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 50"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 50">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 50 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:LawfulPresenceDocumentNumber/nc:IdentificationID" priority="1075" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:LawfulPresenceDocumentNumber/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:LawfulPresenceDocumentPersonIdentification/nc:IdentificationID" priority="1074" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:LawfulPresenceDocumentPersonIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:MedicaidIdentification/nc:IdentificationID|hix-ee:CHIPIdentification/nc:IdentificationID" priority="1073" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:MedicaidIdentification/nc:IdentificationID|hix-ee:CHIPIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-pm:IssuerIdentification/nc:IdentificationID" priority="1072" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-pm:IssuerIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-pm:InsurancePlanIdentification/nc:IdentificationID" priority="1071" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-pm:InsurancePlanIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:PersonMedicaidIdentification/nc:IdentificationID" priority="1070" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:PersonMedicaidIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 30"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 30">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 30 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:PersonCHIPIdentification/nc:IdentificationID" priority="1069" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:PersonCHIPIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 30"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 30">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be between 1 and 30 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplicationCoverageRenewalYearQuantity" priority="1068" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplicationCoverageRenewalYearQuantity"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test=". &gt;= 1 and . &lt;= 5"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". &gt;= 1 and . &lt;= 5">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:InsuranceApplicationCoverageRenewalYearQuantity must be an integer between 1 and 5. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:LawfulPresenceDocumentCategoryText" priority="1067" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:LawfulPresenceDocumentCategoryText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 100"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 100">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:LawfulPresenceDocumentCategoryText must be between 1 and 100 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:Year|hix-ee:TaxReturnYear|hix-core:EmploymentHistoryYearDate" priority="1066" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:Year|hix-ee:TaxReturnYear|hix-core:EmploymentHistoryYearDate"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len = 4"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len = 4">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                                    
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         must be 4 digits long. 
            
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:StepID" priority="1065" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:StepID"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test=". = ('1','2','3')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = ('1','2','3')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:StepID must have the value 1, 2 or 3. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:PersonTribeName" priority="1064" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:PersonTribeName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:PersonTribeName must be between 1 and 256 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-pm:InsurancePlanRateAmount" priority="1063" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-pm:InsurancePlanRateAmount"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 12"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 12">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-pm:InsurancePlanRateAmount must be between 1 and 12 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-pm:InsurancePlanName" priority="1062" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-pm:InsurancePlanName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 2 and $len &lt;= 100"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 2 and $len &lt;= 100">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-pm:InsurancePlanName must be between 2 and 100 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:VerificationInconsistencyJustificationText" priority="1061" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:VerificationInconsistencyJustificationText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 5 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 5 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:VerificationInconsistencyJustificationText must be between 5 and 256 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonRaceText" priority="1060" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonRaceText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 2 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 2 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonRaceText must be between 2 and 256 characters long. 
             </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonEthnicityText" priority="1059" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonEthnicityText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 5 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 5 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonEthnicityText must be between 5 and 256 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:PregnancyStatusExpectedBabyQuantity" priority="1058" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:PregnancyStatusExpectedBabyQuantity"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test=". &lt; 10"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". &lt; 10">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                hix-core:PregnancyStatusExpectedBabyQuantity must be less than 10 [exch:AccountTransferRequest/hix-core:Person/hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:PregnancyStatusExpectedBabyQuantity].  
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeHoursPerWeekMeasure" priority="1057" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeHoursPerWeekMeasure"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 10"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 10">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:IncomeHoursPerWeekMeasure must be between 1 and 10 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplicantParentAverageHoursWorkedPerWeekValue" priority="1056" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplicantParentAverageHoursWorkedPerWeekValue"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-inbound-not-OBR) or ($len &gt;= 1 and $len &lt;= 3)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-inbound-not-OBR) or ($len &gt;= 1 and $len &lt;= 3)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:InsuranceApplicantParentAverageHoursWorkedPerWeekValue must be between 1 and 3 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeDaysPerWeekMeasure" priority="1055" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeDaysPerWeekMeasure"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len = 1"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len = 1">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:IncomeDaysPerWeekMeasure must 1 character long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:ExpenseAmount" priority="1054" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:ExpenseAmount"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 12"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 12">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:ExpenseAmount must be between 1 and 12 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:ExpenseCategoryText" priority="1053" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:ExpenseCategoryText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 5 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 5 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:ExpenseCategoryText must be between 5 and 256 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeEmploymentDescriptionText" priority="1052" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeEmploymentDescriptionText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 2 and $len &lt;= 256"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 2 and $len &lt;= 256">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:IncomeEmploymentDescriptionText must be between 2 and 256 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeUnemploymentSourceText" priority="1051" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeUnemploymentSourceText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 50"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 50">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:IncomeUnemploymentSourceText must be between 1 and 50 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeAmount" priority="1050" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeAmount"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 19"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 19">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:IncomeAmount must be between 1 and 19 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:InformationExchangeSystemCountyName" priority="1049" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:InformationExchangeSystemCountyName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:InformationExchangeSystemCountyName must be between 1 and 18 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:HouseholdSizeQuantity" priority="1048" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:HouseholdSizeQuantity"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 10"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 10">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:HouseholdSizeQuantity must be between 1 and 10 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:TaxReturnTotalExemptionsQuantity" priority="1047" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:TaxReturnTotalExemptionsQuantity"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 10"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 10">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:TaxReturnTotalExemptionsQuantity must be between 1 and 10 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:FacilityName" priority="1046" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:FacilityName"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 60"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 60">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:FacilityName must be between 1 and 60 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:EmploymentHistoryCreditedQuarterQuantity" priority="1045" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:EmploymentHistoryCreditedQuarterQuantity"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 10"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 10">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:EmploymentHistoryCreditedQuarterQuantity must be between 1 and 10 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:VerificationID" priority="1044" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:VerificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^.{13}[A-Z]{2}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^.{13}[A-Z]{2}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:VerificationID must be 15 characters long and the last two characters must be upper-case letters. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:VerificationDescriptionText" priority="1043" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:VerificationDescriptionText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 160"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 160">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:VerificationDescriptionText must be between 1 and 160 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:EligibilityReasonText" priority="1042" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:EligibilityReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^\d{3}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{3}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:EligibilityReasonText must be a 3-digit number.
             </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:EligibilityBasisPendingReasonText" priority="1041" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:EligibilityBasisPendingReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^\d{3}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{3}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:EligibilityBasisPendingReasonText must be a 3-digit number.
              </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:EligibilityInconsistencyReasonText" priority="1040" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:EligibilityInconsistencyReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($is-inbound-not-OBR) or matches(.,'^\d{3}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-inbound-not-OBR) or matches(.,'^\d{3}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:EligibilityInconsistencyReasonText must be a 3-digit number.
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:EligibilityBasisIneligibilityReasonText" priority="1039" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:EligibilityBasisIneligibilityReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^\d{3}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{3}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:EligibilityBasisIneligibilityReasonText must be a 3-digit number.
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:EligibilityBasisInconsistencyReasonText" priority="1038" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:EligibilityBasisInconsistencyReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,'^\d{3}$')"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{3}$')">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:EligibilityBasisInconsistencyReasonText must be a 3-digit number.
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:IncomeCompatibilityInconsistencyReasonText" priority="1037" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:IncomeCompatibilityInconsistencyReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len = 3"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len = 3">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:IncomeCompatibilityInconsistencyReasonText must be 3 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeFederalPovertyLevelPercent" priority="1036" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeFederalPovertyLevelPercent"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 3"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 3">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:IncomeFederalPovertyLevelPercent must be between 1 and 3 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:MedicaidHouseholdEffectivePersonQuantity" priority="1035" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:MedicaidHouseholdEffectivePersonQuantity"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 10"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 10">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:MedicaidHouseholdEffectivePersonQuantity must be between 1 and 10 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:APTCMaximumAmount" priority="1034" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:APTCMaximumAmount"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 12"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 12">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:APTCMaximumAmount must be between 1 and 12 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplicantAgeLeftFosterCare" priority="1033" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplicantAgeLeftFosterCare"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 2"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 2">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:InsuranceApplicantAgeLeftFosterCare must be between 1 and 2 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonAgeMeasure/nc:MeasurePointValue" priority="1032" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonAgeMeasure/nc:MeasurePointValue"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 10"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 10">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:MeasurePointValue must be between 1 and 10 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeHoursPerPayPeriodMeasure" priority="1031" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeHoursPerPayPeriodMeasure"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 7"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 7">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:IncomeHoursPerPayPeriodMeasure must be between 1 and 7 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsurancePremiumAmount" priority="1030" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsurancePremiumAmount"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 12"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 12">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:InsurancePremiumAmount must be between 1 and 12 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsurancePremiumAPTCAmount" priority="1029" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsurancePremiumAPTCAmount"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 12"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 12">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:InsurancePremiumAPTCAmount must be between 1 and 12 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsurancePremiumSubscriberAmount" priority="1028" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsurancePremiumSubscriberAmount"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 12"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 12">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:InsurancePremiumSubscriberAmount must be between 1 and 12 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:LawfulPresenceDocumentPersonIdentification/nc:IdentificationCategoryText" priority="1027" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:LawfulPresenceDocumentPersonIdentification/nc:IdentificationCategoryText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 50"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 50">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationCategoryText must be
                between 1 and 50 characters long. </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="ext:TransferActivity/nc:ActivityIdentification/nc:IdentificationID" priority="1026" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ext:TransferActivity/nc:ActivityIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 20"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 20">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be
                between 1 and 20 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:ReferralActivity/nc:ActivityIdentification/nc:IdentificationID" priority="1025" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:ReferralActivity/nc:ActivityIdentification/nc:IdentificationID"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 20"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 20">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationID must be
                between 1 and 20 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:DisenrollmentActivityReasonText" priority="1024" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:DisenrollmentActivityReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:DisenrollmentActivityReasonText must be
                between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:EnrollmentActivityReasonText" priority="1023" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:EnrollmentActivityReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 18"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 18">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:EnrollmentActivityReasonText must be
                between 1 and 18 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:ReferralActivityReasonText" priority="1022" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:ReferralActivityReasonText"/>
        <xsl:variable name="len" select="string-length(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 35"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 35">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:ReferralActivityReasonText must be
                between 1 and 35 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:IncomeEligibilityBasisStateThresholdFPLPercent" priority="1021" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:IncomeEligibilityBasisStateThresholdFPLPercent"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 3"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 3">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-ee:IncomeEligibilityBasisStateThresholdFPLPercent must be
                between 1 and 3 characters long. 
                </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:VerificationAuthorityName" priority="1020" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:VerificationAuthorityName"/>
        <xsl:variable name="len" select="string-length(normalize-space(string(.)))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1 and $len &lt;= 100"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 100">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:VerificationAuthorityName must be
            between 1 and 100 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:ResponseCode" priority="1019" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:ResponseCode"/>
        <xsl:variable name="len" select="string-length(string(.))"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$len &gt;= 1  and $len &lt;= 8"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$len &gt;= 1 and $len &lt;= 8">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:ResponseCode must be between 1 and 8 characters long. 
            </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:LocationCountyCode" priority="1018" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:LocationCountyCode"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,$threedigits)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,$threedigits)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:LocationCountyCode must contain exactly 3 digits.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:LocationCountryISO3166Alpha3Code" priority="1017" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:LocationCountryISO3166Alpha3Code"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,$threechars)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,$threechars)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:LocationCountryISO3166Alpha3Code must contain exactly 3 uppercase characters.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:IdentificationJurisdictionISO3166Alpha3Code" priority="1016" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:IdentificationJurisdictionISO3166Alpha3Code"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="matches(.,$threechars)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,$threechars)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:IdentificationJurisdictionISO3166Alpha3Code must contain exactly 3 uppercase characters.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncarcerationDate | hix-core:PersonAdoptionDate | hix-core:SignatureDate | hix-ee:LawfulPresenceDocumentExpirationDate |  nc:AssociationBeginDate |  nc:AssociationEndDate | nc:EndDate |  nc:PersonBirthDate | nc:StartDate | scr:AdmitToDate | hix-core:ImmigrationStatusGrantDate |  hix-ee:ESIExpectedChangeDate | hix-ee:InsuranceApplicantESIEnrollmentEligibilityDate | hix-ee:SEPQualifyingEventDate" priority="1015" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncarcerationDate | hix-core:PersonAdoptionDate | hix-core:SignatureDate | hix-ee:LawfulPresenceDocumentExpirationDate |  nc:AssociationBeginDate |  nc:AssociationEndDate | nc:EndDate |  nc:PersonBirthDate | nc:StartDate | scr:AdmitToDate | hix-core:ImmigrationStatusGrantDate |  hix-ee:ESIExpectedChangeDate | hix-ee:InsuranceApplicantESIEnrollmentEligibilityDate | hix-ee:SEPQualifyingEventDate"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:Date"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:Date">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        nc:Date is required in 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        .
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:IncomeDate" priority="1014" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:IncomeDate"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:Date|nc:Year|nc:YearMonth"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:Date|nc:Year|nc:YearMonth">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        nc:Date or nc:Year or nc:YearMonth is required in 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        .
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:VerificationDate | hix-ee:EligibilityDetermination/nc:ActivityDate | hix-ee:EligibilityBasisDetermination/nc:ActivityDate | hix-ee:IncomeCompatibilityDetermination/nc:ActivityDate" priority="1013" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:VerificationDate | hix-ee:EligibilityDetermination/nc:ActivityDate | hix-ee:EligibilityBasisDetermination/nc:ActivityDate | hix-ee:IncomeCompatibilityDetermination/nc:ActivityDate"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:DateTime"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:DateTime">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        nc:DateTime is required in 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                        .
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:SignatureDate/nc:Date|hix-ee:InsuranceApplicationAssisterAssociation/nc:AssociationBeginDate/nc:Date|hix-ee:LawfulPresenceStatusEligibility/hix-ee:EligibilityDateRange/nc:StartDate/nc:Date|hix-core:PersonAdoptionDate/nc:Date" priority="1012" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:SignatureDate/nc:Date|hix-ee:InsuranceApplicationAssisterAssociation/nc:AssociationBeginDate/nc:Date|hix-ee:LawfulPresenceStatusEligibility/hix-ee:EligibilityDateRange/nc:StartDate/nc:Date|hix-core:PersonAdoptionDate/nc:Date"/>
        <xsl:variable name="year" select="year-from-date(xs:date(.))"/>
        <xsl:variable name="current-year" select="year-from-date(current-date())"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="$year &gt; 1912 and $year &lt;= $current-year"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$year &gt; 1912 and $year &lt;= $current-year">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>The year in this nc:Date must be greater than 1912 and less than or equal to the current year.
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:PersonName" priority="1011" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:PersonName"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(nc:PersonFullName)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(nc:PersonFullName)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:PersonName must not contain nc:PersonFullName.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:SignatureName" priority="1010" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:SignatureName"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not(* except nc:PersonFullName)"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(* except nc:PersonFullName)">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>hix-core:SignatureName must contain nc:PersonFullName as its only child.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:ContactTelephoneNumber" priority="1009" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:ContactTelephoneNumber"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="nc:FullTelephoneNumber/nc:TelephoneNumberFullID"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="nc:FullTelephoneNumber/nc:TelephoneNumberFullID">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>nc:FullTelephoneNumber/nc:TelephoneNumberFullID is required in nc:ContactTelephoneNumber.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-core:RoleOfPersonReference|hix-ee:HouseholdMemberReference|nc:PersonReference|hix-ee:ESIContactPersonReference" priority="1008" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-core:RoleOfPersonReference|hix-ee:HouseholdMemberReference|nc:PersonReference|hix-ee:ESIContactPersonReference"/>
        <xsl:variable name="personref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-core:Person[@s:id = $personref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-core:Person[@s:id = $personref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-core:Person.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:InsuranceApplicationAssisterReference" priority="1007" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:InsuranceApplicationAssisterReference"/>
        <xsl:variable name="personref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-ee:Assister[@s:id = $personref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-ee:Assister[@s:id = $personref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-ee:Assister.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:AuthorizedRepresentativeReference" priority="1006" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:AuthorizedRepresentativeReference"/>
        <xsl:variable name="personref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-ee:AuthorizedRepresentative[@s:id = $personref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-ee:AuthorizedRepresentative[@s:id = $personref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-ee:AuthorizedRepresentative.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:ESIReference" priority="1005" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:ESIReference"/>
        <xsl:variable name="esiref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-ee:ESI[@s:id = $esiref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-ee:ESI[@s:id = $esiref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-ee:ESI.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:ReferralActivityReceiverReference" priority="1004" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:ReferralActivityReceiverReference"/>
        <xsl:variable name="sysref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-core:Receiver[@s:id = $sysref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-core:Receiver[@s:id = $sysref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-core:Receiver.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:ReferralActivitySenderReference" priority="1003" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:ReferralActivitySenderReference"/>
        <xsl:variable name="sysref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-core:Sender[@s:id = $sysref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-core:Sender[@s:id = $sysref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-core:Sender.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:MedicaidHouseholdReference" priority="1002" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:MedicaidHouseholdReference"/>
        <xsl:variable name="hhref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-ee:MedicaidHousehold[@s:id = $hhref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-ee:MedicaidHousehold[@s:id = $hhref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-ee:MedicaidHousehold.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="nc:OrganizationReference|hix-core:IncomeSourceOrganizationReference" priority="1001" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="nc:OrganizationReference|hix-core:IncomeSourceOrganizationReference"/>
        <xsl:variable name="orgref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-core:Employer[@s:id = $orgref] or //hix-core:Organization[@s:id = $orgref] or //hix-pm:RolePlayedByOrganization[@s:id = $orgref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-core:Employer[@s:id = $orgref] or //hix-core:Organization[@s:id = $orgref] or //hix-pm:RolePlayedByOrganization[@s:id = $orgref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to a hix-core:Employer or hix-core:Organization or hix-pm:RolePlayedByOrganization.
                        
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    	
    <!--RULE -->
    
    <xsl:template match="hix-ee:ReferralActivityEligibilityReasonReference" priority="1000" mode="M21">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="hix-ee:ReferralActivityEligibilityReasonReference"/>
        <xsl:variable name="elref" select="@s:ref"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="//hix-ee:LawfulPresenceStatusEligibility[@s:id = $elref] or //hix-ee:APTCEligibility[@s:id = $elref] or //hix-ee:CHIPEligibility[@s:id = $elref] or //hix-ee:CSREligibility[@s:id = $elref] or //hix-ee:EmergencyMedicaidEligibility[@s:id = $elref] or //hix-ee:ExchangeEligibility[@s:id = $elref] or //hix-ee:MedicaidMAGIEligibility[@s:id = $elref] or //hix-ee:MedicaidNonMAGIEligibility[@s:id = $elref] or //hix-ee:RefugeeMedicalAssistanceEligibility[@s:id = $elref]"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="//hix-ee:LawfulPresenceStatusEligibility[@s:id = $elref] or //hix-ee:APTCEligibility[@s:id = $elref] or //hix-ee:CHIPEligibility[@s:id = $elref] or //hix-ee:CSREligibility[@s:id = $elref] or //hix-ee:EmergencyMedicaidEligibility[@s:id = $elref] or //hix-ee:ExchangeEligibility[@s:id = $elref] or //hix-ee:MedicaidMAGIEligibility[@s:id = $elref] or //hix-ee:MedicaidNonMAGIEligibility[@s:id = $elref] or //hix-ee:RefugeeMedicalAssistanceEligibility[@s:id = $elref]">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        A 
                        <xsl:text/>
                        <xsl:value-of select="name(.)"/>
                        <xsl:text/>
                         reference must have an ID that points to an Eligibility element.
                
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    <xsl:template match="text()" priority="-1" mode="M21"/>
    <xsl:template match="@*|node()" priority="-2" mode="M21">
        <xsl:apply-templates select="*" mode="M21"/>
    </xsl:template>
    
    <!--PATTERN Generic-->
    	
    <!--RULE -->
    
    <xsl:template match="*[@s:metadata]" priority="1000" mode="M22">
        <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@s:metadata]"/>
        <xsl:variable name="metadataref" select="for $m in data(@s:metadata) return tokenize($m,'\s+')"/>
        <xsl:variable name="metadataids" select="//hix-core:VerificationMetadata/@s:id/string(.)"/>
        		
        <!--ASSERT -->
        
        <xsl:choose>
            <xsl:when test="not($metadataref[not(. = $metadataids)])"/>
            <xsl:otherwise>
                <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($metadataref[not(. = $metadataids)])">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>
                        An s:metadata attribute must reference one or more hix-core:VerificationMetadata elements 
                        <xsl:text/>
                        <xsl:value-of select="$metadataref[not(. = $metadataids)]"/>
                        <xsl:text/>
                         does not.
               
                    </svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*" mode="M22"/>
    </xsl:template>
    <xsl:template match="text()" priority="-1" mode="M22"/>
    <xsl:template match="@*|node()" priority="-2" mode="M22">
        <xsl:apply-templates select="*" mode="M22"/>
    </xsl:template>
</xsl:stylesheet>
