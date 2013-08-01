<style>
  table { border-collapse: collapse; }
  td { border: 1px solid black;
       padding: 10px;
	 }
  caption { padding 20px; }
  pre { border: 1px solid black;
		padding: 10px;
		background-color: rgba(200, 200, 200, 0.4);
      }
</style>

# XML PROCESSING UTILITIES 2.0

* Table of Conents
{:toc}

## Revision History
TODO: Include all history from older manual.
Latest version updated by Sam Habiel in July 2013.

## Introduction
VISTA XML Processing Utilities cover 4 different domains:
 - XML Parsing
 - XML Querying using XPATH
 - XML Creation tools
 - XML Templating

## XML Parsing
The VistA Extensible Markup Language (XML) Parser is a full-featured, validating XML parser written
in the M programming language and designed to interface with the VistA suite of M-based applications.
It is not a standalone product. Rather, it acts as a server application that can provide XML parsing
capabilities to any client application that subscribes to the application programmer interface (API)
specification detailed in this document.

The VistA XML Parser employs two very different API implementations. The first is an event-driven
interface that is modeled after the widely used Simple API for XML (SAX) interface specification. In
this implementation, a client application provides a special handler for each parsing event of interest.
When the client invokes the parser, it conveys not only the document to be parsed, but also the entry
points for each of its event handlers. As the parser progresses through the document, it invokes the
client’s handlers for each parsing event for which a handler has been registered.

The second API implementation is based on the World Wide Web Consortium (W3C’s) Document Object
Model (DOM) specification. This API, which is actually built on top of the event-driven interface, first
constructs an in-memory model of the fully parsed document. It then provides methods to navigate
through and extract information from the parsed document.

The choice of which API to employ is in part dependent on the needs of the application developer. The
event-driven interface requires the client application to process the document in a strictly top-down
manner. In contrast, the in-memory model provides the ability to move freely throughout the document
and has the added advantage of ensuring that the document is well formed and valid before any
information is returned to the client application.

The VistA XML Parser employs an Entity Catalog to allow storage of external entities such as document
type definitions. The Entity Catalog is a VA FileMan-compatible database and can be manipulated using
the usual VA FileMan tools.

### Term Definitions and XML Parser Concept
To understand the terms used in this documentation and the concept of the operation of an XML Parser,
please review the W3C Architecture Domain website, Extensible Markup Language (XML) page at:
<http://www.w3.org/XML/>.

### Known Issues
The following are known issues in this version of the XML parser. Some of these are due to certain
limitations of the M programming language.

Unlike languages like Java that have multiple character encoding support built-in, M does not recognize
character encodings that do not incorporate the printable ASCII character subset. Thus, 16-bit character
encodings such as Unicode are not supported. Fortunately, a large number of 8-bit character encodings
do incorporate the printable ASCII character subset and can be parsed. Because of this limitation, the
VistA XML Parser will reject any documents with unsupported character encodings.

The current version of the VistA XML Parser does not support retrieval of external entities using the
HTTP or FTP protocols (or for that matter, any protocols other than the standard file access protocols of
the underlying operating system). Client applications using the event-driven interface can intercept
external entity retrieval by the parser and implement support for these protocols if desired.

The parser uses the Kernel function FTG^%ZISH for file access. This function reads the entire contents
of a file into an M global. There are several nuances to this function that manifest themselves in parser
operation:

> Files are opened with a time-out parameter. If an attempt is made to access a non-existent file,
> there is a delay of a few seconds before the error is signaled.

FTG^%ZISH doesn't work on GT.M because of the %ZISH call is non-supported. Instead, the programmer must
load the file into a global first and send that global into the parser.

Files are accessed in text mode. The result is that certain imbedded control characters are stripped from
the input stream and never detected by the parser. Because these control characters are disallowed by
XML, the parser will not report such documents as non-conforming.

> A line feed / carriage return sequence at the end of a document is stripped and not presented to
> the parser. Only in rare circumstances would this be considered significant data, but in the
> strictest sense should be preserved.

The parser allows external entities to contain substitution text that in some cases would violate XML rules
that state that a document must be conforming in the absence of resolving such references. In other
words, XML states that a non-validating parser should be able to verify that a document is conforming
without processing external entities. This restriction constrains how token streams can be continued
across entities. The parser recognizes most, but not all, of these restrictions. The effect is that the parser
is more lax in allowing certain kinds of entity substitutions.

Parsers vary in how they enforce whitespace that is designated as required by the XML specification.
This parser will flag the absence of any required whitespace as a conformance error, even in situations
where the absence of such whitespace would not introduce syntactic ambiguity. The result is that this
parser will reject some documents that may be accepted by other parsers.

### Event-Driven API
The event-driven Application Programmer Interface (API) is based on the well-established Simple API
for XML (SAX) interface employed by many XML parsers. This API, Table 1, has a single method.
(Figure 1 spans two pages.)

#### EN^MXMLPRSE(DOC,CBK,OPT)
<table>
<caption>Table 1: EN^MXMLPRSE—Event-Driven API based on SAX interface</caption>
<tr>
<th>Parameter</th>
<th>Type</th>
<th>Required?</th>
<th>Description</th>
</tr>
<tr>
<td><strong>DOC</strong></td>
<td>String</td>
<td>Yes</td>
<td>This is either a closed reference to a global root
containing the document or a filename and path
reference identifying the document on the host
system. If a global root is passed, the document
must either be stored in standard FileMan word-
processing format or may occur in sequentially
numbered nodes below the root node. Thus, if the
global reference is “^XYZ”, the global must be of one
of the following formats:<br />
<pre>
^XYZ(1,0) = "LINE 1"
^XYZ(2,0) = "LINE 2" ...
</pre>
or<br />
<pre>
^XYZ(1) = "LINE 1"
^XYZ(2) = "LINE 2" ...
</pre>
</td>
</tr>
<tr>
<td>CBK</td>
<td>Local array (by reference)</td>
<td>No</td>
<td>This is a local array, passed by reference that
contains a list of parse events and the entry points
for the handlers of those events. The format for each
entry is:<br />
<pre>
CBK(&lt;event type&gt;) = &lt;entry point&gt;
</pre><br />
The entry point must reference a valid entry point in
an existing M routine and should be of the format
tag^routine. The entry should not contain any formal
parameter references. The application developer is
responsible for ensuring that the actual entry point
contains the appropriate number of formal
parameters for the event type. For example, client
application might register its STARTELEMENT event
handler as follows:<br />
<pre>
CBK(“STARTELEMENT”) = “STELE^CLNT”
</pre>
The actual entry point in the CLNT routine must
include two formal parameters as in the example:<br />
<pre>
STELE(ELE,ATR) &lt;handler code&gt;
</pre>
For the types of supported events and their required
parameters, see the discussion on the pages that
follows.
</td>
</tr>
<tr>
<td>OPT</td>
<td>String</td>
<td>No</td>
<td>This is a list of option flags that control parser
behavior. Recognized option flags are:
<ul>
 <li>W = Do not report warnings to the client.</li>
 <li>V = Validate the document. If not specified, the
  parser only checks for conformance.</li>
 <li>0 = Terminate parsing on encountering a
   warning.</li>
 <li>1 = Terminate parsing on encountering a
	validation error. (By default, the parser
	terminates only when a conformance error is
	encountered.) </li>
</ul>
</td>
</tr>
</table>

#### Event Types Recognized by Vista XML Parser
<table>
<caption>Table 2: Event types recognized by the VISTA XML Parser</caption>
<tr>
<th>Event Type</th>
<th>Parameter(s)</th>
<th>Description</th>
</tr>
<tr>
<td><strong>STARTDOCUMENT</strong></td>
<td>None</td>
<td>Notifies the client that document parsing has commenced.</td>
</tr>
<tr>
<td><strong>ENDDOCUMENT</strong></td>
<td>None</td>
<td>Notifies the client that document parsing has completed.</td>
</tr>
<tr>
<td><strong>DOCTYPE</strong></td>
<td>ROOT <br />
PUBID <br />
SYSID</td>
<td>Notifies the client that a DOCTYPE declaration
has been encountered. The name of the
document root is given by ROOT. The public and
system identifiers of the external document type
definition are given by PUBID and SYSID,
		   respectively.</td>
