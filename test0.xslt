
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
    <xsl:param name="anPayloadID"/>
    <xsl:param name="documentreceiptdate"/>
    <xsl:template match="Combined">
        <root>
            <origin>
                <xsl:value-of select="'03'"/>
            </origin>
            <supplierInvoiceId>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@invoiceID, 1,16)"/>
            </supplierInvoiceId>
            <xsl:if test="string-length(normalize-space(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner/Contact[@role = 'billTo']/@addressID)) > 0">
                <receiverCompanyCode>
                    <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner/Contact[@role = 'billTo']/@addressID, 1, 10)"/>
                </receiverCompanyCode>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(Payload/cXML/Header/From/Credential[@domain = 'VendorID']/Identity)) > 0">
                <receiverSupplier>
                    <xsl:value-of select="substring(Payload/cXML/Header/From/Credential[@domain = 'VendorID']/Identity, 1,10)"/>
                </receiverSupplier>
            </xsl:if>
            <currency>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/GrossAmount/Money/@currency, 1,5)"/>
            </currency>
            <!-- gross Amount Template -->
            <xsl:call-template name="GrossAmount"/>
            <documentDate>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@invoiceDate, 1, 10)"/>
            </documentDate>
            <xsl:if test="string-length(normalize-space(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/Comments)) > 0">
                <documentHeaderText>
                    <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/Comments, 1,25)"/>
                </documentHeaderText>
            </xsl:if>
            <invoiceReceiptDate>
                <xsl:value-of select="substring($documentreceiptdate, 1 ,10)"/>
            </invoiceReceiptDate>
        </root>
    </xsl:template>
    <!-- common Templates -->
    <!-- Sum SubTotalAmount + TaxAmount if summary grossAmount is empty -->    
    <xsl:template name="GrossAmount">
        <!-- sum all SubTotalAmount + TaxAmounts -->
        <xsl:variable name="v_gross_amount">
            <xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailItem">
                <value>
                    <xsl:value-of select="sum(SubtotalAmount/Money + Tax/TaxDetail[1]/TaxAmount/Money)"/>
                </value>
                </xsl:for-each>
            </xsl:variable>
        <grossAmount>
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/GrossAmount/Money)) > 0">
                    <xsl:value-of select="format-number(xs:decimal(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/GrossAmount/Money), '0.000000')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                            select="format-number(xs:decimal(sum($v_gross_amount/value)), '0.000000')">
                    </xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </grossAmount>
    </xsl:template>
</xsl:stylesheet>
