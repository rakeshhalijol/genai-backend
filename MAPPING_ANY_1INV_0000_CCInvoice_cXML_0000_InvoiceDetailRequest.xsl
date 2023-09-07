
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hci="http://sap.com/it/"
    xmlns:n0="http://sap.com/xi/Procurement" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

    <xsl:param name="exchange"/>
    <xsl:param name="ancxmlversion"/>  
    <xsl:param name="anPayloadID"/>
    <xsl:param name="anSupplierANID"/>
    <xsl:param name="anBuyerANID"/>
    <xsl:param name="anProviderANID"/>
    <xsl:param name="anSharedSecrete"/>
    <xsl:param name="anContentID"/>
    <xsl:param name="anERPSystemID"/>
    <xsl:param name="anEnvName"/>
    <xsl:param name="anIsMultiERP"/>
    <xsl:variable name="v_amount_gross">
        <xsl:value-of select="replace(/root/data/grossAmount, ',', '')"/>
    </xsl:variable>
    <xsl:variable name="v_curHead" select="//root/data/currency"/>
    <xsl:variable name="v_firstCur" select="//root/data[1]/taxes[1]/currency[1]"/>

    <xsl:variable name="v_invoiceType" select="//root/data/purpose"/>
    <xsl:variable name="v_invType">
        <xsl:choose>
            <xsl:when test="$v_invoiceType = 'I'">standard</xsl:when>
            <xsl:when test="$v_invoiceType = 'C'">creditMemo</xsl:when>
            <xsl:when test="$v_invoiceType = '4'">creditMemo</xsl:when>
            <xsl:when test="$v_invoiceType = '3'">debitMemo</xsl:when>
            <xsl:otherwise>standard</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- start with template match -->
    <xsl:template match="root">
        <xsl:variable name="v_vendorId">
            <xsl:value-of select="/root/data/receiverSupplier"/>
        </xsl:variable>        
        <xsl:variable name="v_curDate">
            <xsl:value-of select="current-dateTime()"/>
        </xsl:variable>
        <xsl:variable name="v_timestamp">
            <xsl:value-of select="concat(substring($v_curDate, 1, 19), substring($v_curDate, 24, 29))"/>
        </xsl:variable>        
        <xsl:variable name="cXMLEnvelopeHeader">
            <xsl:choose>
                <xsl:when test="upper-case($anIsMultiERP) = 'TRUE'">
                    <xsl:value-of
                        select="concat('&lt;cXML payloadID=&quot;', $anPayloadID, '&quot; timestamp=&quot;', $v_timestamp, '&quot; version=&quot;', $ancxmlversion, '&quot; xml:lang=&quot;en-US&quot;&gt; &lt;Header&gt;&lt;From&gt;&lt;Credential domain=&quot;NetworkID&quot;&gt;&lt;Identity&gt;', $anSupplierANID, '&lt;/Identity&gt;&lt;/Credential&gt;&lt;Credential domain=&quot;SystemID&quot;&gt;&lt;Identity&gt;', $anERPSystemID, '&lt;/Identity&gt;&lt;/Credential&gt;&lt;/From&gt;&lt;To&gt;&lt;Credential domain=&quot;VendorID&quot;&gt;&lt;Identity&gt;', $v_vendorId, '&lt;/Identity&gt;&lt;/Credential&gt;&lt;/To&gt;&lt;Sender&gt;&lt;Credential domain=&quot;NetworkID&quot;&gt;&lt;Identity&gt;', $anProviderANID, '&lt;/Identity&gt;&lt;SharedSecret&gt;', $anSharedSecrete, '&lt;/SharedSecret&gt;&lt;/Credential&gt;&lt;UserAgent&gt;Ariba SN Buyer Adapter&lt;/UserAgent&gt;&lt;/Sender&gt;&lt;/Header&gt;')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('&lt;cXML payloadID=&quot;', $anPayloadID, '&quot; timestamp=&quot;', $v_timestamp, '&quot; version=&quot;', $ancxmlversion, '&quot; xml:lang=&quot;en-US&quot;&gt; &lt;Header&gt;&lt;From&gt;&lt;Credential domain=&quot;NetworkID&quot;&gt;&lt;Identity&gt;', $anSupplierANID, '&lt;/Identity&gt;&lt;/Credential&gt;&lt;/From&gt;&lt;To&gt;&lt;Credential domain=&quot;VendorID&quot;&gt;&lt;Identity&gt;', $v_vendorId, '&lt;/Identity&gt;&lt;/Credential&gt;&lt;/To&gt;&lt;Sender&gt;&lt;Credential domain=&quot;NetworkID&quot;&gt;&lt;Identity&gt;', $anProviderANID, '&lt;/Identity&gt;&lt;SharedSecret&gt;', $anSharedSecrete, '&lt;/SharedSecret&gt;&lt;/Credential&gt;&lt;UserAgent&gt;Ariba SN Buyer Adapter&lt;/UserAgent&gt;&lt;/Sender&gt;&lt;/Header&gt;')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cXMLEnvelopeRequest">
            <xsl:value-of
                select="concat('&lt;Request&gt; &lt;CopyRequest&gt; &lt;cXMLAttachment&gt; &lt;Attachment&gt;&lt;URL&gt;', 'cid:', $anContentID, '&lt;/URL&gt; &lt;/Attachment&gt; &lt;/cXMLAttachment&gt; &lt;/CopyRequest&gt; &lt;/Request&gt; &lt;/cXML&gt;')"/>
        </xsl:variable>
        <xsl:variable name="cXMLEnvelope">
            <xsl:value-of select="concat($cXMLEnvelopeHeader, ' ', $cXMLEnvelopeRequest)"/>
        </xsl:variable>
        <xsl:value-of select="hci:setHeader($exchange, 'cXMLEnvelope', $cXMLEnvelope)"/>
        <xsl:value-of select="hci:setHeader($exchange, 'anAttachmentName', 'CCInvoice.xml')"/>
        <xsl:value-of select="hci:setHeader($exchange, 'isANAttachment', 'YES')"/>        
        <Combined>
            <Payload>
                <xsl:element name="cXML">
                    <xsl:attribute name="payloadID">
                        <xsl:value-of select="/root/data/id"/>
                    </xsl:attribute>
                    <xsl:attribute name="timestamp">
                        <xsl:value-of select="concat(substring(/root/time, 0, 20), '-00:00')"/>
                    </xsl:attribute>
                    <!-- /cXML/Header -->
                    <xsl:element name="Header">
                        <xsl:element name="From">
                            <xsl:element name="Credential">
                                <xsl:attribute name="domain">
                                    <xsl:value-of select="'VendorID'"/>
                                </xsl:attribute>
                                <xsl:element name="Identity">
                                    <xsl:value-of select="$v_vendorId"/>
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="Credential">
                                <xsl:attribute name="domain">
                                    <xsl:value-of select="'EndPointID'"/>
                                </xsl:attribute>
                                <xsl:element name="Identity">
                                    <xsl:value-of select="'CIG'"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="To">
                            <xsl:element name="Credential">
                                <xsl:attribute name="domain">
                                    <xsl:value-of select="'NetworkID'"/>
                                </xsl:attribute>
                                <xsl:element name="Identity">
                                    <xsl:value-of select="$anSupplierANID"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="Sender">
                            <xsl:element name="Credential">
                                <xsl:attribute name="domain">
                                    <xsl:value-of select="'NetworkID'"/>
                                </xsl:attribute>
                                <xsl:element name="Identity">
                                    <xsl:value-of select="$anProviderANID"/>
                                </xsl:element>
                                <xsl:element name="SharedSecret">
                                    <xsl:value-of select="$anSharedSecrete"/>
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="UserAgent">
                                <xsl:value-of select="'Ariba Supplier'"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                    <!-- /cXML/Request -->
                    <xsl:element name="Request">
                        <xsl:choose>
                            <xsl:when test="$anEnvName = 'PROD'">
                                <xsl:attribute name="deploymentMode">
                                    <xsl:value-of select="'production'"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="deploymentMode">
                                    <xsl:value-of select="'test'"/>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- /cXML/Request/InvoiceDetailRequest -->
                        <xsl:element name="InvoiceDetailRequest">
                            <!-- /cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader -->
                            <xsl:element name="InvoiceDetailRequestHeader">
                                <xsl:attribute name="invoiceID">
                                    <xsl:value-of select="/root/data/supplierInvoiceId"/>
                                </xsl:attribute>
                                <xsl:attribute name="purpose">
                                    <xsl:value-of select="$v_invType"/>
                                </xsl:attribute>
                                <xsl:attribute name="operation">
                                    <xsl:value-of select="'new'"/>
                                </xsl:attribute>
                                <xsl:attribute name="invoiceDate">
                                    <xsl:value-of select="concat(substring(/root/data/documentDate, 0, 11), 'T00:00:00-00:00')"/>
                                </xsl:attribute>
                                <xsl:element name="InvoiceDetailHeaderIndicator">
                                    <xsl:attribute name="isHeaderInvoice">
                                        <xsl:value-of select="'yes'"/>
                                    </xsl:attribute>
                                </xsl:element>
                                <!-- short emptytag because its mandatory -->
                                <xsl:element name="InvoiceDetailLineIndicator"/>
                                <!-- find youngest NetDueDate -->
                                <xsl:variable name="v_netDueDate">
                                    <xsl:for-each select="/root/data/paymentInfos/netDueDate">
                                        <xsl:sort select="." data-type="text"/>
                                        <xsl:value-of select="concat(substring(., 0, 11), 'T00:00:00-00:00')"/>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:element name="PaymentInformation">
                                    <xsl:attribute name="paymentNetDueDate">
                                        <xsl:value-of select="substring($v_netDueDate, string-length($v_netDueDate) - 24)"/>
                                    </xsl:attribute>
                                </xsl:element>
                                <!-- Extrinsic originalInvoiceNo -->
                                <xsl:if test="/root/data/supplierInvoiceId != ''">
                                    <Extrinsic name="originalInvoiceNo">
                                        <xsl:value-of select="/root/data/supplierInvoiceId"/>
                                    </Extrinsic>
                                </xsl:if>
                            </xsl:element>
                            <!-- /cXML/Request/InvoiceDetailRequest/InvoiceDetailHeaderOrder -->
                            <xsl:element name="InvoiceDetailHeaderOrder">
                                <!-- /cXML/Request/InvoiceDetailRequest/InvoiceDetailHeaderOrder/InvoiceDetailOrderInfo -->
                                <xsl:element name="InvoiceDetailOrderInfo">
                                    <!-- short tag because its mandatory -->
                                    <xsl:element name="MasterAgreementReference">
                                        <xsl:element name="DocumentReference">
                                            <xsl:attribute name="payloadID"/>
                                        </xsl:element>
                                    </xsl:element>
                                    <!-- referenced PO Number -->
                                    <xsl:if test="/root/data/lineItems[1]/poPosting[1]/purchasingDocumentNumber[1] != ''">
                                        <xsl:element name="OrderIDInfo">
                                            <xsl:attribute name="orderID">
                                                <xsl:value-of select="/root/data/lineItems[1]/poPosting[1]/purchasingDocumentNumber[1]"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:element>
                                <!-- /cXML/Request/InvoiceDetailRequest/InvoiceDetailHeaderOrder/InvoiceDetailOrderSummary -->
                                <xsl:element name="InvoiceDetailOrderSummary">
                                    <xsl:attribute name="invoiceLineNumber">
                                        <xsl:value-of select="'1'"/>
                                    </xsl:attribute>
                                    <!-- SubtotalAmount -->
                                    <xsl:call-template name="SubTotalAmount"/>
                                    <!-- GrossAmount -->
                                    <!-- GrossAmount only map is not empty (optional) purpose = "C" or "4" change sign -->
                                    <xsl:if test="$v_amount_gross != ''">
                                        <xsl:element name="GrossAmount">
                                            <xsl:element name="Money">
                                                <xsl:attribute name="currency">
                                                    <xsl:value-of select="/root/data/currency"/>
                                                </xsl:attribute>
                                                <xsl:choose>
                                                    <xsl:when test="/root/data/purpose = 'C' or /root/data/purpose = '4'">
                                                        <xsl:value-of select="format-number(($v_amount_gross * -1), '0.000000')"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="format-number(($v_amount_gross), '0.000000')"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:if>
                                    <!-- NetAmount -->
                                    <xsl:call-template name="NetAmount"/>
                                </xsl:element>
                            </xsl:element>
                            <!-- /cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary -->
                            <xsl:element name="InvoiceDetailSummary">
                                <!-- SubtotalAmount mandatory -->
                                <xsl:call-template name="SubTotalAmount"/>
                                <!-- Tax pre check section -->
                                <!-- ckeck if currency in tax section equal -->
                                <xsl:variable name="v_cur">
                                    <xsl:for-each select="/root/data/taxes">
                                        <xsl:if test="$v_firstCur != currency">
                                            <xsl:value-of select="'notEqual'"/>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:variable>
                                <!-- sum tax amount -->
                                <xsl:variable name="v_tax_amount">
                                    <xsl:choose>
                                        <xsl:when test="$v_cur = 'notEqual'">
                                            <value>
                                                <xsl:value-of select="'0'"/>
                                            </value>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:for-each select="/root/data/taxes[amount != '']">
                                                <value>
                                                    <xsl:variable name="v_amount_t">
                                                        <xsl:value-of select="replace(amount, ',', '')"/>
                                                    </xsl:variable>
                                                    <xsl:value-of select="$v_amount_t"/>
                                                </value>
                                            </xsl:for-each>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <!-- Tax mandatory -->
                                <xsl:element name="Tax">
                                    <xsl:element name="Money">
                                        <xsl:attribute name="currency">
                                            <xsl:choose>
                                                <xsl:when test="$v_cur != 'notEqual'">
                                                    <xsl:value-of select="$v_firstCur"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="''"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:choose>
                                            <xsl:when test="$v_tax_amount != ''">
                                                <xsl:value-of
                                                    select="format-number(sum($v_tax_amount/value), '0.000000')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'0.000000'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:element>
                                    <xsl:element name="Description">
                                        <!-- Language konstant 'en-US' -->
                                        <xsl:attribute name="xml:lang">
                                            <xsl:value-of select="'en-US'"/>
                                        </xsl:attribute>
                                        <!-- Description is empty -->
                                        <xsl:value-of select="''"/>
                                    </xsl:element>
                                </xsl:element>
                                <!-- NetAmount -->
                                <xsl:call-template name="NetAmount"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </Payload>
        </Combined>
    </xsl:template>
    <!-- global templates -->
    <!-- determine total "SubTotalAmount" -->
    <xsl:template name="SubTotalAmount">
        <!-- if same currency exist then sumup data.lineItems[n].glPostings[n].amount based on debitCreditCode. 
         Incase of different currencies then map data grossAmount.
         Show negative sign for amount in case data.purpose = 'C' or '4'
         for invoice sumup should be done as S - H and for 'C' or '4' it should be H - S
    -->
        <xsl:variable name="v_amount">
            <xsl:choose>
                <xsl:when test="/root/data/lineItems/glPostings[currency != $v_curHead] or /root/data/lineItems/glPostings = ''">
                    <xsl:choose>
                        <xsl:when test="/root/data/purpose = 'C' or /root/data/purpose = '4'">
                            <value>
                                <xsl:value-of select="$v_amount_gross * -1"/>
                            </value>
                        </xsl:when>
                        <xsl:otherwise>
                            <value>
                                <xsl:value-of select="$v_amount_gross"/>
                            </value>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="/root/data/purpose = 'C' or /root/data/purpose = '4'">
                            <xsl:for-each select="/root/data/lineItems/glPostings">
                                <xsl:choose>
                                    <xsl:when test="debitCreditCode = 'H'">
                                        <value>
                                            <xsl:variable name="v_amount_h">
                                                <xsl:value-of select="concat('-' ,replace((amount), ',',''))"/>
                                            </xsl:variable>
                                            <xsl:value-of select="($v_amount_h)"/>
                                        </value>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <value>
                                            <xsl:variable name="v_amount_s">
                                                <xsl:value-of select="concat('-' ,replace((amount), ',',''))"/>
                                            </xsl:variable>
                                            <xsl:value-of select="($v_amount_s * -1)"/>
                                        </value>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="/root/data/lineItems/glPostings">
                                <xsl:choose>
                                    <xsl:when test="debitCreditCode = 'H'">
                                        <value>
                                            <xsl:variable name="v_amount_h">
                                                <xsl:value-of select="replace(amount, ',', '')"/>
                                            </xsl:variable>
                                            <xsl:value-of select="($v_amount_h * -1)"/>
                                        </value>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <value>
                                            <xsl:variable name="v_amount_s">
                                                <xsl:value-of select="replace(amount, ',', '')"/>
                                            </xsl:variable>
                                            <xsl:value-of select="($v_amount_s)"/>
                                        </value>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- SubtotalAmount -->
        <xsl:element name="SubtotalAmount">
            <xsl:element name="Money">
                <xsl:attribute name="currency">
                    <xsl:value-of select="/root/data/currency"/>
                </xsl:attribute>
                <xsl:value-of select="format-number(sum($v_amount/value), '0.000000')"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- determine total "NetAmount" -->
    <xsl:template name="NetAmount">
        <!-- sum all discount amounts -->
        <xsl:variable name="v_net_amount">
            <xsl:for-each select="/root/data/paymentInfos">
                <!-- check if manual Cash Discount is empty 17.03.2023 -->
                <xsl:if test="manualCashDiscount != ''">
                    <xsl:choose>
                        <xsl:when test="/root/data/purpose = 'C' or /root/data/purpose = '4'">
                            <value>
                                <xsl:variable name="v_amount_CDM">
                                    <xsl:value-of select="replace(manualCashDiscount, ',', '')"/>
                                </xsl:variable>
                                <xsl:value-of select="($v_amount_CDM * -1)"/>
                            </value>
                        </xsl:when>
                        <xsl:otherwise>
                            <value>
                                <xsl:variable name="v_amount_CDP">
                                    <xsl:value-of select="replace(manualCashDiscount, ',', '')"/>
                                </xsl:variable>
                                <xsl:value-of select="$v_amount_CDP"/>
                            </value>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <!-- NetAmount = GrossAmount - DiscountAmount map NetAmount only if GrossAmount not empty -->
        <xsl:if test="$v_amount_gross != ''">
            <xsl:element name="NetAmount">
                <xsl:element name="Money">
                    <xsl:attribute name="currency">
                        <xsl:value-of select="/root/data/currency"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="/root/data/purpose = 'C' or /root/data/purpose = '4'">
                            <xsl:choose>
                                <xsl:when test="$v_net_amount/value != ''">
                                    <xsl:value-of
                                        select="format-number(($v_amount_gross * -1) - sum($v_net_amount/value), '0.000000')">
                                    </xsl:value-of>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="format-number(($v_amount_gross * -1), '0.000000')">
                                    </xsl:value-of>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$v_net_amount/value != ''">
                                    <xsl:value-of
                                        select="format-number($v_amount_gross - sum($v_net_amount/value), '0.000000')">
                                    </xsl:value-of>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="format-number(($v_amount_gross), '0.000000')">
                                    </xsl:value-of>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>