</tr>
<tr>
	<td><strong>STARTELEMENT</strong></td>
	<td>NAME <br />
	ATTRLIST</td>
	<td>An element (tag) has been encountered. The
	name of the element is given in NAME. The list of
	attributes and their values is provided in the local
	array ATTRLST in the format:

	ATTRLST(&lt;name&gt;) = &lt;value&gt;
	</td>
</tr>
<tr>
	<td><strong>ENDELEMENT</strong></td>
	<td>NAME</td>
	<td>A closing element (tag) has been encountered.
	The name of the element is given in NAME.</td>
</tr>
<tr>
	<td><strong>CHARACTERS</strong></td>
	<td>NAME</td>
	<td>
	Non-markup content has been encountered.
	TEXT contains the text. Line breaks within the
	original document are represented as carriage
	return/line feed character sequences. The parser
	does not necessarily pass an entire line of the
	original document to the client with each event of
	this type.</td>
</tr>
<tr>
	<td><strong>PI</strong></td>
	<td>TARGET<br />
	    TEXT</td>
	<td>The parser has encountered a processing
	instruction. TARGET is the target application for
	the processing instruction. TEXT is a local array
	containing the parameters for the instruction.</td>
</tr>
<tr>
	<td><strong>EXTERNAL</strong></td>
	<td>SYSID<br />
	    PUBID<br />
		GLOBAL</td>
	<td>The parser has encountered an external entity
	reference whose system and public identifiers are
	given by SYSID and PUBID, respectively. If the
	event handler elects to retrieve the entity rather
	than allowing the parser to do so, it should pass
	the global root of the retrieved entity in the
	GLOBAL parameter. If the event handler wishes
	to suppress retrieval of the entity altogether, it
	should set both SYSID and PUBID to null.</td>
</tr>
<tr>
	<td><strong>NOTATION</strong></td>
	<td>NAME<br />
	    SYSID<br />
		PUBIC</td>
	<td>The parser has encountered a notation
	declaration. The notation name is given by
	NAME. The system and public identifiers
	associated with the notation are given by SYSID
	and PUBIC, respectively.</td>
</tr>
<tr>
	<td><strong>COMMENT</strong></td>
	<td>TEXT</td>
	<td>The parser has encountered a comment. TEXT is
	the text of the comment.</td>
</tr>
<tr>
	<td><strong>ERROR</strong></td>
	<td>ERR</td>
	<td>The parser has encountered an error during the
	processing of a document. ERR is a local array
	containing information about the error. The
	format is:
	<ul>
	<li>ERR("SEV") = Severity of the error where 0 is a
	warning, 1 is a validation error, and 2 is a
	conformance error.</li>
	<li>ERR("MSG") = Brief text description of the
	error.</li>
	<li>ERR("ARG") = The token value the triggered
	the error (optional).</li>
	<li>ERR("LIN") = The number of the line being
	processed when the error occurred.</li>
	<li>ERR("POS") = The character position within
	the line where the error occurred.</li>
	<li>ERR("XML") = The original document text of
	the line where the error occurred.</li>
	</ul>
	</td>
</tr>
</table>

A sample client of the event-driven API is provided in the routine MXMLTEST. This routine has an
entry point EN(DOC,OPT), where DOC and OPT are the same parameters as described above in Table 2
for the parser entry point. This sample application simply prints a summary of the parsing events as they
occur.

### In-Memory Document API
This Application Programmer Interface (API) is based on the W3C’s Document Object Model (DOM)
specification. It first builds an “in-memory” image of the fully parsed and validated document and then
provides a set of methods to permit structured traversal of the document and extraction of its contents.
This API is actually layered on top of the event-driven API. In other words, it is actually a client of the
event-driven API that in turn acts as a server to another client application.

The document image is represented internally as a tree with each node in the tree representing an element
instance. Attributes (names and values), non-markup text, and comment text may be associated with any
given node. For example, in Table 3 the XML document on the left is represented by the tree structure on
the right.

<table>
<caption>Table 3: XML document (left) – Tree structure diagram (right)</caption>
<tr>
	<td>
	<pre>
	&lt;top attr1="val1" attr2="val2"&gt;
	&lt;child1&gt;child1 text&lt;/child1&gt;
	&lt;child2&gt;child2 text&gt;&lt;/child2&gt;
	&lt;/top&gt;
	</pre>
	</td>
	<td>
	<strong>top</strong> (attr1 = val1; attr2 = val2)
	<ul>
	<li>Child1 (Child1 text)</li>
	<li>Child2 (Child2 text)</li>
	</ul>
	</td>
</tr>
</table>
	
The supported methods are documented on the pages that follow.

#### $$EN^MXMLDOM(DOC,OPT)
This is the entry point to perform initial processing of the XML document. The client application must
first call this entry point to build the in-memory image of the document before the remaining methods can
be applied. The return value is a handle to the document instance that was created and is used by the
remaining API calls to identify a specific document instance. The parameters for this entry point are
listed in Table 4 by type, requirement (yes or no), and description.
<table>
<caption>Table 4: $$EN^MXMLDOM - Perform inital processing of XML document</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>DOC</td>
	<td>String</td>
	<td>Yes</td>
	<td>Either a closed reference to a global root containing
	the document or a filename and path reference
	identifying the document on the host system. If a
	global root is passed, the document must either be
	stored in standard FileMan word-processing format
	or may occur in sequentially numbered nodes below
	the root node. Thus, if the global reference is
	"^XYZ", the global must be of one of the following
	formats:
	<pre>
	^XYZ(1,0) = "LINE 1"
	^XYZ(2,0) = "LINE 2" ...
	</pre>
	or
	<pre>
	^XYZ(1) = "LINE 1"
	^XYZ(2) = "LINE 2" ...
	</pre>
	</td>
</tr>
<tr>
	<td>OPT</td>
	<td>String</td>
	<td>No</td>
	<td>
		<ul>
			<li> W = Do not report warnings to the client.</li>
			<li> V = Do not validate the document. If specified,
			the parser only checks for conformance.</li>
			<li> 0 = Terminate parsing on encountering a
			warning.</li>
			<li> 1 = Terminate parsing on encountering a validation
			error. (By default, the parser terminates only when a
			conformance error is encountered.)</li>
		</ul>
	</td>
</tr>
<tr>
	<td>Return value</td>
	<td>Integer</td>
	<td>&nbsp;</td>
	<td>Returns a nonzero handle to the document instance
	if parsing completed successfully, or zero otherwise.
	This handle is passed to all other API methods to
	indicate which document instance is being
	referenced. This allows for multiple document
	instances to be processed concurrently.</td>
</tr>
</table>

#### DELETE^MXMLDOM(HANDLE)
This entry point deletes the specified document instance. A client application should always call this entry
point when finished with a document instance. The parameter for this API is listed in Table 5 by type,
requirement (yes or no), and description.

<table>
<caption>Table 5: DELETE^MXMLDOM—Delete specified document instance</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
</table>

#### $$NAME^MXMLDOM(HANDLE,NODE)
This entry point returns the name of the element at the specified node within the document parse tree. The
parameters for this API are listed in Table 6 by type, requirement (yes or no), and description.

<table>
<caption>Table 6: $$NAME^MXMLDOM—Return element name at specified node in document parse tree</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>NODE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node whose associated element name is being
	retrieved.</td>
</tr>
<tr>
	<td>Return value</td>
	<td>String</td>
	<td>The name of the element associated with the
	specified node.</td>
</tr>
</table>

