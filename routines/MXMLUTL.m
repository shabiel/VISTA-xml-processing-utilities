MXMLUTL ;mjk/alb - MXML Build Utilities ;2018-05-30  11:46 AM
 ;;2.6;XML PROCESSING UTILITIES;;May 30, 2018;Build 16
 ; Original routine authored by Department of Veterans Affairs 2002
 QUIT
 ;
XMLHDR() ; -- provides current XML standard header 
 QUIT "<?xml version=""1.0"" encoding=""utf-8"" ?>"
 ;
SYMENC(STR) ; -- replace reserved xml symbols with their encoding.
 N A,I,X,Y,Z,NEWSTR,QT
 S (Y,Z)="",QT=""""
 I STR["&" S NEWSTR=STR D  S STR=Y_Z
 . F X=1:1  S Y=Y_$PIECE(NEWSTR,"&",X)_"&amp;",Z=$PIECE(STR,"&",X+1,99999) Q:Z'["&"
 I STR["<" F  S STR=$PIECE(STR,"<",1)_"&lt;"_$PIECE(STR,"<",2,99999) Q:STR'["<"
 I STR[">" F  S STR=$PIECE(STR,">",1)_"&gt;"_$PIECE(STR,">",2,99999) Q:STR'[">"
 I STR["'" F  S STR=$PIECE(STR,"'",1)_"&apos;"_$PIECE(STR,"'",2,99999) Q:STR'["'"
 I STR[QT F  S STR=$PIECE(STR,QT,1)_"&quot;"_$PIECE(STR,QT,2,99999) Q:STR'[QT
 ;
 ; This algo is new in v2.6.
 ; See https://groups.google.com/d/msg/Hardhats/s2uKhnmVPcM/ep9FWNELBgAJ for details
 N CTRLS,II
 S CTRLS="" F II=0:1:31,127 S CTRLS=CTRLS_$C(II)
 Q $TR(STR,CTRLS)
