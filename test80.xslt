
<!-- Parties -->
<xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner">
<xsl:choose>
    <xsl:when test="Contact/@role = 'from'">
        <xsl:call-template name="createParties">
            <xsl:with-param name="v_path" select="."/>
        </xsl:call-template>                
    </xsl:when>
    <xsl:when test="Contact/@role = 'soldTo'">
        <xsl:call-template name="createParties">
            <xsl:with-param name="v_path" select="."/>
        </xsl:call-template>                
    </xsl:when>
</xsl:choose>
</xsl:for-each>

<!-- Create Party Section -->
<xsl:template name="createParties">
<xsl:param name="v_path"/>
<invoiceParties>
    <role>
        <xsl:value-of select="substring(Contact/@role, 1, 30)"/>
    </role>
    <xsl:if test="string-length(normalize-space(Contact/Name)) > 0">
        <name>
            <xsl:value-of select="substring(Contact/Name, 1, 256)"/>
        </name>
        <xsl:if test="Contact/PostalAddress">
            <providerAddresses>
                <xsl:for-each select="Contact/PostalAddress">
                    <postalAddresses>
                        <streetLines>
                            <xsl:value-of select="Street"/>
                        </streetLines>
                        <town>
                            <xsl:value-of select="City"/>
                        </town>
                        <xsl:if test="string-length(normalize-space(State)) > 0">
                            <region>
                                <xsl:value-of select="substring(State, 1, 3)"/>
                            </region>
                        </xsl:if>
                        <xsl:if test="string-length(normalize-space(PostalCode)) > 0">
                            <postalCode>
                                <xsl:value-of select="substring(PostalCode, 1, 10)"/>
                            </postalCode>
                        </xsl:if>
                        <country>
                            <xsl:value-of select="substring(Country/@isoCountryCode, 1, 3)"/>
                        </country>
                        <scriptCodeKey>
                            <xsl:value-of select="'Zzzz'"/>
                        </scriptCodeKey>
                    </postalAddresses>
                </xsl:for-each>
            </providerAddresses>
        </xsl:if>
    </xsl:if>
    <xsl:if test="//InvoicePartner/IdReference/@domain = 'vatID'">
        <providerOtherInfos>
            <domain>
                <xsl:value-of select="//InvoicePartner/IdReference/@domain['vatID']"/>
            </domain>
            <value>
                <xsl:value-of select="//InvoicePartner/IdReference/@identifier"/>
            </value>
        </providerOtherInfos>
    </xsl:if>
</invoiceParties>
</xsl:template>

<!-- Attachments -->
<xsl:if test="AttachmentList/Attachment">
<xsl:call-template name="Attachment">
    <xsl:with-param name="attachmentList" select="AttachmentList"/>
</xsl:call-template>
</xsl:if>

<!-- Attachments Template -->
<xsl:template name="Attachment">
<xsl:param name="attachmentList"/>
<xsl:variable name="v_taxInv" select="//InvoiceDetailRequestHeader/Extrinsic[@name = 'taxInvoiceAttachmentName']"/>
<xsl:variable name="v_invoicePDF" select="//InvoiceDetailRequestHeader/Extrinsic[@name = 'invoicePDF']"/>

<xsl:for-each select="$attachmentList/Attachment">
    <xsl:variable name="cid_taxInv" select="substring-after($v_taxInv, 'cid:')"/>
    <xsl:variable name="cid_invoicePdf" select="substring-after($v_invoicePDF/Attachment/URL, 'cid:')"/>
    <attachments>
        <xsl:choose>
            <xsl:when test="exists($v_taxInv) and AttachmentID = $cid_taxInv">
                <isDefault>
                    <xsl:value-of select="exists($v_invoicePDF)"/>
                </isDefault>
                <fileName>
                    <xsl:value-of select="$cid_taxInv"/>
                </fileName>
                <documentType>
                    <xsl:value-of select="'Invoice'"/>
                </documentType>
            </xsl:when>
            <xsl:when test="not(exists($v_taxInv)) and exists($v_invoicePDF) and AttachmentID = $cid_invoicePdf">
                <isDefault>
                    <xsl:value-of select="exists($v_invoicePDF)"/>
                </isDefault>
                <fileName>
                    <xsl:value-of select="$cid_invoicePdf"/>
                </fileName>
                <documentType>
                    <xsl:value-of select="'Invoice'"/>
                </documentType>
            </xsl:when>
            <xsl:otherwise>
                <fileName>
                    <xsl:value-of select="AttachmentName"/>
                </fileName>
                <documentType>
                    <xsl:value-of select="'Others'"/>
                </documentType>
            </xsl:otherwise>
        </xsl:choose>
    </attachments>
</xsl:for-each>
</xsl:template>
