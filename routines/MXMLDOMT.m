MXMLDOMT ; VEN/SMH - Unit Tests for DOM Parser;2013-11-27  2:15 PM
 ;;
 ;
 S IO=$P
 N DIQUIET S DIQUIET=1
 D EN^XTMUNIT($T(+0),1)
 QUIT
 ;
XML1 ; @TEST - Parse a regular XML Document--sanity test
 D READ("XML1D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML2 ; @TEST - Parse an XML doc on one line
 D READ("XML2D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML3 ; @TEST - Parse an XML doc broken on several lines
 D READ("XML3D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML4 ; @TEST - Parse an XML doc with Character ref attr
 D READ("XML4D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML5 ; @TEST - Parse an XML doc with Chracter ref attr broken over 2 lines (Sergey's bug)
 D READ("XML5D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML6 ; @TEST - Parse an XML doc with Chracter ref text broken over 2 lines (George's bug)
 D READ("XML6D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XMLFILE ; @TEST - Parse an XML document loacated on the File system (Sam's bug)
 D READ("XML1D")
 ;
 ; Write file
 N % S %=$$GTF^%ZISH($NA(^TMP($J,1)),2,$$DEFDIR^%ZISH(),"mxmldomt.xml")
 I '% S $EC=",U-FILE-WRITE-FAIL,"
 ;
 ; Check 1: No path supplied. System supposed to use default directory
 N D S D=$$EN^MXMLDOM("mxmldomt.xml","WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 ;
 ; Check 2; Supply path explicitly
 N D S D=$$EN^MXMLDOM($$DEFDIR^%ZISH()_"mxmldomt.xml","WD")
 D CHKTF^XTMUNIT(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 ;
 ; Delete file
 N %1 S %1("mxmldomt.xml")=""
 S %=$$DEL^%ZISH($$DEFDIR^%ZISH(),$NA(%1))
 QUIT
READ(TAGNAME) ; Read XML from tag
 K ^TMP($J)
 N LN
 N I F I=1:1 S LN=$P($T(@TAGNAME+I),";;",2) Q:'$L(LN)  S ^TMP($J,I)=LN
 QUIT
 ;
XML1D ;; @DATA for Test 1
 ;;<?xml version="1.0" encoding="utf-8"?>
 ;;<!-- Edited by XMLSpy -->
 ;;<note>
 ;;<to>Tove</to>
 ;;<from>Jani</from>
 ;;<heading>Reminder</heading>
 ;;<body>Don't forget me this weekend!</body>
 ;;</note>
 ;;
XML2D ;; @DATA for Test 2
 ;;<?xml version="1.0" encoding="utf-8"?><!-- Edited by XMLSpy --><note><to>Tove</to><from>Jani</from><heading>Reminder</heading><body>Don't forget me this weekend!</body></note>
 ;;
XML3D ;; @DATA for Test 3
 ;;<?xml version="1.0" 
 ;;encoding="utf-8"?>
 ;;<!-- Edited b
 ;;y XMLSpy -->
 ;;<not
 ;;e>
 ;;<to>Tove<
 ;;/to>
 ;;<from>Jani</from>
 ;;<heading>Reminder</heading>
 ;;<body>Don't forget me this weekend!</
 ;;body>
 ;;</note>
 ;;
XML4D ;; @DATA for Test 4
 ;;<?xml version="1.0" encoding="utf-8"?>
 ;;<!-- Edited by XMLSpy -->
 ;;<note>
 ;;<to lastname="M&#xfc;ller">Tove</to>
 ;;<from>Jani</from>
 ;;<heading>Reminder</heading>
 ;;<body>Don't forget me this weekend!</body>
 ;;</note>
 ;;
XML5D ;; @DATA for Test 5 (Sergey's bug!)
 ;;<?xml version="1.0" encoding="utf-8"?>
 ;;<!-- Edited by XMLSpy -->
 ;;<note>
 ;;<!-- Overflow the main buffer -->
 ;;<subject>AAAAAAAAAAAAAAAAAAAAAAAAAAAA</subject><to lastnameAAAAAAAAAAAAAAAAA="M&#
 ;;xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#x
 ;;fc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#
 ;;xfc;ller">Tove</to>
 ;;<from>Jani</from>
 ;;<heading>Reminder</heading>
 ;;<body>Don't forget me this weekend!</body>
 ;;</note>
 ;;
XML6D ;; @DATA for Test 6 (George's bug!)
 ;;<?xml version="1.0" encoding="utf-8"?>
 ;;<!-- Edited by XMLSpy -->
 ;;<note>
 ;;<!-- Overflow the main buffer -->
 ;;<subject>AAAAAAAAAAAAAAAAAAAAAAAAAAAA</subject>
 ;;<to>Tove&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#
 ;;xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&
 ;;#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xf
 ;;c;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;&#xfc;</to>
 ;;<from>Jani</from>
 ;;<heading>Reminder</heading>
 ;;<body>Don't forget me this weekend!</body>
 ;;</note>
 ;;
