<cfcomponent displayname="TestInstall"  extends="mxunit.framework.TestCase">


  	<cffunction name="beforeTests" returntype="void" access="public">
		<cfset variables.extensionTag = "cfjasperreport" />
 		<cfset variables.Install = createObject("component","#variables.extensionTag#.extension.Install") />
		<cfdirectory action="list" directory="/#variables.extensionTag#/../../dist/" name="files" sort="desc" filter="*.zip"/>
		<cfset variables.extensionzip = "/#variables.extensionTag#/../../dist/#files.name[1]#" />
		<cfset var passw = "">
		<cfif NOT fileExists(variables.extensionzip)>
			<cfset var build = createObject("component","TestBuild") />
			<cfset build.setUp() />
			<cfset build.testBuild() />
		</cfif>
	</cffunction>

  <cffunction name="setUp" returntype="void" access="public">
		<cffile action="read" file="#expandpath('/tests')#/cfadminpassword.txt" variable="passw" />
		<cfset variables.defaultconfig = {"mixed":{"isBuiltInTag":true,"installTestPlugin":true}} />
		<cfset request.adminType = "web" />
		<cfset session.passwordweb = passw />
		<cfset session.passwordserver = passw />
  </cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<cftry>
			<cfset testUnInstall() />
		<cfcatch>
			<!--- just in case a test failed and did not uninstall --->
		</cfcatch>
		</cftry>
	</cffunction>


	<cffunction name="dumpvar" access="private">
		<cfargument name="var">
		<cfdump var="#var#">
		<cfabort/>
	</cffunction>

	<cffunction name="testAddJars">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var err = structNew();
			var path = expandPath("/#variables.extensionTag#/lib/");
			var config = variables.defaultconfig;
			var result = variables.Install.addJars(err,path,config);
	//		debug(result);
//			assertEquals(true,result.status,result.message);
			if(uninstall) {
				testRemoveJars();
			}
		</cfscript>
	</cffunction>

	<cffunction name="testInstall" access="private">
		<cfargument name="config" required="true">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var error = structNew();
			var path = "zip://" & expandPath("#variables.extensionzip#!/");
			var config = arguments.config;
			var libraryPath = expandPath('{railo-#request.adminType#}/library');
			var result = variables.Install.install(error,path,config);
			if(config.mixed.isBuiltInTag) {
				var cfcpth = "#libraryPath#/tag/#variables.extensionTag#/cfc/#rereplace(variables.extensionTag,'^cf','')#.cfc";
				log type="info" text="#serializeJSON(config)# to path #cfcpth#";
				assertTrue(fileExists(cfcpth),cfcpth & " does not exist " & result);
			} else {
				var cfcpth = "#libraryPath#/../customtags/#variables.extensionTag#/cfc/#rereplace(variables.extensionTag,'^cf','')#.cfc";
				log type="info" text="#serializeJSON(config)# to path #cfcpth#";
				assertTrue(fileExists(cfcpth),cfcpth & " does not exist " & result);
			}
//			assertEquals(true,result.status,result.message);
			if(arguments.uninstall){
				testUnInstall(config);
			}
		</cfscript>
	</cffunction>

	<cffunction name="testInstallWebBuiltInTag">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var config = variables.defaultconfig;
			config.mixed.isBuiltInTag = false;
			request.adminType = "web";
			testInstall(config,uninstall);
		</cfscript>
	</cffunction>

	<cffunction name="testInstallWebCustomTag">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var config = variables.defaultconfig;
			config.mixed.isBuiltInTag = true;
			request.adminType = "web";
			testInstall(config,uninstall);
		</cfscript>
	</cffunction>

	<cffunction name="testInstallServerBuiltInTag">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var config = variables.defaultconfig;
			config.mixed.isBuiltInTag = true;
			request.adminType = "server";
			testInstall(config,uninstall);
		</cfscript>
	</cffunction>

	<cffunction name="testInstallServerCustomTag">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var config = variables.defaultconfig;
			config.mixed.isBuiltInTag = false;
			request.adminType = "server";
			testInstall(config,uninstall);
		</cfscript>
	</cffunction>

	<cffunction name="testUnInstall" access="private">
		<cfargument name="config" default="#variables.defaultconfig#">
		<cfscript>
			var error = structNew();
			var path = "zip://" & expandPath("#variables.extensionzip#!/");
			var result = variables.Install.uninstall(path,config);
			var libraryPath = expandPath('{railo-#request.adminType#}/library');
			if(config.mixed.isBuiltInTag) {
				assertFalse(fileExists("#libraryPath#/tag/#variables.extensionTag#/cfc/#rereplace(variables.extensionTag,'^cf','')#.cfc"));
			} else {
				assertFalse(fileExists("#libraryPath#/../customtags/#variables.extensionTag#/cfc/#rereplace(variables.extensionTag,'^cf','')#.cfc"));
			}
	//		debug(result);
//			assertEquals(true,result.status,result.message);
		</cfscript>
	</cffunction>


	<cffunction name="testInstallCustomTag">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var error = structNew();
			var path = "zip://" & expandPath("#variables.extensionzip#!/");
			var config = variables.defaultconfig;
			var result = variables.Install.install(error,path,config);
	//		debug(result);
//			assertEquals(true,result.status,result.message);
			if(arguments.uninstall){
				testUnInstallCustomTag();
			}
		</cfscript>
	</cffunction>

	<cffunction name="testUnInstallCustomTag" access="private">
		<cfscript>
			var error = structNew();
			var path = "zip://" & expandPath("#variables.extensionzip#!/");
			var config = variables.defaultconfig;
			var result = variables.Install.uninstall(path,config);
	//		debug(result);
//			assertEquals(true,result.status,result.message);
		</cfscript>
	</cffunction>


	<cffunction name="testInstallDevCustomTag">
		<cfargument name="uninstall" default="true">
		<cfscript>
			var error = structNew();
			var config = variables.defaultconfig;
			testAddJars(uninstall);
			var config = variables.defaultconfig;
			try {
				var result = variables.Install.addCustomTagsMapping("#expandPath("/"&variables.extensionTag)#/src/tag");
			} catch (any e) {
				debug(e);
			}
			if(arguments.uninstall){
				testUnInstallDevCustomTag();
			}
			return 'added mapping: #expandPath("/"&variables.extensionTag)#/src/tag';
		</cfscript>
	</cffunction>

	<cffunction name="testUnInstallDevCustomTag" access="private">
		<cfscript>
			var error = structNew();
			var path = "zip://" & expandPath("#variables.extensionzip#!/");
			var config = variables.defaultconfig;
			var result = variables.Install.removeCustomTagsMapping("#expandPath("/"&variables.extensionTag)#/src/tag");
		</cfscript>
	</cffunction>

	<cffunction name="testRemoveJars" access="private">
		<cfscript>
			var error = structNew();
			var path = expandPath("/#variables.extensionTag#/lib/");
			var config = variables.defaultconfig;
			var result = variables.Install.removeJars(error,path,config);
		</cfscript>
	</cffunction>

	<cffunction name="listFiles" access="private">
		<cfargument name="dir" required="true" />
		<cfset var files = "" />
		<cfdirectory action="list" directory="#dir#" name="files">
		<cfreturn files />
	</cffunction>

</cfcomponent>