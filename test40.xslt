
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="/">
    <root>
      <lineItems>
        <externalTaxCode>
          <xsl:value-of select="/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailServiceItem/Tax/TaxDetail/@category"/>
        </externalTaxCode>
        <taxCountry>
          <xsl:choose>
            <xsl:when test="/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailServiceItem/Tax/TaxDetail/@country">
              <xsl:value-of select="/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailServiceItem/Tax/TaxDetail/@country"/>
            </xsl:when>
            <xsl:otherwise>TBD</xsl:otherwise>
          </xsl:choose>
        </taxCountry>
        <debitCreditCode>
          <xsl:choose>
            <xsl:when test="/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@purpose = 'standard' or /cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/@purpose = 'lineLevelDebitMemo'">
              <xsl:text>S</xsl:text>
            </xsl:when>
            <xsl:otherwise>H</xsl:otherwise>
          </xsl:choose>
        </debitCreditCode>
        <quantity>
          <xsl:value-of select="/cXML/Request/InvoiceDetailRequest/InvoiceDetailOrder/InvoiceDetailServiceItem/@quantity"/>
        </quantity>
      </lineItems>
      <paymentInfos>
        <netDueDate>
          <xsl:value-of select="/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/PaymentTerm/Extrinsic[@name = 'DiscountTermsDueDate']"/>
        </netDueDate>
        <supplierIBAN>
          <xsl:value-of select="/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner/Contact[@role = 'receivingBank']/IdReference[domain='ibanID']/@identifier"/>
        </supplierIBAN>
        <paymentReference>
          <xsl:value-of select="/cXML/Request/InvoiceDetailRequest/InvoiceDetailRequestHeader/InvoicePartner[/Contact[@role = 'remitTo']&[IdReference/@domain = ‘reference’]/@identifier"/>
        </paymentReference>
      </paymentInfos>
      <taxes>
        <externalCode>
          <xsl:value-of select="/cXML/Request/InvoiceDetailRequest/InvoiceDetailSummary/Tax/TaxDetail/@category"/>
        </externalCode>
      </taxes>
    </root>
  </xsl:template>
</xsl:stylesheet>
