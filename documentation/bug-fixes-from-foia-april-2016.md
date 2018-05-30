# Bug fixes to VA VISTA in the VISTA XML PROCESSING UTILITIES package.

Both bug fixes are in routine MXMLPRSE. There are no other changes to the VISTA MXML\* routines. The rest are additions.

 1. HTML entities (anything starting with #) don't have enough read ahead to decipher the whole thing.
 2. $$FTG^%ZISH used a form where the PATH and the FILENAME were concatenated. This is not officially supported by the Kernel; and thus didn't work on GT.M. The %ZISH call was changed so that it chopped the full path-filename if supplied into a path and a filename seperately.

See entire diff below.

 \< is my version.
 
 \> is the VA version.
 

```
146d144
<  I CPOS+10>LLEN D READ  ; VEN/SMH v2.1 - Read ahead for Entity if not enough in XML buffer.
255,259c253,254
<  ; S:$$PATH(SYS)="" SYS=PATH_SYS /VEN/SMH 2.1 commented out
<  N FILENAME
<  I $L(PATH) S FILENAME=$P(SYS,PATH,2,99) ; VEN/SMH 2.1 (path supplied)
<  E  S FILENAME=SYS ; VEN/SMH 2.1 (no path supplied)
<  S X=$S($$FTG^%ZISH(PATH,FILENAME,$NA(@GBL@(1)),$QL(GBL)+1):GBL,1:"") ; VEN/SMH 2.1
---
>  S:$$PATH(SYS)="" SYS=PATH_SYS
>  S X=$S($$FTG^%ZISH(SYS,"",$NA(@GBL@(1)),$QL(GBL)+1):GBL,1:"")
1,3c1,2
```

# Enhancements to VA Code
What is new:
 
 1. XML Creation Tools
 > * Routine: MXMLBLD
 2. XML Querying using XPATH (XPATH section in the html documentation)
 > * Routine: MXLPATH
 3. XML Templating functions (Templating section in the html documentation)
 > * Routine: MXMLTMP1
 > * Routine: MXMLTMPL
 4. Unit tests
 > * Routine: MXLMDOMT (Unit test for DOM Parser)
 > * Routine: MXLPATT (Unit test for XPATH processing)
 > * Routine: MXMLTMPT (Unit test for XML templating)
