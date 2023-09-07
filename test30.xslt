
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
    <xsl:param name="anPayloadID"/>
    <xsl:param name="documentreceiptdate"/>
    <xsl:template match="Combined">
        <root>
            <!--Determining Invoice or Credit Memo-->
            <xsl:variable name="v_invoiceType" select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@purpose"/>
            <xsl:choose>
                <xsl:when test="$v_invoiceType = 'standard' or $v_invoiceType = 'lineLevelDebitMemo'">
                    <lineItems>
                        <debitCreditCode>
                            <xsl:value-of select="'S'"/>
                        </debitCreditCode>
                    </lineItems>
                </xsl:when>
                <xsl:when test="$v_invoiceType = 'creditmemo' or $v_invoiceType = 'lineLevelCreditMemo'">
                    <lineItems>
                        <debitCreditCode>
                            <xsl:value-of select="'H'"/>
                        </debitCreditCode>
                    </lineItems>
                </xsl:when>
            </xsl:choose>

            <!-- Line Item Mapping -->
            <xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailItem">
                <lineItems>
                    <quantity>
                        <xsl:value-of select="format-number(xs:decimal(@quantity), '0.000')"/>
                    </quantity>
                </lineItems>
            </xsl:for-each>

            <xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailServiceItem">
                <lineItems>
                    <invoiceDocumentItem>
                        <xsl:value-of select="@invoiceLineNumber"/>
                    </invoiceDocumentItem>
                    <currency>
                        <xsl:value-of select="substring(SubtotalAmount/Money/@currency, 1, 5)"/>
                    </currency>
                    <amount>
                        <xsl:value-of select="format-number(xs:decimal(SubtotalAmount/Money), '0.000000')"/>
                    </amount>
                    <externalUnitOfMeasure>
                        <xsl:value-of select="substring(UnitOfMeasure, 1, 30)"/>
                    </externalUnitOfMeasure>
                    <unitPrice>
                        <xsl:value-of select="format-number(xs:decimal(UnitPrice/Money), '0.000000')"/>
                    </unitPrice>
                    <description>
                        <xsl:value-of select="InvoiceDetailItemReference/Description"/>
                    </description>
                    <taxRate>
                        <xsl:value-of select="format-number(xs:decimal(Tax/TaxDetail[1]/@percentageRate), '0.000000')"/>
                    </taxRate>
                </lineItems>
            </xsl:for-each>
        </root>
    </xsl:template>
</xsl:stylesheet>
