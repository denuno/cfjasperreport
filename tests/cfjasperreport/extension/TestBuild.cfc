<cfcomponent displayname="TestInstall"  extends="mxunit.framework.TestCase">

	<cffunction name="setUp" returntype="void" access="public">
		<cfset variables.extensionTag = "cfjasperreport" />
		<cfset variables.build = createObject("component","#variables.extensionTag#.extension.install.Build") />
		<cfset variables.extensionzip = "/#variables.extensionTag#/../../dist/#variables.extensionTag#-extension.zip" />
	</cffunction>

	<cffunction name="dumpvar" access="private">
		<cfargument name="var" />
		<cfdump var="#var#" />
		<cfabort />
	</cffunction>

	<cffunction name="testBuild">
		<cfset var buildresults = variables.build.build() />
		<cfset assertEquals(buildresults.errortext,"") />
		<cfset debug(buildresults) />
	</cffunction>

</cfcomponent>
