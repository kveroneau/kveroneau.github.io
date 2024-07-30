<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" doctype-system="about:legacy-compat" />
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <title>Apple 2</title>
        <script src="script.js"></script>
        <script src="tty.js"></script>
        <script src="lores.js"></script>
        <script src="hires.js"></script>
        <script src="bell.js"></script>
        <script src="dos.js"></script>
        <script src="basic.js"></script>
        <link rel="stylesheet" href="display.css"/>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="script">
    <script type="text/applesoft-basic">
      <xsl:value-of select="."/>
    </script>
  </xsl:template>
</xsl:stylesheet>