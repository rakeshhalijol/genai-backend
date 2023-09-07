
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hci="http://sap.com/it/"
    xmlns:n0="http://sap.com/xi/Procurement" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
    <xsl:param name="anPayloadID"/>
    <xsl:param name="anSupplierANID"/>
    <xsl:param name="anBuyerANID"/>
    <xsl:param name="anProviderANID"/>
    <xsl:param name="anSharedSecrete"/>
    <xsl:param name="anEnvName"/>
    <!-- start with template match -->
    <xsl:template match="root">
        <Combined>
            <Payload>
        <xsl:element name="cXML">
            <xsl:attribute name="payloadID">
                <xsl:value-of select="$anPayloadID"/>
            </xsl:attribute>
            <xsl:attribute name="timestamp">
                <xsl:value-of select="concat(substring(/root/time, 0, 20), '-00:00')"/>
            </xsl:attribute>
            <!-- /cXML/Header -->
            <xsl:element name="Header">
                <xsl:element name="From">
                    <xsl:element name="Credential">
                        <xsl:attribute name="domain">
                            <xsl:value-of select="'NetworkID'"/>
                        </xsl:attribute>
                        <xsl:element name="Identity">
                            <xsl:value-of select="$anSupplierANID"/>
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
                            <xsl:value-of select="'VendorID'"/>
                        </xsl:attribute>
                        <xsl:element name="Identity">
                            <xsl:value-of select="/root/data/receiverSupplier"/>
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
                <!-- /cXML/Request/StatusUpdateRequest -->
                <xsl:element name="StatusUpdateRequest">
                    <!-- /cXML/Request/StatusUpdateRequest/DocumentReference -->
                    <xsl:element name="DocumentReference">
                        <xsl:attribute name="payloadID">
                            <xsl:value-of select="/root/data/id"/>
                        </xsl:attribute>
                    </xsl:element>
                    <!-- /cXML/Request/StatusUpdateRequest/Status -->
                    <xsl:element name="Status">
                        <xsl:attribute name="code">
                            <xsl:value-of select="'200'"/>
                        </xsl:attribute>
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="'en-US'"/>
                        </xsl:attribute>
                        <xsl:attribute name="text">
                            <xsl:value-of select="'OK'"/>
                        </xsl:attribute>
                    </xsl:element>
                    <!-- /cXML/Request/StatusUpdateRequest/InvoiceStatus -->
                    <xsl:element name="InvoiceStatus">
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when
                                    test="(/root/data/status = '2') or (/root/data/status = '6') or (/root/data/status = '4')">
                                    <xsl:value-of select="'rejected'"/>
                                </xsl:when>
                                <xsl:when test="/root/data/paymentStatus = 'C'">
                                    <xsl:value-of select="'paid'"/>
                                </xsl:when>
                                <xsl:when
                                    test="(/root/data/status = '5') and (/root/data/paymentInfos/paymentBlockingReason = '')">
                                    <xsl:value-of select="'reconciled'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'processing'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
            </Payload>
        </Combined>
    </xsl:template>
</xsl:stylesheet>