#### $$CHILD^MXMLDOM(HANDLE,PARENT,CHILD)
Returns the node of the first or next child of a given parent node, or 0 if there are none remaining. The
parameters for this API are listed in Table 7 by type, requirement (yes or no), and description.

<table>
<caption>Table 7: $$CHILD^MXMLDOM—Return parent node’s first or next child. 0 if none remaining.</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>PARENT</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node whose children are being retrieved.</td>
</tr>
<tr>
	<td>CHILD</td>
	<td>Integer</td>
	<td>No</td>
	<td>If specified, this is the last child node retrieved. The
	function will return the next child in the list. If the
	parameter is zero or missing, the first child is
	returned.</td>
</tr>
<tr>
	<td>Return Value</td>
	<td>Integer</td>
	<td>&nbsp;</td>
	<td>The next child node or zero if there are none
	remaining.</td>
</tr>
</table>

#### $$SIBLING^MXMLDOM(HANDLE,NODE)
Returns the node of the specified node’s immediate sibling, or 0 if there is none. The parameters for this
API are listed in Table 8 by type, requirement (yes or no), and description.

<table>
<caption>Table 8: $$SIBLING^MXMLDOM—Return specified node’s immediate sibling. 0 if none remaining</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>NODE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node in the document tree whose sibling is
	being retrieved.</td>
</tr>
<tr>
	<td>Return value</td>
	<td>Integer</td>
	<td>&nbsp;</td>
	<td>The node corresponding to the immediate sibling of
	the specified node, or zero if there is none.</td>
</tr>
</table>

#### $$PARENT^MXMLDOM(HANDLE,NODE)
Returns the parent node of the specified node, or 0 if there is none. The parameters for this API are listed
in Table 9 by type, requirement (yes or no), and description.
<table>
<caption>Table 9: $$PARENT^MXMLDOM—Return specified node’s parent node. 0 if none remaining</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>NODE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node in the document tree whose parent is
	being retrieved.</td>
</tr>
<tr>
	<td>Return value</td>
	<td>String</td>
	<td>&nbsp;</td>
	<td>
	 The parent node of the specified node, or zero if there is no parent.
	</td>
</tr>
</table>

#### TEXT^MXMLDOM(HANDLE,NODE,TEXT) or $$TEXT^MXMLDOM(HANDLE,NODE,TEXT)
Extracts non-markup text associated with the specified node. The parameters for this API are listed in
Table 10 by type, requirement (yes or no), and description.

<table>
<caption>Table 10: TEXT^MXMLDOM or $$TEXT^MXMLDOM—Extract specified node’s non-markup text</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>NODE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node in the document tree that is being
	referenced by this call.</td>
</tr>
<tr>
	<td>TEXT</td>
	<td>String</td>
	<td>Yes</td>
	<td>This parameter must contain a closed local or global
	array reference that is to receive the text. The
	specified array is deleted before being populated.</td>
</tr>
<tr>
	<td>Return value</td>
	<td>Boolean</td>
	<td>&nbsp;</td>
	<td>If called as an extrinsic function, the return value is
	true if text was retrieved, or false if not.</td>
</tr>
</table>

#### CMNT^MXMLDOM(HANDLE,NODE,TEXT) or $$CMNT^MXMLDOM(HANDLE,NODE,TEXT)
Extracts comment text associated with the specified node. The parameters for this API are listed in Table
11 by type, requirement (yes or no), and description.
<table>
<caption>Table 11: CMNT^MXMLDOM or $$CMNT^MXMLDOM—Extract specified node’s comment text</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>NODE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node in the document tree that is being
	referenced by this call.</td>
</tr>
<tr>
	<td>TEXT</td>
	<td>String</td>
	<td>Yes</td>
	<td>This parameter must contain a closed local or global
	array reference that is to receive the text. The
	specified array is deleted before being populated.</td>
</tr>
<tr>
	<td>Return value</td>
	<td>Boolean</td>
	<td>&nbsp;</td>
	<td>If called as an extrinsic function, the return value is
	true if text was retrieved, or false if not.</td>
</tr>
</table>

#### $$ATTRIB^MXMLDOM(HANDLE,NODE,ATTRIB)
Retrieves the first or next attribute associated with the specified node. The parameters for this API are
listed in Table 12 by type, requirement (yes or no), and description.

<table>
<caption>Table 12: $$ATTRIB^MXMLDOM—Retrieve specified node’s first or next attribute</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>NODE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node whose attribute name is being retrieved.</td>
</tr>
<tr>
	<td>ATTRIB</td>
	<td>String</td>
	<td>No</td>
	<td>The name of the last attribute retrieved by this call. If
	null or missing, the first attribute associated with the
	specified node is returned. Otherwise, the next
	attribute in the list is returned.</td>
</tr>
<tr>
	<td>Return value</td>
	<td>String</td>
	<td>&nbsp;</td>
	<td>The name of the first or next attribute associated with
	the specified node, or null if there are none
	remaining.</td>
</tr>
</table>

#### $$VALUE^MXMLDOM(HANDLE,NODE,ATTRIB)
Retrieves the value associated with the named attribute. The parameters for this API are listed in Table 13
by type, requirement (yes or no), and description.

<table>
<caption>Table 13: $$VALUE^MXMLDOM—Retrieve value associated with named attribute</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>HANDLE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The value returned by the $$EN^MXMLDOM call that
	created the in-memory document image.</td>
</tr>
<tr>
	<td>NODE</td>
	<td>Integer</td>
	<td>Yes</td>
	<td>The node whose attribute value is being retrieved.</td>
</tr>
<tr>
	<td>ATTRIB</td>
	<td>String</td>
	<td>No</td>
	<td>The name of the attribute whose value is being
	retrieved by this call.</td>
</tr>
<tr>
	<td>Return value</td>
	<td>String</td>
	<td>&nbsp;</td>
	<td>The value associated with the specified attribute.</td>
</tr>
</table>

### VistA XML Parser Usage Example
This is a simple example of how to use the VistA XML Parser with an XML document (file). The XML
file contains a parent node named BOOKS. Nested within that parent node are child nodes named TITLE
and AUTHOR.

Remember the following:

> The parent node is the node whose child nodes are being retrieved.

> The child node, if specified, is the last child node retrieved. The function will return the next child in
> the list. If the parameter is zero or missing, the first child is returned.

#### Create an XML File
*Figure 1: VistA XML Parser Use Example—Create XML File*
<pre>
^TMP($J,1)=&lt;?xml version='1.0'?&gt;
^TMP($J,2)=&lt;!DOCTYPE BOOK&gt;
^TMP($J,3)=&lt;BOOK&gt;
^TMP($J,4)=&lt;TITLE&gt;Design Patterns&lt;/TITLE&gt;
^TMP($J,5)=&lt;AUTHOR&gt;Gamma&lt;/AUTHOR&gt;
^TMP($J,6)=&lt;AUTHOR&gt;Helm&lt;/AUTHOR&gt;
^TMP($J,7)=&lt;AUTHOR&gt;Johnson&lt;/AUTHOR&gt;
^TMP($J,8)=&lt;AUTHOR&gt;Vlissides&lt;/AUTHOR&gt;
^TMP($J,9)=&lt;/BOOK&gt;
</pre>

Invoke Simple API for XML (SAX) Interface

*Figure 2: VistA XML Parser Use Example—Invoke SAX Interface*
<pre>D EN^MXMLTEST($NA(^TMP($J)),"V")&lt;Enter&gt;</pre>

. . . Now see what happens.

Check Document Object Model (DOM) Interface

*Figure 3: VistA XML Parser Use Example—Check DOM Interface*

<pre>
&gt;S HDL=$$EN^MXMLDOM($NA(^TMP($J))) &lt;Enter&gt;

 ; Write name of the first node
&gt;W $$NAME^MXMLDOM(HDL,1) &lt;Enter&gt;
BOOK
 
 ; Get the child of the node
&gt;S CHD=$$CHILD^MXMLDOM(HDL,1) &lt;Enter&gt;
 
 ; Write child name
