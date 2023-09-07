
<xsl:template match="Combined">
    <root>
        <invoiceReceiptDate>
            <xsl:value-of select="substring($documentreceiptdate, 1 ,10)"/>
        </invoiceReceiptDate>
        <xsl:if test="string-length(normalize-space(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/Tax/TaxDetail[@category = 'vat']/@taxPointDate)) > 0">
            <taxFulfillmentDate>
                <xsl:value-of select="substring(//InvoiceDetailSummary/Tax/TaxDetail[@category = 'vat']/@taxPointDate, 1, 10)"/>
            </taxFulfillmentDate>
        </xsl:if>
        <externalIds>
            <id>
                <xsl:value-of select="$anPayloadID"/>
            </id>
            <type>
                <xsl:value-of select="'anPayloadId'"/>    
            </type>
        </externalIds>
        <xsl:for-each select="(//InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailItem, //InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailServiceItem)">
            <xsl:if test="string-length(normalize-space(../InvoiceDetailOrderInfo/OrderReference/@orderID)) > 0">
                <poReferences>
                    <documentNumber>
                        <xsl:value-of select="substring(../InvoiceDetailOrderInfo/OrderReference/@orderID, 1, 10)"/>
                    </documentNumber>
                    <xsl:if test="string-length(normalize-space(InvoiceDetailItemReference/@lineNumber)) > 0">
                        <itemNumber>
                            <xsl:value-of select="substring(InvoiceDetailItemReference/@lineNumber, 1, 10)"/>
                        </itemNumber>
                    </xsl:if>
                </poReferences>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="//InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailServiceItem/ServiceEntryItemReference">
            <xsl:if test="string-length(normalize-space(@serviceEntryID)) > 0">
                <sesReferences>
                    <documentNumber>
                        <xsl:value-of select="substring(@serviceEntryID, 1, 10)"/>
                    </documentNumber>
                    <xsl:if test="string-length(normalize-space(@serviceLineNumber)) > 0">
                        <itemNumber>
                            <xsl:value-of select="@serviceLineNumber"/>
                        </itemNumber>
                    </xsl:if>
                </sesReferences>
            </xsl:if>
        </xsl:for-each>
    </root>
</xsl:template>
