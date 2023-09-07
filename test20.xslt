
<xsl:template match="Combined">
    <!-- Line Item Mapping -->
    <xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder">
        <!-- Material Based Mapping Line Item Details -->
        <xsl:for-each select="InvoiceDetailItem">
            <lineItems>
                <xsl:if test="string-length(normalize-space(@invoiceLineNumber)) > 0">
                    <invoiceDocumentItem>
                        <xsl:value-of select="@invoiceLineNumber"/>
                    </invoiceDocumentItem>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(SubtotalAmount/Money/@currency)) > 0">
                    <currency>
                        <xsl:value-of select="substring(SubtotalAmount/Money/@currency, 1, 5)"/>
                    </currency>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(SubtotalAmount/Money)) > 0">
                    <amount>
                        <xsl:value-of select="format-number(xs:decimal(SubtotalAmount/Money), '0.000000')"/>
                    </amount>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(UnitOfMeasure)) > 0">
                    <externalUnitOfMeasure>
                        <xsl:value-of select="substring(UnitOfMeasure, 1, 30)"/>
                    </externalUnitOfMeasure>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(UnitPrice/Money)) > 0">
                    <unitPrice>
                        <xsl:value-of select="format-number(xs:decimal(UnitPrice/Money), '0.000000')"/>
                    </unitPrice>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(InvoiceDetailItemReference/Description)) > 0">
                    <description>
                        <xsl:value-of select="InvoiceDetailItemReference/Description"/>
                    </description>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(Tax/TaxDetail[1]/@percentageRate)) > 0 ">
                    <taxRate>
                        <xsl:value-of select="format-number(xs:decimal(Tax/TaxDetail[1]/@percentageRate), '0.000000')"/>
                    </taxRate>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(Tax/TaxDetail[1]/@category)) > 0 ">
                    <externalTaxCode>
                        <xsl:value-of select="Tax/TaxDetail[1]/@category"/>
                    </externalTaxCode>
                </xsl:if>
                <xsl:if test="string-length(normalize-space()) > 0">
                    <taxCountry>
                        <xsl:value-of select="substring(, 1, 3)"/>
                    </taxCountry>
                </xsl:if>
            </lineItems>               
        </xsl:for-each>           
    </xsl:for-each>
</xsl:template>