&gt;W $$NAME^MXMLDOM(HDL,CHD) &lt;Enter&gt;
TITLE
 ;
 ; Get the text of the child.
&gt;W $$TEXT^MXMLDOM(HDL,CHD,$NA(VV)) &lt;Enter&gt;
1
 ;
&gt;ZWRITE VV &lt;Enter&gt;
VV(1)=Design Patterns
</pre>

List All Sibling Nodes

*Figure 4: VistA XML Parser Use Example—List Sibling Nodes*
<pre>
&gt;S CHD=$$CHILD^MXMLDOM(HDL,1) &lt;Enter&gt;
&gt;S SIB=CHD &lt;Enter&gt;
&gt;F S SIB=$$SIBLING^MXMLDOM(HDL,SIB) Q:SIB'&gt;0 W !,SIB,?4,$$NAME^MXMLDOM(HDL,SIB) &lt;Enter&gt;
3 AUTHOR
4 AUTHOR
5 AUTHOR
6 AUTHOR
&gt;
</pre>

## XML Document Creation Utility APIs
These Application Programmer Interfaces (API) have been developed to assist you in creating an XML
document.

### Simple/Singlet XML Building APIs

#### $$XMLHDR^MXMLUTL()
This extrinsic function returns a standard extensible markup language (XML) header for encoding XML
messages. This API is a Supported Reference. Format:
<pre>
$$XMLHDR^MXMLUTL()
</pre>

<table>
<caption>Table 14: $$XMLHDR^MXMLUTL(STR)—Return a standard XML Message Headers</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>Return value</td>
	<td>String</td>
	<td>&nbsp;</td>
	<td>Standard XML header.</td>
</tr>
</table>

Example:
<pre>
&gt;S X=$$XMLHDR^MXMLUTL
&gt;W X
&lt;?xml version="1.0" encoding="utf-8" ?&gt;
</pre>

#### $$SYMENC^MXMLUTL(STR)
This extrinsic function replaces reserved XML symbols in a string with their XML encoding for strings
used in an extensible markup language (XML) message. This API is a Supported Reference. Format:
<pre>
$$SYMENC^MXMLUTL(STR)
</pre>

<table>
<caption>Table 15: $$SYMENC^MXMLUTL(STR)—Encoded Strings in XML Messages</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>STR</td>
	<td>String</td>
	<td>Yes</td>
	<td>String to be encoded in an XML message</td>
</tr>
<tr>
	<td>Return value</td>
	<td>String</td>
	<td>&nbsp;</td>
	<td>The input string with XML encoding replacing reserved XML symbols.</td>
</tr>
</table>

Example:
<pre>
&gt;S X=$$SYMENC^MXMLUTL("This line isn't &amp;""&lt;XML&gt;"" safe as is.")
</pre>

#### $$MKTAG^MXMLBLD(NAME,ATTRS,TEXT,CLOSE)
This extrinsic function creates an XML tag.

<table>
<caption>Table 16: $$MKTAG^MXMLBLD(NAME,ATTRS,TEXT,CLOSE)—Create an XML tag</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>NAME</td>
	<td>String</td>
	<td>Yes</td>
	<td>Name of the xml element to write; or /Name to create a closing tag</td>
</tr>
<tr>
	<td>ATTRS</td>
	<td>Array</td>
	<td>No</td>
	<td>Name Value pair of attributes. If not passed, no attributes are produced.</td>
</tr>
<tr>
	<td>TEXT</td>
	<td>String</td>
	<td>No</td>
	<td>Text to include in the node. If not passed, No text is produced.</td>
</tr>
<tr>
	<td>CLOSE</td>
	<td>Boolean (0 or 1)</td>
	<td>No</td>
	<td>Weather to close the XML tag. If not passed, the default behavior is to close the tag.</td>
</tr>
</table>

Examples:
<pre>
&gt;N %1
&gt;S %1("type")="japaense"
&gt;S %1("origin")="japan"
&gt;W $$MKTAG^MXMLBLD("name",.%1,"Toyoda",1)         ; &lt;name origin="japan" type="japaense"&gt;Toyoda&lt;/name&gt;
&gt;W $$MKTAG^MXMLBLD("name",.%1,"Toyoda")           ; &lt;name origin="japan" type="japaense"&gt;Toyoda&lt;/name&gt;
&gt;W $$MKTAG^MXMLBLD("name",,"Toyoda")              ; &lt;name&gt;Toyoda&lt;/name&gt;
&gt;W $$MKTAG^MXMLBLD("name",.%1)                    ; &lt;name origin="japan" type="japaense" /&gt;
&gt;W $$MKTAG^MXMLBLD("name",.%1,,0)                 ; &lt;name origin="japan" type="japaense"&gt;
&gt;W $$MKTAG^MXMLBLD("/name");                      ; &lt;/name&gt;
</pre>

#### \[$$\]PUT^MXMLBLD(RETURN,STRING)
PUT is a convenience procedure/extrinsic function that adds a line to an array passed by reference.

<table>
<caption>Table 17: [$$]PUT^MXMLBLD - Add a line to an array</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>RETURN</td>
	<td>Array passed by Reference</td>
	<td>Yes</td>
	<td>PUT adds an extra numeric subscript to the end of the array. The value of the subscripted entry is the string</td>
</tr>
<tr>
	<td>STRING</td>
	<td>String</td>
	<td>Yes</td>
	<td>The string that will be the value to add to an array</td>
</tr>
<tr>
	<td>Return value</td>
	<td>Integer</td>
	<td>&nbsp;</td>
	<td>If called with $$, PUT will return the number of new subscript</td>
</tr>
</table>

Example:
<pre>
&gt;N RTN                                                                       
&gt;D PUT^MXMLBLD(.RTN,$$XMLHDR^MXMLUTL())
&gt;D PUT^MXMLBLD(.RTN,$$MKTAG^MXMLBLD("Book",,"Pride and Prejudice"))
&gt;ZWRITE RTN
&gt;RTN(1)="&lt;?xml version=""1.0"" encoding=""utf-8"" ?&gt;"
&gt;RTN(2)="&lt;Book&gt;Pride and Prejudice&lt;/Book&gt;"
</pre>

### Build APIs
This section includes the following calls which together provide a more complex
API but complete API to build an XML document.

<ul>
<li>START^MXMLBLD(DOC,DOCTYPE,FLAG,NO1ST,ATT)</li>
<li>END^MXMLBLD</li>
<li>ITEM^MXMLBLD(INDENT,TAG,ATT,VALUE)</li>
<li>MULTI^MXMLBLD(INDENT,TAG,ATT,DOITEM)</li>
</ul>

#### START^MXMLBLD(DOC,DOCTYPE,FLAG,NO1ST,ATT)
This procedure creates the first element in the doucment and also by default
writes out the XML header and DOCTYPE.

<table>
<caption>Table 18: START^MXMLBLD - Start an XML document</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>DOC</td>
	<td>String</td>
	<td>Yes</td>
	<td>Root element name</td>
</tr>
<tr>
	<td>DOCTYPE</td>
	<td>String</td>
	<td>No</td>
	<td>DOCTYPE reference for the XML document</td>
</tr>
<tr>
	<td>FLAG</td>
	<td>String</td>
	<td>No</td>
	<td>Only supported flag is "G". If not passed, the document builder will 
	print the document as you write it to the current device. If passed, it
	will put the document under ^TMP("MXMLBLD",$J). By default, it's printed
	to the current device.</td>
</tr>
<tr>
	<td>NO1ST</td>
	<td>Boolean (0 or 1)</td>
	<td>No</td>
	<td>If 1 is passed, the &lt;?xml... XML header will not be included. By
	default, it's included.</td>
</tr>
<tr>
	<td>ATT</td>
	<td>Array</td>
	<td>No</td>
	<td>Name value hash in the format ATT("name")="value". If not passed,
	no attributes are added.</td>
