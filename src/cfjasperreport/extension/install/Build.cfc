<cfcomponent output="false">

	<cffunction name="build" returntype="struct" output="false">
		<cfset var builddir = getDirectoryFromPath(getMetadata(this).path) & "../../../../build" />
		<cf_antrunner antfile="#builddir#/build.xml" target="build.extension" resultsVar="result"/>
		<cfreturn result />
	</cffunction>

	<cffunction name="getExtensionName">
		<cfset var extensionName = "" />
		<cfdirectory action="list" directory="../../../" name="extensionName" />
		<cfset extensionName = listLast(extensionName.fileName) />
		<cfreturn extensionName />
	</cffunction>

	<cffunction name="compileRailoMapping">
		<cfset var cm = "" />
		<cfset var cmList = "" />
		<cffile action="read" file="#getDirectoryFromPath(getMetadata(this).path)#temp/CompileMappings.txt" variable="cmList" />
		<cfloop list="#cmList#" index="cm">
			<cfadmin
			    action="compileMapping"
			    type="web"
			    password="#session.passwordweb#"
			    virtual="#cm#"
		    	stoponerror="false"
		     />
		</cfloop>
	</cffunction>

	<cffunction name="createRailoArchive">
		<cffile action="read" file="#getDirectoryFromPath(getMetadata(this).path)#temp/Archives.txt" variable="raList" />
		<cfloop list="#raList#" index="ra">
			<cfadmin
			    action="createArchive"
			    type="web"
			    password="#session.passwordweb#"
			    file="#listFirst(ra,'=')#"
			    virtual="#listLast(ra,'=')#"
			    secure="true"
			    	stoponerror="false"
			    append="false"
			     />
		</cfloop>
	</cffunction>


</cfcomponent>