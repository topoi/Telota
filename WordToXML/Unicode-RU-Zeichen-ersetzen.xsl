<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- Dieses XSLT ersetzt die Codepoints aus der Unicode-Private-Use-Area der 
        Schriftart CyrillicHlv und CryHistRoman mit den korrekten Codepoints aus dem 
        kyrillischen Block von Unicode -->
    <xsl:output method="xml" use-character-maps="russisch"></xsl:output>
    <xsl:character-map name="russisch">
        
        <!-- Beginnt bei F020, entspricht dem Space-->
        <xsl:output-character character="&#xF020;" string="&#x0020;" />
        
        <!-- Entspricht dem laut: a  -->
        <xsl:output-character character="&#xF0C0;" string="&#x0410;" />
        <xsl:output-character character="&#xF0E0;" string="&#x0430;" />
        
        <!-- Entspricht dem laut: b  -->
        <xsl:output-character character="&#xF0C1;" string="&#x0411;" />
        <xsl:output-character character="&#xF0E1;" string="&#x0431;" />
        
        <!-- Entspricht dem laut: w,v  -->
        <xsl:output-character character="&#xF0C2;" string="&#x0412;" />
        <xsl:output-character character="&#xF0E2;" string="&#x0432;" />
        <!-- Entspricht dem laut: g  -->
        <xsl:output-character character="&#xF0C3;" string="&#x0413;" />
        <xsl:output-character character="&#xF0E3;" string="&#x0433;" />
        
        <!-- Entspricht dem laut: je, e  -->
        <xsl:output-character character="&#xF0C5;" string="&#x0415;" />
        <xsl:output-character character="&#xF0E5;" string="&#x0435;" />
        
        <!-- Entspricht dem laut: d -->
        <xsl:output-character character="&#xF0C4;" string="&#x0414;" />
        <xsl:output-character character="&#xF0E4;" string="&#x0434;" />
        
        <!-- Entspricht dem laut: jo -->
        <xsl:output-character character="&#xF0A8;" string="&#x0401;" />
        <xsl:output-character character="&#xF0B8;" string="&#x0451;" />
        
        <!-- Entspricht dem laut:sh, g  -->
        <xsl:output-character character="&#xF0C6;" string="&#x0416;" />
        <xsl:output-character character="&#xF0E6;" string="&#x0436;" />
        
        <!-- Entspricht dem laut: s  -->
        <xsl:output-character character="&#xF0C7;" string="&#x0417;" />
        <xsl:output-character character="&#xF0E7;" string="&#x0437;" />
        
        <!-- Entspricht dem laut: i  -->
        <xsl:output-character character="&#xF0C8;" string="&#x0418;" />
        <xsl:output-character character="&#xF0E8;" string="&#x0438;" />
        
        <!-- Entspricht dem laut: j -->
        <xsl:output-character character="&#xF0C9;" string="&#x0419;" />
        <xsl:output-character character="&#xF0E9;" string="&#x0439;" />
        
        <!-- Entspricht dem laut: k -->
        <xsl:output-character character="&#xF0CA;" string="&#x041A;" />
        <xsl:output-character character="&#xF0EA;" string="&#x043A;" />
       
        <!-- Entspricht dem laut:l  -->
        <xsl:output-character character="&#xF0CB;" string="&#x041B;" />
        <xsl:output-character character="&#xF0EB;" string="&#x043B;" />
        
        <!-- Entspricht dem laut: m  -->
        <xsl:output-character character="&#xF0CC;" string="&#x041C;" />
        <xsl:output-character character="&#xF0EC;" string="&#x043C;" />
        
        <!-- Entspricht dem laut: n -->
        <xsl:output-character character="&#xF0CD;" string="&#x041D;" />
        <xsl:output-character character="&#xF0ED;" string="&#x043D;" />
        
        <!-- Entspricht dem laut: o -->
        <xsl:output-character character="&#xF0CE;" string="&#x041E;" />
        <xsl:output-character character="&#xF0EE;" string="&#x043E;" />
        
        <!-- Entspricht dem laut: p -->
        <xsl:output-character character="&#xF0CF;" string="&#x041F;" /> 
        <xsl:output-character character="&#xF0EF;" string="&#x043F;" />
        
        <!-- Entspricht dem laut: rollendes r -->
        <xsl:output-character character="&#xF0D0;" string="&#x0420;" />
        <xsl:output-character character="&#xF0F0;" string="&#x0440;" />
        
        <!-- Entspricht dem laut: ss  -->
        <xsl:output-character character="&#xF0D1;" string="&#x0421;" />
        <xsl:output-character character="&#xF0F1;" string="&#x0441;" />
        
        <!-- Entspricht dem laut: t -->
        <xsl:output-character character="&#xF0D2;" string="&#x0422;" />
        <xsl:output-character character="&#xF0F2;" string="&#x0442;" />
        
        <!-- Entspricht dem laut: u -->
        <xsl:output-character character="&#xF0D3;" string="&#x0423;" />
        <xsl:output-character character="&#xF0F3;" string="&#x0443;" />
        
        <!-- Entspricht dem laut: f -->
        <xsl:output-character character="&#xF0D4;" string="&#x0424;" />
        <xsl:output-character character="&#xF0F4;" string="&#x0444;" />
        
        <!-- Entspricht dem laut: ch  -->
        <xsl:output-character character="&#xF0D5;" string="&#x0425;" />
        <xsl:output-character character="&#xF0F5;" string="&#x0445;" />
        
        <!-- Entspricht dem laut:z  -->
        <xsl:output-character character="&#xF0D6;" string="&#x0426;" />
        <xsl:output-character character="&#xF0F6;" string="&#x0446;" />
        
        <!-- Entspricht dem laut: tsch  -->
        <xsl:output-character character="&#xF0D7;" string="&#x0427;" />
        <xsl:output-character character="&#xF0F7;" string="&#x0447;" />
        
        <!-- Entspricht dem laut: sch  -->
        <xsl:output-character character="&#xF0D8;" string="&#x0428;" />
        <xsl:output-character character="&#xF0F8;" string="&#x0448;" />
        
        <!-- Entspricht dem laut: schtsch -->
        <xsl:output-character character="&#xF0D9;" string="&#x0429;" />
        <xsl:output-character character="&#xF0F9;" string="&#x0449;" />
        
        <!-- Entspricht dem laut: Härtezeichen  -->
        <xsl:output-character character="&#xF0DA;" string="&#x042A;" />
        <xsl:output-character character="&#xF0FA;" string="&#x044A;" />
        
        <!-- Entspricht dem laut: y -->
        <xsl:output-character character="&#xF0DB;" string="&#x042B;" />
        <xsl:output-character character="&#xF0FB;" string="&#x044B;" />
        
        
        <!-- Entspricht dem laut: Weichheitszeichen -->
        <xsl:output-character character="&#xF0DC;" string="&#x042C;" />
        <xsl:output-character character="&#xF0FC;" string="&#x044C;" />
        
        
        <!-- Entspricht dem laut: ä -->
        <xsl:output-character character="&#xF0DD;" string="&#x042D;" />
        <xsl:output-character character="&#xF0FD;" string="&#x044D;" />
        
        <!-- Entspricht dem laut: ju -->
        <xsl:output-character character="&#xF0DE;" string="&#x042E;" />
        <xsl:output-character character="&#xF0FE;" string="&#x044E;" />
        
        <!-- Entspricht dem laut: ja -->
        <xsl:output-character character="&#xF0DF;" string="&#x042F;" />
        <xsl:output-character character="&#xF0FF;" string="&#x044F;" />
        
        <!-- CYRILLIC CAPITAL LETTER YAT -->
        <xsl:output-character character="&#xF088;" string="&#x0462;" />
        <xsl:output-character character="&#xF098;" string="&#x0463;" />
        
        <!-- Sonderzeichen -->
        <xsl:output-character character="&#xF02E;" string="&#x002E;" />
        <xsl:output-character character="&#xF021;" string="&#x0021;" />
        <xsl:output-character character="&#xF022;" string="&#x0022;" />
        <xsl:output-character character="&#xF023;" string="&#x0023;" />
        <xsl:output-character character="&#xF024;" string="&#x0024;" />
        <xsl:output-character character="&#xF025;" string="&#x0025;" />
        <xsl:output-character character="&#xF026;" string="&#x0026;" />
        <xsl:output-character character="&#xF027;" string="&#x0027;" />
        <xsl:output-character character="&#xF028;" string="&#x0028;" />
        <xsl:output-character character="&#xF029;" string="&#x0029;" />
        <xsl:output-character character="&#xF02A;" string="&#x002A;" />
        <xsl:output-character character="&#xF02B;" string="&#x002B;" />
        <xsl:output-character character="&#xF02C;" string="&#x002C;" />
        <xsl:output-character character="&#xF02D;" string="&#x002D;" />
        <xsl:output-character character="&#xF02E;" string="&#x002E;" />
        <xsl:output-character character="&#xF02F;" string="&#x002F;" />
        <xsl:output-character character="&#xF030;" string="&#x0030;" />
        <xsl:output-character character="&#xF031;" string="&#x0031;" />
        <xsl:output-character character="&#xF032;" string="&#x0032;" />
        <xsl:output-character character="&#xF033;" string="&#x0033;" />
        <xsl:output-character character="&#xF034;" string="&#x0034;" />
        <xsl:output-character character="&#xF035;" string="&#x0035;" />
        <xsl:output-character character="&#xF036;" string="&#x0036;" />
        <xsl:output-character character="&#xF037;" string="&#x0037;" />
        <xsl:output-character character="&#xF038;" string="&#x0038;" />
        <xsl:output-character character="&#xF039;" string="&#x0039;" />
        <xsl:output-character character="&#xF03A;" string="&#x003A;" />
        <xsl:output-character character="&#xF03B;" string="&#x003B;" />
        <xsl:output-character character="&#xF03C;" string="&#x003C;" />
        <xsl:output-character character="&#xF03D;" string="&#x003D;" />
        <xsl:output-character character="&#xF03E;" string="&#x003E;" />
        <xsl:output-character character="&#xF03F;" string="&#x003F;" />
        <xsl:output-character character="&#xF040;" string="&#x0040;" />
        <xsl:output-character character="&#xF05B;" string="&#x005B;" />
        <xsl:output-character character="&#xF05C;" string="&#x005C;" />
        <xsl:output-character character="&#xF05D;" string="&#x005D;" />
        <xsl:output-character character="&#xF05E;" string="&#x005E;" />
        <xsl:output-character character="&#xF05F;" string="&#x005F;" />
        <xsl:output-character character="&#xF060;" string="&#x0060;" />
        <xsl:output-character character="&#xF07B;" string="&#x007B;" />
        <xsl:output-character character="&#xF07C;" string="&#x007C;" />
        <xsl:output-character character="&#xF07D;" string="&#x007D;" />
        <xsl:output-character character="&#xF07E;" string="&#x007E;" />
        <xsl:output-character character="&#xF07F;" string="&#x007F;" />
        <xsl:output-character character="&#xF080;" string="&#x0402;" />
        <xsl:output-character character="&#xF081;" string="&#x0403;" />
        <xsl:output-character character="&#xF082;" string="&#x002C;" />
        <xsl:output-character character="&#xF083;" string="&#x0453;" />
        <xsl:output-character character="&#xF084;" string="&#x201E;" />
        <xsl:output-character character="&#xF085;" string="&#x2026;" />
        <xsl:output-character character="&#xF086;" string="&#x046A;" />
        <xsl:output-character character="&#xF087;" string="&#x046B;" />
        <xsl:output-character character="&#xF08A;" string="&#x0409;" />
        <xsl:output-character character="&#xF08B;" string="&#x227A;" />
        <xsl:output-character character="&#xF08C;" string="&#x040A;" />
        <xsl:output-character character="&#xF08D;" string="&#x040C;" />
        <xsl:output-character character="&#xF08E;" string="&#x040B;" />
        <xsl:output-character character="&#xF08F;" string="&#x040F;" />
        <xsl:output-character character="&#xF090;" string="&#x0452;" />
        <xsl:output-character character="&#xF091;" string="&#x2018;" />
        <xsl:output-character character="&#xF092;" string="&#x2019;" />
        <xsl:output-character character="&#xF093;" string="&#x201C;" />
        <xsl:output-character character="&#xF094;" string="&#x201D;" />
        <xsl:output-character character="&#xF096;" string="&#x002D;" />
        <xsl:output-character character="&#xF099;" string="&#x0467;" />
        <xsl:output-character character="&#xF09A;" string="&#x0459;" />
        <xsl:output-character character="&#xF09B;" string="&#x227B;" />
        <xsl:output-character character="&#xF09C;" string="&#x045A;" />
        <xsl:output-character character="&#xF09D;" string="&#x045C;" />
        <xsl:output-character character="&#xF09E;" string="&#x045B;" />
        <xsl:output-character character="&#xF09F;" string="&#x045F;" />
        <xsl:output-character character="&#xF0A1;" string="&#x040E;" />
        <xsl:output-character character="&#xF0A2;" string="&#x045E;" />
        <xsl:output-character character="&#xF0A3;" string="&#x0408;" />
        <xsl:output-character character="&#xF0A4;" string="&#x00A4;" />
        <xsl:output-character character="&#xF0A5;" string="&#x0490;" />
        <xsl:output-character character="&#xF0A6;" string="&#x00A6;" />
        <xsl:output-character character="&#xF0A7;" string="&#x00A7;" />
        <xsl:output-character character="&#xF0A8;" string="&#x0401;" />
        <xsl:output-character character="&#xF0A9;" string="&#x04E8;" />
        <xsl:output-character character="&#xF0AA;" string="&#x0404;" />
        <xsl:output-character character="&#xF0AB;" string="&#x226A;" />
        <xsl:output-character character="&#xF0AC;" string="&#x00AC;" />
        <xsl:output-character character="&#xF0AE;" string="&#x04E9;" />
        <xsl:output-character character="&#xF0AF;" string="&#x0407;" />
        <xsl:output-character character="&#xF0B0;" string="&#x00B0;" />
        <xsl:output-character character="&#xF0B1;" string="&#x0474;" />
        <xsl:output-character character="&#xF0B2;" string="&#x0406;" />
        <xsl:output-character character="&#xF0B3;" string="&#x0456;" />
        <xsl:output-character character="&#xF0B4;" string="&#x0491;" />
        <xsl:output-character character="&#xF0B5;" string="&#x0475;" />
        <xsl:output-character character="&#xF0B6;" string="&#x00B6;" />
        <xsl:output-character character="&#xF0B7;" string="&#x00B7;" />
        <xsl:output-character character="&#xF0B8;" string="&#x0451;" />
        <xsl:output-character character="&#xF0BA;" string="&#x0454;" />
        <xsl:output-character character="&#xF0BB;" string="&#x226B;" />
        <xsl:output-character character="&#xF0BC;" string="&#x0458;" />
        <xsl:output-character character="&#xF0BD;" string="&#x0405;" />
        <xsl:output-character character="&#xF0BE;" string="&#x0455;" />
        <xsl:output-character character="&#xF0BF;" string="&#x0457;" />
        <xsl:output-character character="&#xF089;" string="&#x0466;" />
        <xsl:output-character character="&#xF097;" string="&#x2014;" />
        <xsl:output-character character="&#xF095;" string="&#x00B7;" />
        <xsl:output-character character="&#xF0AD;" string="&#x2013;" />
        <xsl:output-character character="&#xF0B9;" string="&#x2116;" />

        <!-- Alphabet Groß A-Z -->
        <xsl:output-character character="&#xF041;" string="&#x0041;"/>
        <xsl:output-character character="&#xF042;" string="&#x0042;"/>
        <xsl:output-character character="&#xF043;" string="&#x0043;"/>
        <xsl:output-character character="&#xF044;" string="&#x0044;"/>
        <xsl:output-character character="&#xF045;" string="&#x0045;"/>
        <xsl:output-character character="&#xF046;" string="&#x0046;"/>
        <xsl:output-character character="&#xF047;" string="&#x0047;"/>
        <xsl:output-character character="&#xF048;" string="&#x0048;"/>
        <xsl:output-character character="&#xF049;" string="&#x0049;"/>
        <xsl:output-character character="&#xF04A;" string="&#x004A;"/>
        <xsl:output-character character="&#xF04B;" string="&#x004B;"/>
        <xsl:output-character character="&#xF04C;" string="&#x004C;"/>
        <xsl:output-character character="&#xF04D;" string="&#x004D;"/>
        <xsl:output-character character="&#xF04E;" string="&#x004E;"/>
        <xsl:output-character character="&#xF04F;" string="&#x004F;"/>
        <xsl:output-character character="&#xF050;" string="&#x0050;"/>
        <xsl:output-character character="&#xF051;" string="&#x0051;"/>
        <xsl:output-character character="&#xF052;" string="&#x0052;"/>
        <xsl:output-character character="&#xF053;" string="&#x0053;"/>
        <xsl:output-character character="&#xF054;" string="&#x0054;"/>
        <xsl:output-character character="&#xF055;" string="&#x0055;"/>
        <xsl:output-character character="&#xF056;" string="&#x0056;"/>
        <xsl:output-character character="&#xF057;" string="&#x0057;"/>
        <xsl:output-character character="&#xF058;" string="&#x0058;"/>
        <xsl:output-character character="&#xF059;" string="&#x0059;"/>
        <xsl:output-character character="&#xF05A;" string="&#x005A;"/>
        
        <!-- Alphabet klein a-z -->
        <xsl:output-character character="&#xF061;" string="&#x0061;"/>
        <xsl:output-character character="&#xF062;" string="&#x0062;"/>
        <xsl:output-character character="&#xF063;" string="&#x0063;"/>
        <xsl:output-character character="&#xF064;" string="&#x0064;"/>
        <xsl:output-character character="&#xF065;" string="&#x0065;"/>
        <xsl:output-character character="&#xF066;" string="&#x0066;"/>
        <xsl:output-character character="&#xF067;" string="&#x0067;"/>
        <xsl:output-character character="&#xF068;" string="&#x0068;"/>
        <xsl:output-character character="&#xF069;" string="&#x0069;"/>
        <xsl:output-character character="&#xF06A;" string="&#x006A;"/>
        <xsl:output-character character="&#xF06B;" string="&#x006B;"/>
        <xsl:output-character character="&#xF06C;" string="&#x006C;"/>
        <xsl:output-character character="&#xF06D;" string="&#x006D;"/>
        <xsl:output-character character="&#xF06E;" string="&#x006E;"/>
        <xsl:output-character character="&#xF06F;" string="&#x006F;"/>
        <xsl:output-character character="&#xF070;" string="&#x0070;"/>
        <xsl:output-character character="&#xF071;" string="&#x0071;"/>
        <xsl:output-character character="&#xF072;" string="&#x0072;"/>
        <xsl:output-character character="&#xF073;" string="&#x0073;"/>
        <xsl:output-character character="&#xF074;" string="&#x0074;"/>
        <xsl:output-character character="&#xF075;" string="&#x0075;"/>
        <xsl:output-character character="&#xF076;" string="&#x0076;"/>
        <xsl:output-character character="&#xF077;" string="&#x0077;"/>
        <xsl:output-character character="&#xF078;" string="&#x0078;"/>
        <xsl:output-character character="&#xF079;" string="&#x0079;"/>
        <xsl:output-character character="&#xF07A;" string="&#x007A;"/>

        <!-- Kein Ziel, mit REPLACEMENT CHARACTER ersetzen -->
        <xsl:output-character character="&#xF0A0;" string="&#xFFFD;" />
       
        
    </xsl:character-map>
    <xsl:template match="/">      
        <xsl:copy-of select="." />
    </xsl:template>
</xsl:stylesheet>