</tr>
</table>

#### END^MXMLBLD
This procedure closes the Start Root XML element. It doesn't accept any
parameters.

#### ITEM^MXMLBLD(INDENT,TAG,ATT,VALUE)
This procedure adds an xml element with no child elements, like &lt;Book&gt;
History of Arabia&lt;Book&gt;.

<table>
<caption>Table 19: ITEM^MXMLBLD - Add an element without children</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>INDENT</td>
	<td>Integer</td>
	<td>No</td>
	<td>Number of spaces to indent the item. Can be omitted for no indents.</td>
</tr>
<tr>
	<td>TAG</td>
	<td>Tag name</td>
	<td>Yes</td>
	<td>Element Name</td>
</tr>
<tr>
	<td>ATT</td>
	<td>Array</td>
	<td>No</td>
	<td>Name value hash in the format ATT("name")="value". If not passed,
	no attributes are added.</td>
</tr>
<tr>
	<td>VALUE</td>
	<td>String</td>
	<td>No</td>
	<td>Text to put in the node.</td>
</tr>
</table>

#### MULTI^MXMLBLD(INDENT,TAG,ATT,DOITEM)
This procedure is used to add an element with child elements.

<table>
<caption>Table 20: MULTI^MXMLBLD - Add an element with children</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>INDENT</td>
	<td>Integer</td>
	<td>No</td>
	<td>Number of spaces to indent the item. Can be omitted for no indents.</td>
</tr>
<tr>
	<td>TAG</td>
	<td>Tag name</td>
	<td>Yes</td>
	<td>Element Name</td>
</tr>
<tr>
	<td>ATT</td>
	<td>Array</td>
	<td>No</td>
	<td>Name value hash in the format ATT("name")="value". If not passed,
	no attributes are added.</td>
</tr>
<tr>
	<td>ITEM</td>
	<td>Routine Tag</td>
	<td>Yes</td>
	<td>A entry point that calls ITEM or call MULTI^MXMLBLD recursively.</td>
</tr>
</table>

#### Example
<pre>
TESTBLD1	; Test Wally's XML Builder
	N %1 S %1("version")="2.5"
	D START^MXMLBLD("Books",,"G",,.%1)
	N %1 S %1("type")="date"
	D ITEM^MXMLBLD(,"LastUpdated",.%1,"3-15-99")
	D MULTI^MXMLBLD(,"Book",,"BOOKEAC1")
	D MULTI^MXMLBLD(,"Book",,"BOOKEAC2")
	D END^MXMLBLD
	ZWRITE ^TMP("MXMLBLD",$J,*)
	QUIT
BOOKEAC1	; Book 1
	D ITEM^MXMLBLD(,"Author",,"AUSTEN,JANE")
	D ITEM^MXMLBLD(,"Title",,"PRIDE AND PREJUDICE")
	D ITEM^MXMLBLD(,"Description",,"A romantic novel revealing how pride can cloud our better judgement.")
	Q
BOOKEAC2	; Book 2
	D ITEM^MXMLBLD(,"Author",,"Johann Wolfgang von Goethe")
	D ITEM^MXMLBLD(,"Title",,"Sorrows of Young Werther")
	D ITEM^MXMLBLD(,"Description",,"A tale of unrequited love leading to the demise of the protagonist.")
	Q
</pre>

Expected Output:
<pre>
^TMP("MXMLBLD",5609,1)="&lt;?xml version=""1.0"" encoding=""utf-8"" ?&gt;"
^TMP("MXMLBLD",5609,2)="&lt;Books version=""2.5""&gt;"
^TMP("MXMLBLD",5609,3)="&lt;LastUpdated type=""date""&gt;3-15-99&lt;/LastUpdated&gt;"
^TMP("MXMLBLD",5609,4)="&lt;Book&gt;"
^TMP("MXMLBLD",5609,5)="&lt;Author&gt;AUSTEN,JANE&lt;/Author&gt;"
^TMP("MXMLBLD",5609,6)="&lt;Title&gt;PRIDE AND PREJUDICE&lt;/Title&gt;"
^TMP("MXMLBLD",5609,7)="&lt;Description&gt;A romantic novel revealing how pride can cloud our better judgement.&lt;/Description&gt;"
^TMP("MXMLBLD",5609,8)="&lt;/Book&gt;"
^TMP("MXMLBLD",5609,9)="&lt;Book&gt;"
^TMP("MXMLBLD",5609,10)="&lt;Author&gt;Johann Wolfgang von Goethe&lt;/Author&gt;"
^TMP("MXMLBLD",5609,11)="&lt;Title&gt;Sorrows of Young Werther&lt;/Title&gt;"
^TMP("MXMLBLD",5609,12)="&lt;Description&gt;A tale of unrequited love leading to the demise of the protagonist.&lt;/Description&gt;"
^TMP("MXMLBLD",5609,13)="&lt;/Book&gt;"
^TMP("MXMLBLD",5609,14)="&lt;/Books&gt;"
</pre>

## XML Templating functions
The routine MXMLTMPL and associated routines are reponsible for providing
XML templating functions. You can do the following things with it:
 - Create templates
 - Substitute placeholders in templates at runtime.
 - Insert and remove template XML into other XML.
 - Audit tools to make sure all placeholders have been substituted.

The use case which this routine is best used for is creating XML documents
that have repeating sections that come from VISTA data. For example, a 
medication XML template can be created by hand and then stored in Fileman.
At runtime, each medication's data can be extracted and then the placeholders
substituted with the actual data; then this XML blob can be inserted into a
larger XML document.

*Warning: Because all array names are passed by name, name collision is a 
strong possibility. Make sure that all array names you pass in are namespaced
if you are using local variables!*
 
 Array Creation
 - PUSH^MXMLTMP1(STK,VAL)
 - POP^MXMLTMP1(STK,VAL)
 - QUERY^MXMLTMPL(IARY,XPATH,OARY)
 - CP^MXMLTMPL(CPSRC,CPDEST)
 
 Array Manipulation
 - REPLACE^MXMLTMPL(REXML,RENEW,REXPATH)
 - INSERT^MXMLTMPL(INSXML,INSNEW,INSXPATH)
 - INSINNER^MXMLTMPL(INNXML,INNNEW,INNXPATH)

 Mapping Placeholders
 - MISSING^MXMLTMPL(IXML,OARY)
 - MAP^MXMLTMPL(IXML,INARY,OXML)

 Printing for debugging purposes
 - PARY^MXMLTMPL(GLO,ZN)

 Advanced functionality
 - QUEUE^MXMLTMPL(BLST,ARRAY,FIRST,LAST)
 - BUILD^MXMLTMPL(BLIST,BDEST)

In explanations of how this works, the following XML will be used as reference:
<pre>
1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
2 &lt;Books&gt;
3 &lt;LastUpdated date="@@LASTUP@@" /&gt;
4 &lt;Book&gt;
5 &lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;
6 &lt;Title&gt;@@TITLE@@&lt;/Title&gt;
7 &lt;Description&gt;@@DES@@&lt;/Description&gt;
8 &lt;/Book&gt;
9 &lt;/Books&gt;
</pre>

### Array Creation APIs
#### PUSH^MXMLTMP1(STK,VAL)
Pushes a value VAL to a named array STK (for stack). See examples at the end
of this section.

<table>
<caption>Table 21: PUSH^MXMLTMP1 - Push a value into an array</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>STK</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>The array name in which the value will be stored.</td>
</tr>
<tr>
	<td>VAL</td>
	<td>String</td>
	<td>Yes</td>
	<td>Value to store (string)</td>
</tr>
</table>

#### POP^MXMLTMP1(STK,VAL)
Pops the last pushed item (at the bottom of STK) into VAL.

<table>
<caption>Table 22: POP^MXMLTMP1 - Pop a value from STK to VAL</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>STK</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>The array name in which the value will be retrieved.</td>
</tr>
<tr>
	<td>VAL</td>
	<td>Reference</td>
	<td>Yes</td>
	<td>Variable in which the value will be restored.</td>
