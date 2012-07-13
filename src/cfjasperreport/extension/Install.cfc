<cfcomponent extends="install.Installer">

		<cfset variables.extensionTag = "cfjasperreport" />

    <cffunction name="validate" returntype="string" output="no"
    	hint="called from Railo to install application">
    	<cfargument name="error" type="struct">
        <cfargument name="path" type="string">
        <cfargument name="config" type="struct">
        <cfargument name="step" type="numeric">
        <cfset arguments.config=arguments.config.mixed>
    </cffunction>

    <cffunction name="install" returntype="string" output="no"
    	hint="called from Railo to install application">
    	<cfargument name="error" type="struct">
        <cfargument name="path" type="string">
        <cfargument name="config" type="struct">

       	<cfset arguments.config=arguments.config.mixed>

				<cfset standardInstall(error,path,config) />

				<cfif directoryExists(getDirectoryFromPath(getMetadata(this).path)&"test")>
					<cfif config.installTestPlugin>
						<cfset addTestPlugin(getDirectoryFromPath(getMetadata(this).path)&"test/test.cfm",config.isBuiltInTag) />
					<cfelse>
					</cfif>
				</cfif>

        <!--- create mapping --->
<!---
        <cfif config.makeMapping>
            <cfadmin
                action="updateMapping"
                type="#request.adminType#"
                password="#session["password"&request.adminType]#"

                virtual="#sctURL.scriptName#"
                physical="#config.rootPath#"
                archive=""
                primary="physical"
                trusted="false"
                toplevel="true">
        </cfif>
 --->
		<cflog type="INFO" text="#serializeJSON(error)#"/>
        <cfset var message='#variables.extensionTag# is now successfully installed! Rock on with your bad self.'>
		<cfif config.isBuiltInTag OR config.installTestPlugin>
			<cfset message = message & "<br /><strong>P.S.</strong> <font color='red'>You will need to <a href=""#getContextRoot()#/railo-context/admin/server.cfm?action=services.restart"">restart the server</a> to use the new functionality!</font>">
		</cfif>
        <cfreturn message>

    </cffunction>

	<cffunction name="update">
	</cffunction>

    <cffunction name="uninstall" returntype="string" output="no"
    	hint="called from Railo to uninstall application">
    	<cfargument name="path" type="string">
        <cfargument name="config" type="struct">
       	<cfset arguments.config=arguments.config.mixed>
				<cfset standardUnInstall(path,config) />
        <cfreturn '#variables.extensionTag# sucessfully removed'>
    </cffunction>

</cfcomponent>