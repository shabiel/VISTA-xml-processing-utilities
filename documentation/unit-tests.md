In order to run the unit tests, you need the latest version of M-Unit.

This can be found at: <https://github.com/joelivey/M-Unit>.

The unit tests to run are the following:
 - D TEST^MXMLBLD
 - D TEST^MXMLPATT
 - D TEST^MXMLTMPT
 - D ^MXMLDOMT

Pre-installation known failures:

The tests are written to test both existing functionality and the new
functionality which is introduced with this patch.  If run on a system prior to
this patch being installed, it is expected that two tests will fail within the
MXMLDOMT routine.  The relevant part of the test output has been copied below:

  XMLFILE - - Parse an XML document loacated on the File system (Sam's bug)
  XMLFILE^MXMLDOMT - - Parse an XML document loacated on the File system (Sam's bu
  g) - XML not parsed

  XMLFILE^MXMLDOMT - - Parse an XML document loacated on the File system (Sam's bu
  g) - XML not parsed
  -----------------------------------------------------------------------  [FAIL]
	XML9 - - XML Entity Encoder bug .-----------------------------  [FAIL]

After the patch is installed, these failures should not be present.