</tr>
</table>

Example of Pop:
<pre>
PUSHPOP2 ; Push and Pop
	N KBAN
	D PUSH^MXMLTMP1($NA(KBAN),"Test1")
	D PUSH^MXMLTMP1($NA(KBAN),"Test2")
	N KBANVAL
	D POP^MXMLTMP1($NA(KBAN),.KBANVAL)
	W KBANVAL,! ; Test2
	QUIT
</pre>

#### QUERY^MXMLTMPL(IARY,XPATH,OARY)
This will get you XML associated with an pseudo-XPATH expression from IARY
(Name) into OARY (Name). For example, from the reference XML cited at the
beginning of this section, a pseudo-XPATH of "//Books/Book" returns the
following:
<pre>
&lt;Book&gt;
&lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;
&lt;Title&gt;@@TITLE@@&lt;/Title&gt;
&lt;Description&gt;@@DES@@&lt;/Description&gt;
&lt;/Book&gt;
</pre>

*Warning: This is psuedo-XPATH syntax. It's not real XPATH. See below for
supported syntax*

<table>
<caption>Table 24: QUERY^MXMLTMP1 - Pop a value from STK to VAL</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>IARY</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Input XML array by Name</td>
</tr>
<tr>
	<td>XPATH</td>
	<td>String</td>
	<td>Yes</td>
	<td>Pseudo-XPATH. Only //head-node/child1/child2 is supported.</td>
</tr>
<tr>
	<td>OARY</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Output XML array by Name</td>
</tr>
</table>

#### CP^MXMLTMPL(CPSRC,CPDEST)
This copies an array from CPSRC (Name) to CPDEST (Name). A programmer may use
the merge command instead as it provides the same functionality.

<table>
<caption>Table 25: CP^MXMLTMPL - Copy Arrays</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>CPSRC</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Source Array Name</td>
</tr>
<tr>
	<td>CPDEST</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Destination Array Name</td>
</tr>
</table>

### Array Manipulation APIs
#### REPLACE^MXMLTMPL(REXML,RENEW,REXPATH)
Replaces the XML pointed to by REXPATH in REXML (name) by RENEW.
The last tag in the REXPATH (e.g. c in //a/b/c) is where the replacement
begins. For example, in the example below, a REXPATH of //Books/Book will
replace lines 3 to 5. 

<pre>
1 &lt;?xml ...&gt;
2 &lt;Books&gt;
3 &lt;Book&gt;
4 &lt;Author&gt;Lord Byron&lt;/Author&gt;
5 &lt;/Book&gt;
6 &lt;/Books&gt;
</pre>

If RENEW is empty (""), The INNER XML pointed to XPATH gets deleted. So in the
example above, only line 4 will be deleted.

Examples below in the DEMO program.

<table>
<caption>Table 26: REPLACE^MXMLTMPL - Replace XML in documents</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>REXML</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Original XML array whose contents will be replaced</td>
</tr>
<tr>
	<td>RENEW</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>New contents array to be used for the replacement</td>
</tr>
<tr>
	<td>REXPATH</td>
	<td>String</td>
	<td>Yes</td>
	<td>Psuedo-XPATH point at which to do the replacement. See QUERY above
        for format.</td>
</tr>
</table>

#### INSERT^MXMLTMPL(INSXML,INSNEW,INSXPATH)
Inserts XML in INSNEW in XML of INSXML at the Pseudo-XPATH point. If there are
existing children at the INSXPATH point, the new content is appended after 
the existing children. For an example, see the DEMO program below.

<table>
<caption>Table 27: INSERT^MXMLTMPL - Insert XML in document</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>INSXML</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Original XML array in which new XML will be inserted</td>
</tr>
<tr>
	<td>INSNEW</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>XML to insert</td>
</tr>
<tr>
	<td>INSXPATH</td>
	<td>String</td>
	<td>Yes</td>
	<td>Psuedo-XPATH point at which to do the insertion. See QUERY above
        for format.</td>
</tr>
</table>

#### INSINNER^MXMLTMPL(INNXML,INNNEW,INNXPATH)
Like INSERT^MXMLTMPL, except that only the content inside the main tag of the
XML in INNNEW is inserted into INNXML. For example, if INNNEW has the following
contents:

<pre>
1 &lt;Book&gt;
2 &lt;Author&gt;Lord Byron&lt;/Author&gt;
3 &lt;/Book&gt;
</pre>

Only line 2 gets inserted into the original document INNXML. The outer tags
(lines 1 and 3) are discarded. See examples in the DEMO program below.

<table>
<caption>Table 28: INSINNER^MXMLTMPL - Insert inner XML in document</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>INNXML</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Original XML array in which new XML will be inserted</td>
</tr>
<tr>
	<td>INNNEW</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>XML to insert, from which only the inner XML will be inserted.</td>
</tr>
<tr>
	<td>INNXPATH</td>
	<td>String</td>
	<td>Yes</td>
	<td>Psuedo-XPATH point at which to do the insertion. See QUERY above
        for format.</td>
</tr>
</table>

### Mapping Placeholders
Placeholders are one of the very powerful features of the templating code.
Any item in the XML that is enclosed in @@ (like "@@AUTHOR@@") is a
placeholder.

#### MISSING^MXMLTMPL(IXML,OARY)
This queries IXML for any placeholders that have not been replaced yet (hence
the "Missing") and place the output in a numerically subscripted array OARY. 
See example below in DEMO program.

<table>
<caption>Table 29: MISSING^MXMLTMPL - List unreplaced placeholders</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>IXML</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Input XML</td>
</tr>
<tr>
	<td>OARY</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Output in the format OARY(1)="ITEM1",OARY(2)="ITEM2" etc 
    (@@ removed)</td>
</tr>
</table>

#### MAP^MXMLTMPL(IXML,INARY,OXML)
MAP takes a Mumps Hash in INARY and replaces the hash keys in IXML that
are also placeholders with their value, and puts the output in OXML.

Here's a very simple example:
<pre>
N KBANIXML,KBANINARY,KBANOXML
S KBANIXML(1)="&lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;"
S KBANINARY("AUTHOR")="Lord Byron"
D MAP^MXMLTMPL($NA(KBANIXML),$NA(KBANINARY),$NA(KBANOXML))
W KBANOXML(1),! ; &lt;Author&gt;Lord Byron&lt;/Author&gt;
</pre>

<table>
<caption>Table 30: MAP^MXMLTMPL - Map placeholders using passed Hash</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>IXML</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Input XML containing the placeholders to be filled in</td>
</tr>
<tr>
	<td>INARY</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Hash in the format of MUMPSNAME("KEY")="VALUE". The key corresponds
        to the placeholder text in between the @@</td>
</tr>
<tr>
	<td>OXML</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Output XML produced by this procedure</td>
</tr>
</table>

### Printing for debugging purposes
#### PARY^MXMLTMPL(GLO,ZN)
Prints an array passed by name in GLO. If optional ZN is passed as -1,
line numbers are suppressed. Otherwise, line numbers are printed. See
numerous examples in the DEMO program.
<table>
<caption>Table 31: PARY^MXMLTMPL - Print Array</caption>
<tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Required</th>
	<th>Description</th>
</tr>
<tr>
	<td>GLO</td>
	<td>Mumps Name</td>
	<td>Yes</td>
	<td>Array to be printed. Doesn't have to be an XML array.</td>
</tr>
<tr>
	<td>ZN</td>
	<td>-1</td>
	<td>No</td>
	<td>If -1 is passed, line numbers are not printed; otherwise, line 
    numbers are printed</td>
</tr>
</table>

### Advanced functionality for templating
#### QUEUE^MXMLTMPL(BLST,ARRAY,FIRST,LAST) and BUILD^MXMLTMPL(BLIST,BDEST)
QUEUE and BUILD are to be used together. QUEUE creates build instructions in
BLST for items in ARRAY using FIRST and LAST as the instructions on what
lines to copy. BUILD executes the instructions in BLIST to create an array
in BDEST.

Example (using the reference XML at the beginning of the chapter in array 
MXMLTEMPLATE):

Starting Array:

<pre>
&gt;ZWRITE MXMLTEMPLATE
MXMLTEMPLATE(0)=9
MXMLTEMPLATE(1)="&lt;?xml version=""1.0"" encoding=""utf-8"" ?&gt;"
MXMLTEMPLATE(2)="&lt;Books&gt;"
MXMLTEMPLATE(3)="&lt;LastUpdated date=""@@LASTUP@@"" /&gt;"
MXMLTEMPLATE(4)="&lt;Book&gt;"
MXMLTEMPLATE(5)="&lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;"
MXMLTEMPLATE(6)="&lt;Title&gt;@@TITLE@@&lt;/Title&gt;"
MXMLTEMPLATE(7)="&lt;Description&gt;@@DES@@&lt;/Description&gt;"
MXMLTEMPLATE(8)="&lt;/Book&gt;"
MXMLTEMPLATE(9)="&lt;/Books&gt;"
</pre>

Code:

<pre>
&gt;D QUEUE^MXMLTMPL($NA(MXMLBLIST),$NA(MXMLTEMPLATE),1,2)

&gt;D QUEUE^MXMLTMPL($NA(MXMLBLIST),$NA(MXMLTEMPLATE),4,4)

&gt;D QUEUE^MXMLTMPL($NA(MXMLBLIST),$NA(MXMLTEMPLATE),8,9)

&gt;ZWRITE MXMLBLIST
MXMLBLIST(0)=3
MXMLBLIST(1)="MXMLTEMPLATE;1;2"
MXMLBLIST(2)="MXMLTEMPLATE;4;4"
MXMLBLIST(3)="MXMLTEMPLATE;8;9"

&gt;D BUILD^MXMLTMPL($NA(MXMLBLIST),$NA(MXMLOUTPUT))

&gt;ZWRITE MXMLOUTPUT
MXMLOUTPUT(0)=5
MXMLOUTPUT(1)="&lt;?xml version=""1.0"" encoding=""utf-8"" ?&gt;"
MXMLOUTPUT(2)="&lt;Books&gt;"
MXMLOUTPUT(3)="&lt;Book&gt;"
MXMLOUTPUT(4)="&lt;/Book&gt;"
MXMLOUTPUT(5)="&lt;/Books&gt;"
</pre>

### Demo Program for Templating

<pre>
DEMO	; Demo program.
	;
CREATE ; Create Template
	N MXMLTEMPLATE
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),$$XMLHDR^MXMLUTL())
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;Books&gt;")
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;LastUpdated date=""@@LASTUP@@"" /&gt;")
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;Book&gt;")
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;")
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;Title&gt;@@TITLE@@&lt;/Title&gt;")
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;Description&gt;@@DES@@&lt;/Description&gt;")
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;/Book&gt;")
	D PUSH^MXMLTMP1($NA(MXMLTEMPLATE),"&lt;/Books&gt;")
	;
