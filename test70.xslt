
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
