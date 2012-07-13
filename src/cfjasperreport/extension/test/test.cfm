<cfset h2util = createObject("component","H2Util").init(cfadminpassword="testtest") />
<cffunction name="fakeAction">
	<cfargument name="name">
	<cfreturn '?'>
</cffunction>
<cfset thisHereDir = getDirectoryFromPath(getCurrentTemplatePath()) />
<cfoutput>
	<!--- check to see if we are running from the plugin, define faux function if not --->
	<cftry>
		<cfset wee = action("overview") />
	<cfcatch>
		<cfset action = fakeAction />
	</cfcatch>
	</cftry>
	<cfdirectory action="list" directory="./examples" name="exampledirs"/>
	<cfloop query="exampledirs">
		<h3>#name#</h3>
		<cfdirectory action="list" directory="#thisHereDir#/examples/#name#/reports" name="examplereports" filter="*.jrxml"/>
		<cfloop query="examplereports">
			<blockquote>
				<form action="#action('overview')#" method="post">
					<input type="hidden" name="exampledir" value="#exampledirs.name#">
					<input type="hidden" name="jrxml" value="#examplereports.name#">
					<input type="hidden" name="runreport" value="1">
					<strong>#examplereports.name#</strong>
					type:
					<select name="exporttype">
						<cfset exporttypes = "PDF:pdf,Excel (POI):xls,RTF:rtf,xml:xml,xmlEmbed:xmlEmbed,HTML:html,Excel (jExcelAPI):jxl,CSV:csv,ODT:odt,ODS:ods,DOCX:docx,XLSX:xlsx,PowerPoint (PPTX):pptx,XHTML:xhtml" />
						<cfloop list="#exporttypes#" index="lst">
							<option value="#listLast(lst,':')#">#listFirst(lst,':')#</option>
						</cfloop>
					</select>
					<input type="submit" value="run report">
					<br />
				</form>
			</blockquote>
		</cfloop>
	</cfloop>
<cffile action="read" file="#getCurrentTemplatePath()#" variable="code">
<cfoutput><pre>
Code:
#replace(code,"<","<","all")#</pre></cfoutput>
	<cfif structKeyExists(form,"runreport")>
		<cfset dsname = "" />
		<cfset datafile = "" />
		<cfset resourcebundle = "" />
		<cfset reportparams = structNew() />
		<!--- run any needed report example setup stuff --->
		<cfinclude template="examples/#form.exampledir#/setup.cfm">
		<!--- run the report with whatever was set in setup.cfm --->
		<cf_jasperreport
			jrxml="#thisHereDir#/examples/#form.exampledir#/reports/#form.jrxml#"
			filename="#listFirst(form.jrxml,'.')#"
			dsn="#dsname#"
			resourcebundle="#resourcebundle#"
			reportparams="#reportparams#"
			datafile="#datafile#"
			exporttype="#form.exporttype#"/>
	</cfif>
</cfoutput>