PARY1 ; Print Array
	W "Printing pushed template",!
	D PARY^MXMLTMPL($NA(MXMLTEMPLATE))
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="@@LASTUP@@" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;
	; 6 &lt;Title&gt;@@TITLE@@&lt;/Title&gt;
	; 7 &lt;Description&gt;@@DES@@&lt;/Description&gt;
	; 8 &lt;/Book&gt;
	; 9 &lt;/Books&gt;
	;
MISS1 ; Print elements needing to be resolved
	N MXMLMISS
	D MISSING^MXMLTMPL($NA(MXMLTEMPLATE),$NA(MXMLMISS))
	;
PARY11 ; Print Array
	W "Printing unresolved placeholder elements",!
	D PARY^MXMLTMPL($NA(MXMLMISS))
	K MXMLMISS
	;
	; 1 LASTUP
	; 2 AUTHOR
	; 3 TITLE
	; 4 DES
	;
MAP1 ; Map the Date
	N DATE S DATE=$$FMTE^XLFDT($$NOW^XLFDT())
	N MXMLHASH S MXMLHASH("LASTUP")=DATE
	K DATE
	;
	N MXMLOUTPUT
	D MAP^MXMLTMPL($NA(MXMLTEMPLATE),$NA(MXMLHASH),$NA(MXMLOUTPUT))
	K MXMLHASH
	;
PARY2 ; Print Array
	W !
	W "Printing template with mapped date",!
	D PARY^MXMLTMPL($NA(MXMLOUTPUT))
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="Aug 01, 2013@10:43:36" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;
	; 6 &lt;Title&gt;@@TITLE@@&lt;/Title&gt;
	; 7 &lt;Description&gt;@@DES@@&lt;/Description&gt;
	; 8 &lt;/Book&gt;
	; 9 &lt;/Books&gt;
	;
	W !
	W "Original: ",!
	D PARY^MXMLTMPL($NA(MXMLTEMPLATE))
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="@@LASTUP@@" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;
	; 6 &lt;Title&gt;@@TITLE@@&lt;/Title&gt;
	; 7 &lt;Description&gt;@@DES@@&lt;/Description&gt;
	; 8 &lt;/Book&gt;
	; 9 &lt;/Books&gt;
	;
SWAP ; Swap the output into the original
	K MXMLTEMPLATE
	M MXMLTEMPLATE=MXMLOUTPUT
	K MXMLOUTPUT
	;
QUERY1 ; Grab the books parts to use as a repeating segment
	N MXMLBOOKSXML
	D QUERY^MXMLTMPL($NA(MXMLTEMPLATE),"//Books/Book",$NA(MXMLBOOKSXML))
	;
PARY3 ; Print Array
	W !,"Printing the Books XML segement",!
	D PARY^MXMLTMPL($NA(MXMLBOOKSXML))
	;
	; 1 &lt;Book&gt;
	; 2 &lt;Author&gt;@@AUTHOR@@&lt;/Author&gt;
	; 3 &lt;Title&gt;@@TITLE@@&lt;/Title&gt;
	; 4 &lt;Description&gt;@@DES@@&lt;/Description&gt;
	; 5 &lt;/Book&gt;
	;
MAP3 ; Make second map
	N MXMLHASH
	S MXMLHASH("AUTHOR")="Lord Byron"
	S MXMLHASH("TITLE")="Don Juan"
	S MXMLHASH("DES")="A swipe at the traditional Don Juan story, the hero goes clueless into various adventures and many romantic conquests"
	N MXMLOUTPUTLB
	D MAP^MXMLTMPL($NA(MXMLBOOKSXML),$NA(MXMLHASH),$NA(MXMLOUTPUTLB))
	K MXMLHASH
	;
PARY4 ; Print Array
	W !,"Printing Mapped Book segment",!
	D PARY^MXMLTMPL($NA(MXMLOUTPUTLB))
	;
	; 1 &lt;Book&gt;
	; 2 &lt;Author&gt;Lord Byron&lt;/Author&gt;
	; 3 &lt;Title&gt;Don Juan&lt;/Title&gt;
	; 4 &lt;Description&gt;A swipe at the traditional Don Juan story, the hero goes clueless into various adventures and many romantic conquests&lt;/
	; Description&gt;
	; 5 &lt;/Book&gt;
	;
REPLACE1 ; Replace the original Books segment with the new segment
	D REPLACE^MXMLTMPL($NA(MXMLTEMPLATE),$NA(MXMLOUTPUTLB),"//Books/Book")
	K MXMLOUTPUT
	;
