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
            <!--Determining Invoice or Credit Memo-->
            <xsl:variable name="v_purpose"/>
            <xsl:variable name="v_invoiceType" select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@purpose"/>
            <xsl:choose>
                <xsl:when test="$v_invoiceType = 'standard' or $v_invoiceType = 'lineLevelDebitMemo'">
                    <purpose>
                        <xsl:value-of select="'I'"/>
                    </purpose>
                </xsl:when>
                <xsl:when test="$v_invoiceType = 'creditmemo' or $v_invoiceType = 'lineLevelCreditMemo'">
                    <purpose>
                        <xsl:value-of select="'C'"/>
                    </purpose>
                </xsl:when>
            </xsl:choose>
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
            <xsl:if test="string-length(normalize-space(Payload/cXML/Header/To/Credential[@domain = 'SystemID']/Identity)) > 0">
                <receiverSystemId>
                    <xsl:value-of select="substring(Payload/cXML/Header/To/Credential[@domain = 'SystemID']/Identity, 1,30)"/>
                </receiverSystemId>
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
            <!-- Payment Infos Mapping -->
            <xsl:if test="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/PaymentTerm/Extrinsic[@name = 'DiscountTermsDueDate'] or 
                Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner/Contact[@role = 'receivingBank']/IdReference[@domain='ibanID']/@identifier">
                <paymentInfos>
                    <xsl:if test="//InvoiceDetailRequestHeader/PaymentTerm/Extrinsic[@name = 'DiscountTermsDueDate']">
                        <netDueDate>
                            <xsl:value-of select="//InvoiceDetailRequestHeader/PaymentTerm/Extrinsic[@name = 'DiscountTermsDueDate']"/>
                        </netDueDate>
                    </xsl:if>
                    <xsl:if test="//InvoiceDetailRequestHeader/InvoicePartner[Contact[@role = 'receivingBank']]/IdReference[@domain='ibanID']/@identifier">
                        <supplierIBAN>
                            <xsl:value-of select="substring(//InvoiceDetailRequestHeader/InvoicePartner[Contact[@role = 'receivingBank']]/IdReference[@domain='ibanID']/@identifier, 1, 32)"/>
                        </supplierIBAN>
                    </xsl:if>
                    <xsl:if test="//InvoiceDetailRequestHeader/InvoicePartner/Contact[@role = 'remitTo']/IdReference[@domain = 'reference']/@identifier">
                        <paymentReference>
                            <xsl:value-of select="substring(Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner/Contact[@role = 'remitTo']/IdReference[@domain = 'reference']/@identifier, 1, 30)"/>
                        </paymentReference>
                    </xsl:if>
                </paymentInfos>
            </xsl:if>
            <!-- Taxes Mapping -->
            <xsl:for-each
                select="Payload/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/Tax/TaxDetail">
                <taxes>
                    <xsl:if test="string-length(normalize-space(@category)) > 0">
                        <externalCode>
                           