
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
            <receiverSystemId>
                <xsl:value-of select="substring(Payload/cXML/Header/To/Credential[@domain='SystemID']/Identity, 1,30)"/>
            </receiverSystemId>
            <receiverCompanyCode>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner/Contact[@role = 'billTo']/@addressID, 1, 10)"/>
            </receiverCompanyCode>
            <receiverSupplier>
                <xsl:value-of select="substring(Payload/cXML/Header/From/Credential[@domain = 'VendorID']/Identity, 1,10)"/>
            </receiverSupplier>
            <purpose>
                <xsl:choose>
                    <xsl:when test="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@purpose = 'standard' or Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@purpose = 'lineLevelDebitMemo'">
                        <xsl:value-of select="'I'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'C'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </purpose>
            <currency>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/GrossAmount/Money/@currency, 1,5)"/>
            </currency>
            <grossAmount>
                <xsl:value-of select="format-number(xs:decimal(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/GrossAmount/Money), '#0.000000')"/>
            </grossAmount>
            <documentDate>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@invoiceDate, 1, 10)"/>
            </documentDate>
            <documentHeaderText>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/Comments, 1,25)"/>
            </documentHeaderText>
            <invoiceReceiptDate>
                <xsl:value-of select="substring($documentreceiptdate, 1 ,10)"/>
            </invoiceReceiptDate>
            <taxFulfillmentDate>
                <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/Tax/TaxDetail[@category = 'vat']/@taxPointDate, 1, 10)"/>
            </taxFulfillmentDate>
            <externalIds>
                <type>
                    <xsl:value-of select="'anPayloadId'"/>    
                </type>
                <id>
                    <xsl:value-of select="$anPayloadID"/>
                </id>
            </externalIds>
        </root>
    </xsl:template>


    
<!-- Line Item Mapping -->
<xsl:for-each select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder">
    <!-- Material Based Mapping Line Item Details -->
    <xsl:for-each select="InvoiceDetailItem">
        <xsl:call-template name="createItem">
            <xsl:with-param name="v_path_item" select="."/>
        </xsl:call-template>                
    </xsl:for-each>           
    <xsl:for-each select="InvoiceDetailServiceItem">
        <xsl:call-template name="createItem">
            <xsl:with-param name="v_path_item" select="."/>
        </xsl:call-template>                
    </xsl:for-each>           
</xsl:for-each>

<!-- Create DetailItem/DetailServiceItem Section -->
<xsl:template name="createItem">
    <xsl:param name="v_path_item"/>
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
                <xsl:choose>
                    <xsl:when test="contains(SubtotalAmount/Money,',')">
                        <xsl:value-of select="format-number(number(translate(SubtotalAmount/Money, ',', '.')), '#0.000000')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="format-number(xs:decimal(SubtotalAmount/Money), '#0.000000')"/>
                    </xsl:otherwise>
                </xsl:choose>
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
        <xsl:if test="string-length(normalize-space(@quantity)) > 0">
            <quantity>
                <xsl:value-of select="format-number(xs:decimal(@quantity), '0.000')"/>
            </quantity>
        </xsl:if>
    </lineItems>
</xsl:template>

</xsl:stylesheet>
