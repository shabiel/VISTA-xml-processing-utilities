MXMLDOMT ; VEN/SMH - Unit Tests for DOM Parser;2015-05-25  11:36 AM
 ;;2.4;XML PROCESSING UTILITIES;;June 15, 2015;Build 14
 ;;
 ; (c) Sam Habiel 2014
 ;
 S IO=$P
 N DIQUIET S DIQUIET=1
 D EN^%ut($T(+0),1)
 QUIT
 ;
XML1 ; @TEST - Parse a regular XML Document--sanity test
 D READ("XML1D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^%ut(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML2 ; @TEST - Parse an XML doc on one line
 D READ("XML2D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^%ut(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML3 ; @TEST - Parse an XML doc broken on several lines
 D READ("XML3D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^%ut(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML4 ; @TEST - Parse an XML doc with Character ref attr
 D READ("XML4D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^%ut(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML5 ; @TEST - Parse an XML doc with Chracter ref attr broken over 2 lines (Sergey's bug)
 D READ("XML5D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^%ut(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 QUIT
XML6 ; @TEST - Parse an XML doc with Chracter ref text broken over 2 lines (George's bug)
 D READ("XML6D")
 N D S D=$$EN^MXMLDOM($NA(^TMP($J)),"WD")
 D CHKTF^%ut(D,"XML not parsed")
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
 D CHKTF^%ut(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 ;
 ; Check 2; Supply path explicitly
 N D S D=$$EN^MXMLDOM($$DEFDIR^%ZISH()_"mxmldomt.xml","WD")
 D CHKTF^%ut(D,"XML not parsed")
 D DELETE^MXMLDOM(D)
 ;
 ; Delete file
 N %1 S %1("mxmldomt.xml")=""
 S %=$$DEL^%ZISH($$DEFDIR^%ZISH(),$NA(%1))
 QUIT
XML136 ; @TEST - VA Patch 136 - Long comments are not read properly
 N CB,I,TEST,Y,Z
 K ^TMP($J,"P136 TEST")
 S U="^",TEST="FAILED",Z=0
 F I=1:1 S Y=$T(XML7D+I) Q:$P(Y,";;",2)=""  D
 .I $E(Y,1,3)=" ;;" S Y=$E(Y,4,999),Z=Z+1,^TMP($J,"P136 TEST",Z)=Y Q
 .S Y=$E(Y,2,999),^TMP($J,"P136 TEST",Z)=^TMP($J,"P136 TEST",Z)_Y
 .Q
 S CB("ENDDOCUMENT")="ENDD^MXMLDOMT",Y="^TMP($J,""P136 TEST"")"
 D EN^MXMLPRSE(Y,.CB,"")
 D CHKEQ^%ut(TEST,"PASSED","Long comments are not parsed properly")
 K ^TMP($J,"P136 TEST")
 Q
 ;
XML8 ; @TEST - CRH bug -- testing now
 D READ("XML8D")
 K ^UTILITY($J,"OUT XML")
 M ^UTILITY($J,"OUT XML")=^TMP($J)
 N I,K
 N L F L=1:1:700 D
 . K ^TMP($J,"OUT XML")
 . N BX S BX=0 S I=0 F  S I=$O(^UTILITY($J,"OUT XML",I)) Q:I'>0  F K=0:L:$L(^(I)) S BX=BX+1 S ^TMP($J,"OUT XML",BX)=$E((^UTILITY($J,"OUT XML",I)),K+1,K+L)
 . N D S D=$$EN^MXMLDOM($NA(^TMP($J,"OUT XML")),"W")
 . I 'D W L,! zwrite ^TMP("MXMLERR",$J)
 . D CHKTF^%ut(D,"XML not parsed")
 . D DELETE^MXMLDOM(D)
 K ^UTILITY($J,"OUT XML")
 QUIT
 ;
ENDD ;end of document call back
 ;ZEXCEPT: TEST
 S TEST="PASSED"
 Q
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
XML7D ;; @DATA for Test 7 (VA patch 136)
 ;;<Bloodbank><Patient dfn="990451" firstName="CARPANTS" lastName="BIFF" dob="7720613.000000" ssn="111111111" abo="A " rh="N">
 ;;<TransfusionReactions><TransfusionReaction type="Urticaria" date="3130408.151856" unitId="W040713210843" productTypeName="Thawed
 ;;Apheresis FRESH FROZEN PLASMA" productTypePrintName="FFP AFR Thaw" productCode="E2121V00" comment="On 4/8/13 after transfusion of
 ;;thawed plasma unit #W040713210843 the patient developed a rash and itching.  Th
 ;;e entire unit had been transfused.  There were only minor changes in his VS: T 98.3 to 98.2; HR 56 to 56; BP 119/71 to 132/75 and
 ;;RR 18 to 18.  Blood Bank was notified of a suspected transfusion reaction.  A clerical check revealed no errors; the patient&ap
 ;;os;s posttransfusion plasma was not hemolyzed and his direct antiglobulin tesst (DAT) remained negative.  The patient's symptoms
 ;;and the lack of laboratory findings are most conististent with a mild allergic transfusion reaction.  Such reactions are not uncommon
 ;;and are usually directed to foreign proteins in the transfused plasma to which the recipient is immune.  If future transfusions are
 ;;needed premedication with benadryl may be beneficial."/>
 ;;</TransfusionReactions></Patient></Bloodbank>
 ;;
XML8D ;; @DATA for Test8 (CRH MOCHA bug)
 ;;<?xml version="1.0" encoding="ASCII" standalone="yes"?>
 ;;<PEPSResponse xsi:schemaLocation="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
 ;;   <Header pingOnly="false">
 ;;       <Time value="3170131"/>
 ;;       <MServer namespace="1~/Data/VistA/Training/o(/Data/VistA/Training/r)~/Data/VistA/Training/g/mumps.gld" uci="EHR" ip="10.20.20.40" serverName="NCWHHCHAPAP25" stationNumber="300"></MServer>
 ;;       <MUser userName="THURBER,JOSEPH H" duz="79" jobNumber="23854"></MUser>
 ;;       <PEPSVersion difIssueDate="20170101" difBuildVersion="1.0" difDbVersion="3.2"></PEPSVersion>
 ;;   </Header>
 ;;   <Body>
 ;;        <drugCheck>
 ;;            <drugDrugChecks>
 ;;                <drugDrugCheck>
 ;;                    <id>31757</id>
 ;;                    <source>FDB</source>
 ;;                    <interactedDrugList>
 ;;                        <drug orderNumber="I;0;PROSPECTIVE;1||" ien="507" drugName="LITHIUM CARBONATE 300MG TAB" vuid="4003119" gcnSeqNo="4003"/>
 ;;                        <drug orderNumber="I;347511P;PROFILE;1|849959;1|I" ien="505" drugName="LISINOPRIL 20MG TAB" vuid="4014012" gcnSeqNo="391"/>
 ;;                    </interactedDrugList>
 ;;                    <severity>Severe Interaction</severity>
 ;;                    <interaction><![CDATA[LITHIUM/ACE INHIBITORS; ARBS]]></interaction>
 ;;                    <shortText><![CDATA[LITHIUM CARBONATE 300 MG TABLET and LISINOPRIL 20 MG TABLET may interact based on the potential interaction between LITHIUM and ACE INHIBITORS; ARBS]]></shortText>
 ;;                    <professionalMonograph>
 ;;                        <monographSource>FDB</monographSource>
 ;;                        <disclaimer>This information is generalized and not intended as specific medical advice. Consult your healthcare professional before taking or discontinuing any drug or commencing any course of treatment.</disclaimer>
 ;;                        <monographTitle><![CDATA[MONOGRAPH TITLE:  ACE Inhibitors; ARBs/Lithium]]></monographTitle>
 ;;                        <severityLevel>SEVERITY LEVEL:  2-Severe Interaction: Action is required to reduce the risk of severe adverse interaction.</severityLevel>
 ;;                        <mechanismOfAction>MECHANISM OF ACTION:  Angiotensin converting enzyme inhibitor s (ACEI) or angiotensin II receptor blocker (ARB)-induced sodium loss or volume depletion may result in decreased renal clearance of lithium.(1)</mechanismOfAction>
 ;;                        <clinicalEffects><![CDATA[CLINICAL EFFECTS:  Concurrent use of ACEI or ARBs may result in elevated lithium levels and lithium toxicity. Lithium has a narrow therapeutic range. Unintended increases in lithium concentrations may lead to lithium toxicity.  Early symptoms of lithium toxicity may include: lethargy, muscle weakness or stiffness, new onset or coarsening of hand tremor, vomiting, diarrhea, confusion, ataxia, blurred vision, bradycardia, tinnitus, or nystagmus.  Severe toxicity may produce multiple organ dysfunction (e.g. seizures, coma, renal failure, cardiac arrhythmias, cardiovascular collapse) and may be fatal.(1)]]></clinicalEffects>
 ;;                        <predisposingFactors>PREDISPOSING FACTORS:  Risk factors for lithium toxicity in clude: acute renal impairment, chronic renal disease, dehydration, low sodium diet, and concomitant use of multiple medications which may impair renal elimination of lithium (e.g. ACEI, ARBs, NSAIDs, diuretics).(1)  Patients who require higher therapeutic lithium levels to maintain symptom control are particularly susceptible to these factors.</predisposingFactors>
 ;;                        <patientManagement><![CDATA[PATIENT MANAGEMENT:  If concurrent therapy cannot be avoided, monitor closely.  Evaluate renal function and most recent lithium levels.  If renal function is not stable, when ever possible delay initiation of concurrent therapy until renal function is stable. The onset of lithium toxicity due to concomitant therapy with an ACEI or ARB may be delayed for 3-5 weeks.(2)  Patients receiving this combination should be observed for signs of lithium toxicity when the ACEI or ARB dose is increased or if additional risk factors for lithium toxicity emerge. If an ACEI or ARB is required in a patient stabilized on lithium therapy, check baseline lithium concentration, consider empirically lowering the lithium dose, then recheck lithium levels 5 to 7 days after ACEI or ARB initiation. A djust lithium, ACEI or ARB dose as required and continue frequent (e.g. weekly) monitoring of lithium until levels have stabilized. If lithium is to be started in a patient stabilized on an ACEI or ARB, consider starting with a lower lithium do se and titrate slowly as half-life may be prolonged.(1)  Monitor lithium concentrations frequently until stabilized on the combination. If an interacting drug is discontinued, the lithium level may fall. Monitor lithium concentration and adjust dose if needed.(1) Counsel patient to assure they know signs and symptoms of lithium toxicity and understand the importance of follow-up laboratory testing.]]></patientManagement>
 ;;                        <discussion><![CDATA[DISCUSSION:  Elevated lithium levels and lithium toxicity have been reported during concomitant administration of lithium and an ACEI(3-17) or an ARB(18-20). Other factors, such as dehydration, acute or worsening of chronic renal impairment, or acute changes in sodium intake may increase the occurrence of a clinically important interaction.]]></discussion>
 ;;                        <references>
 ;;                            <reference><![CDATA[REFERENCES:]]></reference>
 ;;                            <reference><![CDATA[1.Lithobid (lithium carbonate) US prescribing information. ANI Pharmaceuticals, Inc. May, 2016.]]></reference>
 ;;                            <reference><![CDATA[2.Finley PR. Drug Interactions with Lithium: An Update. Clin Pharmacokinet 2016 Aug;55(8):925-41.]]></reference>
 ;;                            <reference><![CDATA[3.Douste-Blazy P, Rostin M, Livarek B, Tordjman E, Montastruc JL, Galinier F. Angiotensin converting enzyme inhibitors and lithium treatment. Lancet 1986 Jun 21;1(8495):1448.]]></reference>
 ;;                            <reference><![CDATA[4.Navis GJ, de Jong PE, de Zeeuw D. Volume homeostasis, angiotensin converting enzyme inhibition, and lithium therapy. Am J Med 1989 May; 86(5):621.]]></reference>
 ;;                            <reference><![CDATA[5.Baldwin CM, Safferman AZ. A case of lisinopril-induced lithium toxicity. DICP 1990 Oct;24(10):946-7.]]></reference>
 ;;                            <reference><![CDATA[6.Griffin JH, Hahn SM. Lisinopril-induced lithium toxicity. DICP 1991 Jan; 25(1):101.]]></reference>
 ;;                            <reference><![CDATA[7.Correa FJ, Eiser AR. Angiotensin-converting enzyme inhibitors and lithium toxicity. Am J Med 1992 Jul;93(1):108-9.]]></reference>
 ;;                            <reference><![CDATA[8.DasGupta K, Jefferson JW, Kobak KA, Greist JH. The effect of enalapril on serum lithium levels in healthy men. J Clin Psychiatry 1992 Nov; 53(11):398-400.]]></reference>
 ;;                            <reference><![CDATA[9.Zwanzger P, Marcuse A, Boerner RJ, Walther A, Rupprecht R. Lithium intoxication after administration of AT1 blockers. J Clin Psychiatry 2001 Mar;62(3):208-9.]]></reference>
 ;;                            <reference><![CDATA[10.Meyer JM, Dollarhide A, Tuan IL. Lithium toxicity after switch from fosinopril to lisinopril. Int Clin Psychopharmacol 2005 Mar;20(2):115-8.]]></reference>
 ;;                            <reference><![CDATA[11.Spinewine A, Schoevaerdts D, Mwenge GB, Swine C, DiveA. Drug-induced lithium intoxication: a case report. J Am Geriatr Soc 2005 Feb; 53(2):360-1.]]></reference>
 ;;                            <reference><![CDATA[12.Chandragiri SS, Pasol E, Gallagher RM. Lithium ACE in hibitors, NSAIDs, and verapamil. A possible fatal combination. Psychosomatics 1998 May-Jun; 39(3):281-2.]]></reference>
 ;;                            <reference><![CDATA[14.Alderman CP, Lindsay KS. Increased serum lithium concentration secondary to treatment with tiaprofenic acid and fosinopril. Ann Pharmacother 1996 Dec;30(12):1411-3.]]></reference>
 ;;                            <reference><![CDATA[15.Teitelbaum M. A significant increase in lithium levels after concomitant ACE inhibitor administration. Psychosomatics 1993 Sep-Oct;34(5):450-3.]]></reference>
 ;;                            <reference><![CDATA[16.Drouet A, Bouvet O. Lithium and converting enzyme inhibitors. Encephale 1990 Jan-Feb;16(1):51-2.]]></reference>
 ;;                            <reference><![CDATA[17.Rostin M, Douste-Blazy P, Galinier M, Montastruc JL. Lithium and the converting enzyme inhibitor: a dangerous combination. Presse Med 1988 Jun 11;17(23):1218.]]></reference>
 ;;                            <reference><![CDATA[18.Leung M, Remick RA. Potential drug interaction between lithium and valsartan. J Clin Psychopharmacol 2000 Jun;20(3):392-3.]]></reference>
 ;;                            <reference><![CDATA[19.Blanche P, Raynaud E, Kerob D, Galezowski N. Lithium intoxication in an elderly patient after combined treatment with losartan. Eur J Clin Pharmacol 1997;52(6):501.]]></reference>
 ;;                            <reference><![CDATA[20.Su YP, Chang CJ, Hwang TJ. Lithium intoxication after valsartan treatment. Psychiatry Clin Neurosci 2007 Apr;61(2):204.]]></reference>
 ;;                        </references>
 ;;                    </professionalMonograph>
 ;;                </drugDrugCheck>
 ;;            </drugDrugChecks>
 ;;            <drugTherapyChecks/>
 ;;            <drugDoseChecks/>
 ;;            <drugPrecautionsCheck/>
 ;;            <drugDiseaseCheck/>
 ;;        </drugCheck>
 ;;    </Body>
 ;;</PEPSResponse>
