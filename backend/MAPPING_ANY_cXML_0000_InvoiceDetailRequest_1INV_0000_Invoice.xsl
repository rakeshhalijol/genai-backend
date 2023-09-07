
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
                            <xsl:value-of select="substring(@category, 1, 30)"/>
                        </externalCode>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space(@percentageRate)) > 0">
                        <percentage>
                            <xsl:value-of select="format-number(xs:decimal(@percentageRate), '0.000000')"/>
                        </percentage>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space(Description)) > 0">
                        <description>
                            <xsl:value-of select="Description"/>
                        </description>
                    </xsl:if>
                    <amount>
                        <xsl:value-of select="format-number(xs:decimal(TaxAmount/Money), '#0.000000')"/>
                    </amount>
                    <currency>
                        <xsl:value-of select="substring(TaxAmount/Money/@currency, 1, 3)"/>
                    </currency>
                    <xsl:if test="string-length(normalize-space(TaxAmount/Money/@alternateAmount)) > 0">
                        <baseAmountInLocalCurrency>
                            <xsl:value-of select="format-number(xs:decimal(TaxAmount/Money/@alternateAmount), '0.000000')"/>
                        </baseAmountInLocalCurrency>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space(TaxAmount/Money/@alternateCurrency)) > 0">
                        <localCurrency>
                            <xsl:value-of select="substring(TaxAmount/Money/@alternateCurrency, 1 ,5)"/>
                        </localCurrency>
                    </xsl:if>                        
                    <xsl:if test="string-length(normalize-space(TaxableAmount/Money)) > 0">
                        <baseAmountInTransactionCurrency>
                            <xsl:value-of select="format-number(xs:decimal(TaxableAmount/Money), '0.000000')"/>
                        </baseAmountInTransactionCurrency>
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
            <!-- attachments -->
            <xsl:if test="AttachmentList/Attachment">
                <xsl:call-template name="Attachment">
                    <xsl:with-param name="attachmentList"
                        select="AttachmentList"/>
                </xsl:call-template>
            </xsl:if>            
            <!-- References -->
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
                        <xsl:if test="string-length(normalize-space(InvoiceDetailServiceItemReference/@lineNumber)) > 0">
                            <itemNumber>
                                <xsl:value-of select="substring(InvoiceDetailServiceItemReference/@lineNumber, 1, 10)"/>
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
        </root>
    </xsl:template>
    <!-- common Templates -->
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
</xsl:stylesheet>