PARY5 ; Print Array
	W !,"Printing original template after mapped segment is inserted",!
	D PARY^MXMLTMPL($NA(MXMLTEMPLATE))
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="Aug 01, 2013@10:43:36" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;Author&gt;Lord Byron&lt;/Author&gt;
	; 6 &lt;Title&gt;Don Juan&lt;/Title&gt;
	; 7 &lt;Description&gt;A swipe at the traditional Don Juan story, the hero goes clueless into various adventures and many romantic conquests&lt;/
	; Description&gt;
	; 8 &lt;/Book&gt;
	; 9 &lt;/Books&gt;
	;
MAP4 ; Make another book map
	N MXMLHASH
	S MXMLHASH("AUTHOR")="Samuel Butler"
	S MXMLHASH("TITLE")="The way of all Flesh"
	S MXMLHASH("DES")="A semi-autobiographical novel which attacks Victorian-era hypocrisy."
	N MXMLOUTPUTSB
	D MAP^MXMLTMPL($NA(MXMLBOOKSXML),$NA(MXMLHASH),$NA(MXMLOUTPUTSB))
	K MXMLHASH
	;
PARY6 ; Print Array
	W !,"Printing Mapped Book segment",!
	D PARY^MXMLTMPL($NA(MXMLOUTPUTSB))
	;
	; 1 &lt;Book&gt;
	; 2 &lt;Author&gt;Samuel Butler&lt;/Author&gt;
	; 3 &lt;Title&gt;The way of all Flesh&lt;/Title&gt;
	; 4 &lt;Description&gt;A semi-autobiographical novel which attacks Victorian-era hypocrisy.&lt;/Description&gt;
	; 5 &lt;/Book&gt;
	;
INSINN1 ; Insert inner portion of Books XML before the end of the Books section
	D INSINNER^MXMLTMPL($NA(MXMLTEMPLATE),$NA(MXMLOUTPUTSB),"//Books/Book")
	;
PARY7 ; Print Array
	W !,"Printing original template after second mapped section is inserted",!
	D PARY^MXMLTMPL($NA(MXMLTEMPLATE))
	W !,"Incorrect XML produced",!
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="Aug 01, 2013@10:43:36" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;Author&gt;Lord Byron&lt;/Author&gt;
	; 6 &lt;Title&gt;Don Juan&lt;/Title&gt;
	; 7 &lt;Description&gt;A swipe at the traditional Don Juan story, the hero goes clueless into various adventures and many romantic conquests&lt;/
	; Description&gt;
	; 8 &lt;Author&gt;Samuel Butler&lt;/Author&gt;
	; 9 &lt;Title&gt;The way of all Flesh&lt;/Title&gt;
	; 10 &lt;Description&gt;A semi-autobiographical novel which attacks Victorian-era hypocrisy.&lt;/Description&gt;
	; 11 &lt;/Book&gt;
	; 12 &lt;/Books&gt;
	; Incorrect XML produced
	;
DEL1 ; Delete Books section
	D REPLACE^MXMLTMPL($NA(MXMLTEMPLATE),"","//Books/Book")
	;
PARY8 ; Print Array
	W !,"Printing a template without the books section which just got deleted."
	D PARY^MXMLTMPL($NA(MXMLTEMPLATE))
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="Aug 01, 2013@10:43:36" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;/Book&gt;
	; 6 &lt;/Books&gt;
	;
	W !,"Printing both mapped arrays",!
	D PARY^MXMLTMPL($NA(MXMLOUTPUTLB))
	D PARY^MXMLTMPL($NA(MXMLOUTPUTSB))
	;
	; 1 &lt;Book&gt;
	; 2 &lt;Author&gt;Lord Byron&lt;/Author&gt;
	; 3 &lt;Title&gt;Don Juan&lt;/Title&gt;
	; 4 &lt;Description&gt;A swipe at the traditional Don Juan story, the hero goes clueless into various adventures and many romantic conquests&lt;/
	; Description&gt;
	; 5 &lt;/Book&gt;
	; 1 &lt;Book&gt;
	; 2 &lt;Author&gt;Samuel Butler&lt;/Author&gt;
	; 3 &lt;Title&gt;The way of all Flesh&lt;/Title&gt;
	; 4 &lt;Description&gt;A semi-autobiographical novel which attacks Victorian-era hypocrisy.&lt;/Description&gt;
	; 5 &lt;/Book&gt;
	;
INSINN2 ; Insert inner portion of Books XML again of Byron's Don Juan
	D INSINNER^MXMLTMPL($NA(MXMLTEMPLATE),$NA(MXMLOUTPUTLB),"//Books/Book")
	;
PARY9 ; Print Array
	W !!,"Printing template with Don Juan"
	D PARY^MXMLTMPL($NA(MXMLTEMPLATE))
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="Aug 01, 2013@10:43:36" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;Author&gt;Lord Byron&lt;/Author&gt;
	; 6 &lt;Title&gt;Don Juan&lt;/Title&gt;
	; 7 &lt;Description&gt;A swipe at the traditional Don Juan story, the hero goes clueless into various adventures and many romantic conquests&lt;/
	; Description&gt;
	; 8 &lt;/Book&gt;
	; 9 &lt;/Books&gt;
	;
INSERT1 ; Insert all of the Butler's Way of all Flesh into template under Books
	D INSERT^MXMLTMPL($NA(MXMLTEMPLATE),$NA(MXMLOUTPUTSB),"//Books")
	;
PARY0 ; Print Array
	W !!,"Printing template with both books in it"
	D PARY^MXMLTMPL($NA(MXMLTEMPLATE))
	;
	; 1 &lt;?xml version="1.0" encoding="utf-8" ?&gt;
	; 2 &lt;Books&gt;
	; 3 &lt;LastUpdated date="Aug 01, 2013@10:43:36" /&gt;
	; 4 &lt;Book&gt;
	; 5 &lt;Author&gt;Lord Byron&lt;/Author&gt;
	; 6 &lt;Title&gt;Don Juan&lt;/Title&gt;
	; 7 &lt;Description&gt;A swipe at the traditional Don Juan story, the hero goes clueless into various adventures and many romantic conquests&lt;/
	; Description&gt;
	; 8 &lt;/Book&gt;
	; 9 &lt;Book&gt;
	; 10 &lt;Author&gt;Samuel Butler&lt;/Author&gt;
	; 11 &lt;Title&gt;The way of all Flesh&lt;/Title&gt;
	; 12 &lt;Description&gt;A semi-autobiographical novel which attacks Victorian-era hypocrisy.&lt;/Description&gt;
	; 13 &lt;/Book&gt;
	; 14 &lt;/Books&gt;
QUIT QUIT
</pre>

## Entity Catalog
The entity catalog is used to store external entities and their associated public identifiers. When the XML
parser encounters an external entity reference with a public identifier, it first looks for that public
identifier in the entity catalog. If it finds the entity, it retrieves its value. Otherwise, it attempts to
retrieve the entity value using the system identifier. The problem with using system identifiers is that
they often identify resources that may have been relocated since the document was authored. (This is
analogous to the problem with broken links in HTML documents.) Using public identifiers and an entity
catalog allows one to build a collection of commonly used and readily accessible external entities (e.g.,
external document type definitions).

XML ENTITY CATALOG (#950)
The entity catalog is a VA FileMan-compatible file that is very simple in structure:

<table>
<caption>Table 16: XML ENTITY CATALOG file (#950)—Stores external entities and assoc public identifiers</caption>
<tr>
	<th>Field #</th>
	<th>Field Name</th>
	<th>Datatype</th>
	<th>Description</th>
</tr>
<tr>
	<td>.01</td>
	<td>ID</td>
	<td>Free text (1-250)</td>
	<td>The public identifier associated with this entity.</td>
</tr>
<tr>
	<td>1</td>
	<td>VALUE</td>
	<td>Word Processing</td>
	<td>The text associated with the entity.</td>
</tr>
</table>

## Unit Tests
Unit tests are provided in routines 
 - MXMLPATT (for XPATH processing)
 - MXMLBLD (for XML building)
 - MXMLTMPT (for XML templating)

In addition, a manual test routine for the XML Parser is at MXMLTEST.
