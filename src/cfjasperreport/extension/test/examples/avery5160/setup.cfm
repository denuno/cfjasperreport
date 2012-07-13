<cfset dsname = "jasperreport_" & listLast(getDirectoryFromPath(getCurrentTemplatePath()),"\/") />
<cfset dbpath = "#gettempDirectory()#/db/" & dsname />
<cfset result = h2util.createDSN(dsn="#dsname#",path="#dbpath#") />
<cfif !result.status>
	CRAP!  Couldn't create the DSN for this example.  Sorry hombre.
	<cfdump var="#result#">
</cfif>
<cfinclude template="popdb.cfm">