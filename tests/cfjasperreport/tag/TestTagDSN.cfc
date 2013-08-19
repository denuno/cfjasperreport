<cfcomponent displayname="TestInstall"  extends="mxunit.framework.TestCase">

	<cfimport taglib="/cfjasperreport/tag/cfjasperreport" prefix="jr" />

	<cffunction name="beforeTests" returntype="void" access="public">
		<cfset workpath = "#getDirectoryFromPath(getMetadata(this).path)#../../data/work" />
		<cftry>
			<cfset directoryDelete(workpath,true) />
			<cfcatch></cfcatch>
		</cftry>
		<cfset directoryCreate(workpath) />
	</cffunction>

	<cffunction name="setUp" returntype="void" access="public">
		<cfset datapath = "#getDirectoryFromPath(getMetadata(this).path)#../../data" />
		<cfset workpath = "#getDirectoryFromPath(getMetadata(this).path)#../../data/work" />
		<cfset dbpath = datapath & "/db/jasperreport" />
		<cfset variables.h2util = createObject("component","H2Util").init(cfadminpassword="testtest") />
		<cftry>
			<cfquery datasource="jasperreport">SELECT count(*) FROM employee</cfquery>
			<cfcatch>
				<cfset debug(variables.h2util.createDSN(dsn="jasperreport",path="#dbpath#"))/>
				<cfset dsname = "jasperreport" />
				<cfinclude template="popdb.cfm" />
			</cfcatch>
		</cftry>
 	</cffunction>

	<cffunction name="teardown" returntype="void" access="public">
<!---
		<cfset variables.h2util.removeDSN(dsn="jasperreport",path="#dbpath#")/>
 --->
	</cffunction>

	<cffunction name="testjasperreportsFileNotFound">
<!---
h2 issue of super slow
	<cfset tc = getTickCount()>
		<cfset request.debug("<p>line #getCurrentContext()[1].line# in #getTickCount() - tc#	ms")>
		<cfset datapath = "#getDirectoryFromPath(getMetadata(this).path)#../../data" />
		<cfset workpath = "#getDirectoryFromPath(getMetadata(this).path)#../../data/work" />
		<cfset dbpath = datapath & "/db/jasperreport" />
		<cfset variables.h2util = createObject("component","H2Util").init(cfadminpassword="testtest") />
		<cfset debug(variables.h2util.createDSN(dsn="jasperreport",path="#dbpath#"))/>

		<cfset request.debug("<p>line #getCurrentContext()[1].line# in #getTickCount() - tc#	ms")>
	<cfset doCreateTable = true>	<!--- change to false to skip table creation --->
	<cfif doCreateTable>
		<cfquery name="qCreateTable" datasource="jasperreport">
			CREATE TABLE IF NOT EXISTS		Test (
				ID		VARCHAR NOT NULL,
				TIME	TIMESTAMP NOT NULL
			);
		</cfquery>
		<cfset request.debug("<p>line #getCurrentContext()[1].line# in #getTickCount() - tc#	ms")>
		<cfset tc = getTickCount()>
	</cfif>
	<cfquery name="qCreateTable" datasource="jasperreport">
		INSERT INTO	Test( ID, TIME )
		SELECT	'#CreateUUID()#', #createOdbcDateTime( now() )#;
	</cfquery>
	<cfset request.debug("<p>line #getCurrentContext()[1].line# in #getTickCount() - tc# ms")>
	<cfset tc = getTickCount()>
	<cfquery name="qSelect" datasource="jasperreport">
		SELECT	*
		FROM	TEST
	</cfquery>
	<cfset request.debug("<p>line #getCurrentContext()[1].line# in #getTickCount() - tc# ms")>
	<cfset tc = getTickCount()>
	<cfquery name="qSelect" datasource="jasperreport">
		SELECT	*
		FROM	TEST
	</cfquery>
	<cfset request.debug("<p>line #getCurrentContext()[1].line# in #getTickCount() - tc# ms")>

<cfthrow message="fart">


 --->
		<cftry>
			<jr:jasperreport jrxml="#datapath#/not-here.jrxml" dsn="jasperreport" exportfile="#workpath#/idcards-dsn.pdf" exporttype="pdf"/>
			<cfcatch>
				<cfset assertEquals("cfjasperreport.filenotfound",cfcatch.type)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="testjasperreportsTagIdCardsWithImgLinksPdf">
		<cfsetting requesttimeout="120">
		<cfset params = {imagepath:"#datapath#/logo.jpg",imageurl:"#cgi.http_host#/tests/data/images/avatars/1.jpg"} />
		<jr:jasperreport jrxml="#datapath#/idcards-dsn.jrxml" dsn="jasperreport" exportfile="#workpath#/idcards-dsn.pdf" params="#params#" exporttype="pdf"/>
	</cffunction>

	<cffunction name="testjasperreportsTagPdf">
		<jr:jasperreport jrxml="#datapath#/test.jrxml" exportfile="#workpath#/rockn.pdf" dsn="jasperreport" exporttype="pdf"/>
	</cffunction>

	<cffunction name="testjasperreportsTagAvery5160Pdf">
		<jr:jasperreport jrxml="#datapath#/avery5160.jrxml" exportfile="#workpath#/avery5160.pdf" exporttype="pdf" dsn="jasperreport"/>
	</cffunction>

	<cffunction name="testjasperreportsTagBarcodePdf">
		<jr:jasperreport jrxml="#datapath#/barcode.jrxml" exportfile="#workpath#/barcode.pdf" exporttype="pdf" dsn="jasperreport"/>
	</cffunction>

	<cffunction name="testjasperreportsTagXls">
		<jr:jasperreport jrxml="#datapath#/test.jrxml" dsn="jasperreport" exportfile="#workpath#/rockn.xls" exporttype="xls"/>
	</cffunction>

	<cffunction name="testjasperreportsWithChartDSN">
		<jr:jasperreport jrxml="#datapath#/test.jrxml" exportfile="#workpath#/rockn.pdf" exporttype="pdf" dsn="jasperreport"/>
	</cffunction>

</cfcomponent>
