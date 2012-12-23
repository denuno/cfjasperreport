<cfcomponent>

	<cffunction name="standardInstall" output="false">
		<cfargument name="error" type="struct" />
		<cfargument name="path" type="string" />
		<cfargument name="config" type="struct" />
		<cfset var defaultstandards = "jars,tags,plugins,functions,cdrivers" />
		<cfset var standards = "" />
		<cfdirectory action="list" directory="#path#" name="files">
		<cfloop query="files">
			<cfif listFindNoCase(defaultstandards,listFirst(name,"."))>
				<cfset standards = listAppend(standards,lcase(listFirst(name,"."))) />
			</cfif>
		</cfloop>
		<cfif find("jars",standards)>
			<cfset addJars(error,"#path#/jars",arguments.config) />
		</cfif>
		<cfset config.isBuiltInTag=config.isBuiltInTag EQ "true" />
		<cfset config.installTestPlugin=config.installTestPlugin EQ "true" />
		<cfif find("tags",standards)>
			<cfif config.isBuiltInTag>
				<cfset cfcext = '<cfcomponent extends="#variables.extensionTag#/cfc/#rereplace(variables.extensionTag,"^cf","")#"></cfcomponent>' />
				<cffile action="write" file="#getLibraryPath()#/tag/#rereplace(variables.extensionTag,'^cf','')#.cfc" output="#cfcext#" />
				<cfset dirCopy("#path#/tags","#getLibraryPath()#/tag")>
				<cfset addCustomTagsMapping("#getLibraryPath()#/tag/#variables.extensionTag#") />
			<cfelse>
				<cfset dirCopy("#path#/tags","#getLibraryPath()#/../customtags/")>
				<cfset addCustomTagsMapping("#getLibraryPath()#/../customtags/#variables.extensionTag#") />
			</cfif>
		</cfif>
		<cfif find("functions",standards)>
			<cfset dirCopy("#path#/functions","#getLibraryPath()#/function")>
		</cfif>
		<cfif find("plugins",standards)>
			<cfset dirCopy("#path#/plugins",getPluginDir())>
		</cfif>
		<cfif find("cdrivers",standards)>
			<cfset dirCopy("#path#/cdrivers",getCacheDriverDir())>
		</cfif>
		<cfif directoryExists(getDirectoryFromPath(getMetadata(this).path)&"test")>
			<cfif config.installTestPlugin>
				<cfset addTestPlugin(getDirectoryFromPath(getMetadata(this).path)&"test/test.cfm",config.isBuiltInTag) />
			<cfelse>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="standardUnInstall" output="false">
		<cfargument name="path" type="string" />
		<cfargument name="config" type="struct" />
		<cfset var defaultstandards = "jars,tags,plugins,functions,cdrivers,applications" />
		<cfset var standards = "" />
		<cfset var errors=array() />
		<cfdirectory action="list" directory="#path#" name="files">
		<cfloop query="files">
			<cfif listFindNoCase(defaultstandards,listFirst(name,"."))>
				<cfset standards = listAppend(standards,lcase(listFirst(name,"."))) />
			</cfif>
		</cfloop>
		<cftry>
			<cfif find("jars",standards)>
				<cfset removeJars(structNew(),"#path#/jars",arguments.config) />
				<cfdirectory action="delete" directory="#path#/jars" recurse="true">
			</cfif>
			<cfif find("tags",standards)>
				<cfset config.isBuiltInTag=config.isBuiltInTag EQ "true" />
				<cfif config.isBuiltInTag>
					<cfdirectory action="list" name="tags" directory="#path#/tags" recurse="false">
					<cfloop query="tags">
						<cfif type eq "dir">
							<cfdirectory directory="#getLibraryPath()#/tag/#name#" action="delete" recurse="yes">
							<cftry><cffile action="delete" file="#getLibraryPath()#/tag/#rereplace(variables.extensionTag,'^cf','')#.cfc"><cfcatch></cfcatch>
							</cftry>
							<cftry><cffile action="delete" file="#getLibraryPath()#/tag/#rereplace(variables.extensionTag,'^cf','')#.cfm"><cfcatch></cfcatch>
							</cftry>
						<cfelse>
							<cffile action="delete" file="#getLibraryPath()#/tag/#name#">
						</cfif>
					</cfloop>
					<cfset removeCustomTagsMapping("#getLibraryPath()#/tag/#variables.extensionTag#") />
				<cfelse>
					<cfset removeCustomTagsMapping("#getLibraryPath()#/../customtags/#variables.extensionTag#") />
					<cfdirectory directory="#getLibraryPath()#/../customtags/#variables.extensionTag#" action="delete" recurse="yes">
				</cfif>
			</cfif>
			<cfif find("functions",standards)>
				<cfdirectory action="list" name="functions" directory="#path#/functions" recurse="false">
				<cfloop query="functions">
					<cfif type eq "dir">
						<cfdirectory directory="#getLibraryPath()#/function/#name#" action="delete" recurse="yes">
					<cfelse>
						<cffile action="delete" file="#getLibraryPath()#/function/#name#">
					</cfif>
				</cfloop>
			</cfif>
			<cfif find("plugins",standards)>
				<cfdirectory action="list" name="plugins" directory="#path#/plugins" recurse="false">
				<cfloop query="plugins">
					<cfdirectory action="delete" recurse="true" directory="#getPluginDir()#/#name#" />
				</cfloop>
			</cfif>
			<cfcatch>
				<cfset ArrayAppend(errors,cfcatch) />
			</cfcatch>
		</cftry>
		<cfif arrayLen(errors) EQ 1>
			<cfthrow object="#errors[1]#" />
		<cfelseif arrayLen(errors) GT 1>
			<cfset var message="" />
			<cfset var error="" />
			<cfloop array="#errors#" index="error">
				<cfset message&=error.message&chr(13)&chr(10) />
			</cfloop>
			<cfthrow message="#message#" />
		</cfif>
	</cffunction>

	<cffunction name="addJars" returntype="string" output="no"
		hint="called from Railo to install application">
		<cfargument name="error" type="struct" />
		<cfargument name="path" type="string" />
		<cfset dirCopy(path,"#getLibraryPath()#/../lib")>
		<!---
		<cfdirectory action="list" name="qJars" directory="#path#" filter="*.jar" sort="name desc"/>
		<cfsetting requesttimeout="360" />
		<cfloop query="qJars">
			<cfadmin action="updateJar" type="#request.adminType#" password="#session["password"&request.adminType]#" jar="#path#/#name#" />
		</cfloop>
		<cftry>
			<cfadmin action="updateJar" type="#request.adminType#" password="#session["password"&request.adminType]#" jar="#path#/defaults.properties" />
			<cfcatch>
			</cfcatch>
		</cftry>
			<cfset request.debug(qJars)>
			<cfset request.debug(path)>
			--->
	</cffunction>

	<cffunction name="removeJars" returntype="string" output="no"
		hint="called from Railo to install application">
		<cfargument name="error" type="struct" />
		<cfargument name="path" type="string" />
		<cfdirectory action="list" name="qJars" directory="#path#" filter="*.jar" sort="name desc"/>
		<cfsetting requesttimeout="360" />
		<cfloop query="qJars">
			<cfadmin action="removeJar" type="#request.adminType#" password="#session["password"&request.adminType]#" jar="#path#/#name#" />
		</cfloop>
	</cffunction>

	<cffunction name="addCustomTagsMapping" output="false">
		<cfargument name="physicalPath" />
		<cfadmin action="getCustomTagMappings" returnVariable="customtagMappings" type="#request.adminType#" password="#session["password"&request.adminType]#" />
		<cfquery name="isAlreadyMapped" dbtype="query">
			SELECT * FROM customtagMappings WHERE strphysical =
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.physicalPath#" />
		</cfquery>
		<cfif NOT isAlreadyMapped.recordcount>
			<cfadmin action="updatecustomtag" archive="false" primary="false" trusted="false" virtual="#arguments.physicalPath#" physical="#arguments.physicalPath#" type="#request.adminType#" password="#session["password"&request.adminType]#" />
		<cfelse>
			<cfthrow type="#variables.extensionTag#.mappingsThereDude" detail="'#arguments.physicalPath#' has already been mapped as a custom tag directory" />
		</cfif>
		<cfadmin action="reload" type="#request.adminType#" password="#session["password"&request.adminType]#" />
		<cfreturn />
	</cffunction>

	<cffunction name="removeCustomTagsMapping" output="false">
		<cfargument name="physicalPath" />
		<cfadmin action="getCustomTagMappings" returnVariable="customtagMappings" type="#request.adminType#" password="#session["password"&request.adminType]#" />
		<cfquery name="isAlreadyMapped" dbtype="query">
			SELECT * FROM customtagMappings WHERE strphysical =
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.physicalPath#" />
		</cfquery>
		<cfif isAlreadyMapped.recordcount>
			<cfadmin action="removecustomtag" physical="#arguments.physicalPath#" virtual="#isAlreadyMapped.virtual#" type="#request.adminType#" password="#session["password"&request.adminType]#" />
		<cfelse>
			<cfthrow type="#variables.extensionTag#.noMappingToRemove" detail="no mapping for path: #arguments.physicalPath#" />
		</cfif>
		<cfadmin action="reload" type="#request.adminType#" password="#session["password"&request.adminType]#" /> <cfadmin action="getCustomTagMappings" returnVariable="customtagMappings" type="#request.adminType#" password="#session["password"&request.adminType]#" />
		<cfquery name="isAlreadyMapped" dbtype="query">
			SELECT * FROM customtagMappings WHERE strphysical =
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.physicalPath#" />
		</cfquery>
		<cfif isAlreadyMapped.recordcount>
			<cfthrow type="#variables.extensionTag#.mappingStillThereBro" detail="something is fscked up, mapping still exists!" />
		</cfif>
	</cffunction>

	<cffunction name="getLibraryPath" access="public" returntype="string">
		<cfswitch expression="#request.adminType#">
			<cfcase value="web">
				<cfreturn expandPath('{railo-web}/library') />
			</cfcase>
			<cfcase value="server">
				<cfreturn expandPath('{railo-server}/library') />
			</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getPluginDir" access="public" output="false">
		<cfset var pluginDir = "" />
		<cfadmin action="getPluginDirectory" type="#request.adminType#" password="#session["password"&request.adminType]#" returnVariable="pluginDir">
		<cfif NOT directoryExists(pluginDir)>
			<cfdirectory action="create" directory="#pluginDir#" recurse="true" />
		</cfif>
		<cfreturn pluginDir />
	</cffunction>

	<cffunction name="getCacheDriverDir" access="private" output="false">
		<cfset var cacheDriverDir = "" />
		<cfadmin action="getPluginDirectory" type="#request.adminType#" password="#session["password"&request.adminType]#" returnVariable="cacheDriverDir">
		<cfset cacheDriverDir = listDeleteAt(cacheDriverDir,listLen(cacheDriverDir,"/"),"/") & "/cdriver" />
		<cfif NOT directoryExists(cacheDriverDir)>
			<cfdirectory action="create" directory="#cacheDriverDir#" recurse="true" />
		</cfif>
		<cfreturn cacheDriverDir />
	</cffunction>

	<!---
	Copies a directory.

	@param source      Source directory. (Required)
	@param destination      Destination directory. (Required)
	@param nameConflict      What to do when a conflict occurs (skip, overwrite, makeunique). Defaults to overwrite. (Optional)
	@return Returns nothing.
	@author Joe Rinehart (joe.rinehart@gmail.com)
	@version 2, February 4, 2010
	--->
	<cffunction name="dirCopy" output="true">
	    <cfargument name="source" required="true" type="string">
	    <cfargument name="destination" required="true" type="string">
	    <cfargument name="nameconflict" required="true" default="overwrite">

	    <cfset var contents = "" />

	    <cfif not(directoryExists(arguments.destination))>
	        <cfdirectory action="create" directory="#arguments.destination#">
	    </cfif>

	    <cfdirectory action="list" directory="#arguments.source#" name="contents">

	    <cfloop query="contents">
	        <cfif contents.type eq "file">
	            <cffile action="copy" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#" nameconflict="#arguments.nameConflict#">
	        <cfelseif contents.type eq "dir">
	            <cfset dirCopy(arguments.source & "/" & name, arguments.destination & "/" & name) />
	        </cfif>
	    </cfloop>
	</cffunction>

	<cffunction name="addTestPlugin" access="private" output="false">
		<cfargument name="testfile" required="true" />
		<cfargument name="isBuiltInTag" required="true" type="boolean" />
		<cfset var testfilename = listLast(testfile,'/\') />
		<cfset var lang = "" />
		<cfset var action = "" />
		<cfset var test = "" />
		<cfoutput>
			<cfsavecontent variable="lang">
				<?xml version="1.0" encoding="UTF-8"?>
				<languages>
					<language key="de">
						<title>
							#variables.extensionTag# test
						</title>
						<description>
							Dis et un test den #variables.extensionTag#
						</description>
					</language>
					<language key="en">
						<title>
							#variables.extensionTag# test
						</title>
						<description>
							Test for #variables.extensionTag#
						</description>
					</language>
				</languages>
			</cfsavecontent>
			<cfsavecontent variable="action">
				<%cfcomponent extends="railo-context.admin.plugin.Plugin"> <%cffunction name="init" hint="this function will be called to initalize"> <%cfargument name="lang" type="struct"> <%cfargument name="app" type="struct"> <%/cffunction> <%cffunction name="overview" output="yes"> <%cfargument name="lang" type="struct"> <%cfargument name="app" type="struct"> <%cfargument name="req" type="struct"> <%cfoutput><%cfinclude template="#testfilename#"/><%/cfoutput> <%/cffunction> <%/cfcomponent>
			</cfsavecontent>
		</cfoutput>
		<cfset pluginDir = getPluginDir() & "/" & variables.extensionTag />
		<cfif NOT directoryExists(pluginDir)>
			<cfdirectory action="create" directory="#pluginDir#" recurse="true" />
		</cfif>
		<cffile action="write" file="#pluginDir#/language.xml" output="#lang#" />
		<cffile action="write" file="#pluginDir#/Action.cfc" output="#replace(action,'<%','<','all')#" />
		<cffile action="read" file="#testfile#" variable="test" />
		<cfif isBuiltInTag>
			<cfset test = replace(test,"cf_#rereplace(variables.extensionTag,'^cf','')#","cf#rereplace(variables.extensionTag,'^cf','')#","all") />
		</cfif>
		<cffile action="write" file="#pluginDir#/#testfilename#" output="#test#" />
		<cfif listLast(getDirectoryFromPath(testfile),"\/") eq "test">
			<cfset dirCopy(getDirectoryFromPath(testfile),pluginDir) />
		</cfif>
		<cfadmin action="reload" type="#request.adminType#" password="#session["password"&request.adminType]#"/>
	</cffunction>

	<cffunction name="addTestPluginFile" access="private" output="false">
		<cfargument name="testfile" required="true" />
		<cfset var testfilename = listLast(testfile,'/\') />
		<cfset pluginDir = getPluginDir() & "/" & variables.extensionTag />
		<cfif NOT directoryExists(pluginDir)>
			<cfdirectory action="create" directory="#pluginDir#" recurse="true" />
		</cfif>
		<cffile action="copy" destination="#pluginDir#/#testfilename#" source="#testfile#" />
	</cffunction>

</cfcomponent>