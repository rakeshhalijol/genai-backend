
<!-- Taxes Mapping -->
<xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/Tax/TaxDetail">
    <taxes>
        <xsl:if test="string-length(normalize-space(@category)) > 0">
            <externalCode>
                <xsl:value-of select="substring(@category, 1, 30)"/>
            </externalCode>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(Description)) > 0">
            <description>
                <xsl:value-of select="Description"/>
            </description>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(@percentageRate)) > 0 ">
            <percentage>
                <xsl:value-of select="format-number(xs:decimal(@percentageRate), '0.000000')"/>
            </percentage>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(TaxAmount/Money/@currency)) > 0">
            <currency>
                <xsl:value-of select="substring(TaxAmount/Money/@currency, 1, 3)"/>
            </currency>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(TaxAmount/Money)) > 0">
            <amount>
                <xsl:value-of select="format-number(xs:decimal(TaxAmount/Money), '#0.000000')"/>
            </amount>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(TaxableAmount/Money)) > 0">
            <baseAmountInTransactionCurrency>
                <xsl:value-of select="format-number(xs:decimal(TaxableAmount/Money), '0.000000')"/>
            </baseAmountInTransactionCurrency>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(TaxAmount/Money/@alternateCurrency)) > 0">
            <localCurrency>
                <xsl:value-of select="substring(TaxAmount/Money/@alternateCurrency, 1 ,5)"/>
            </localCurrency>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(TaxAmount/Money/@alternateAmount)) > 0">
            <baseAmountInLocalCurrency>
                <xsl:value-of select="format-number(xs:decimal(TaxAmount/Money/@alternateAmount), '0.000000')"/>
            </baseAmountInLocalCurrency>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(TaxLocation)) > 0">
            <country>
                <xsl:value-of select="substring(TaxLocation,1, 2)"/>
            </country>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(@isTriangularTransaction)) > 0">
            <isEuropeanCommunityVATTriangulation>
                <xsl:value-of select="@isTriangularTransaction"/>
            </isEuropeanCommunityVATTriangulation>
        </xsl:if>
    </taxes>
</xsl:for-each>

<!-- Parties -->
<xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner">
    <xsl:choose>
        <xsl:when test="Contact/@role = 'from'">
            <xsl:call-template name="createParties">
                <xsl:with-param name="v_path" select="."/>
            </xsl:call-template>                
        </xsl:when>
    </xsl:choose>
</xsl:for-each>
