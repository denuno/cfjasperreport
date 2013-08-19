<cfcomponent name="jasperreport">

	<!--- Meta data --->
	<cfset this.metadata.attributetype="fixed" />

	<cfset this.metadata.attributes={
		action=			{required:false,type:"string",default:"runReport"},
		jrxml=			{required:false,type:"string",default:""},
		exporttype=			{required:false,type:"string",default:"pdf"},
		exportfile=			{required:false,type:"string",default:""},
		dsn=			{required:false,type:"string",default:""},
		datasource=			{required:false,type:"string",default:""},
		query=			{required:false,type:"Object"},
		params=			{required:false,type:"struct"},
		sqlstring=			{required:false,type:"string",default:""},
		datafile=			{required:false,type:"any",default:""},
		resultsVar= {required:false,type:"string",default:"report"},
		resourcebundle = {required:false,type:"string",default:""},
		datasourcexpath= {required:false,type:"string",default:""},
		filename=			{required:false,type:"string",default:"report"},
		forceDownload= {required:false,type:"boolean",default:"false"}
		} />

	<cffunction name="init" output="no" returntype="void" hint="invoked after tag is constructed">
		<cfargument name="hasEndTag" type="boolean" required="yes" />
		<cfargument name="parent" type="component" required="no" hint="the parent cfc custom tag, if there is one" />
		<cfset var libs = "" />
		<cfset variables.hasEndTag = arguments.hasEndTag />
	</cffunction>

<!---
	<cffunction name="throw">
		<cfargument name="message" />
		<cfargument name="error" />
		<cfif structKeyExists(arguments,"error")>
			<!--- <cfset request.debug(error) /> --->
			<cftry>
				<cfthrow type="cfjasperreport.error" message="#message#" detail="#error.stacktrace#" />
				<cfcatch>
					<cfthrow type="cfjasperreport.error" message="#message#" detail="#error.toString()#" />
				</cfcatch>
			</cftry>
		</cfif>
		<cfthrow type="cfjasperreport.error" message="#message#" />
	</cffunction>
 --->

	<cffunction name="onStartTag" output="yes" returntype="boolean">
		<cfargument name="attributes" type="struct" />
		<cfargument name="caller" type="struct" />
		<cfscript>
			var report = "";
			if(attributes.dsn neq "") {
				attributes.datasource = attributes.dsn;
			}
			var results = callMethod("_"&attributes.action,attributes);
			
			if(attributes.action == "runReport") {
				if(attributes.exportfile gt "") {
					reportToFile(results,attributes.exportfile);
				} else {
					download("#attributes.filename#.#attributes.exporttype#",results,attributes.forceDownload);
				}
			}
			caller[attributes.resultsVar] = results;
		</cfscript>
		<cfif not variables.hasEndTag>
			<cfset onEndTag(attributes,caller,"") />
		</cfif>
		<cfreturn variables.hasEndTag />
	</cffunction>

	<cffunction name="getLibraryLoader" returntype="any" output="false" access="private" hint="">
		<cfif NOT structKeyExists(variables,"_loader")>
			<cfset variables._loader = createObject("component","lib.LibraryLoader").init() />
		</cfif>
	  <cfreturn variables._loader />
	</cffunction>

	<cffunction name="_runReport">
		<cfargument name="jrxml" type="string" required="yes" />
		<cfargument name="dataSource" default="" />
		<cfargument name="datafile" default="" />
		<cfargument name="exportType" default="pdf" />
		<cfargument name="reportparams" default="#structNew()#" />
		<cfargument name="download" default="no" />
		<cfargument name="newquery" default="" />
		<cfargument name="query" />
		<cfargument name="resourcebundle" default="" />
		<cfargument name="locale" default="US" />
		<cfargument name="localeLanguage" default="ENGLISH" />
		<cflock name="jasperLock" type="exclusive" timeout="10">
			<cfif fileExists(arguments.jrxml)>
				<cfset var daJRXML = readJRXMLFile(arguments.jrxml) />
			<cfelseif isXML(arguments.jrxml)>
				<cfset var daJRXML = xmlparse(arguments.jrxml) />
			<cfelse>
				<cfthrow type="cfjasperreport.filenotfound" detail="the file #jrxml# could not be found or was not valid XML" />
			</cfif>
			<cfscript>
				var jasperReport = _compile(arguments.jrxml);
				var system = getLibraryLoader().create("java.lang.System");
				var classpath = system.getProperty("java.class.path");
				var daTitle = daJRXML.jasperReport.xmlAttributes.name;
				var daXM = toString(daJRXML);
				var params = reportparams;
				var parameters = getLibraryLoader().create("java.util.HashMap");
				var ka = structNew();
				var daConnection = "";
				var drs = "";
				var LocaleOb = getLibraryLoader().create("java.util.Locale");
				var JRParameter = getLibraryLoader().create("net.sf.jasperreports.engine.JRParameter");
				var FileOb = getLibraryLoader().create("java.io.File");

				// we get "Cannot load com.apple.laf.AquaLookAndFeel" if we don't set crossPlat on OSX at least
				var UIManager = getLibraryLoader().create("javax.swing.UIManager");
				UIManager.setLookAndFeel(UIManager.getCrossPlatformLookAndFeelClassName());

				if(NOT isStruct(params)) {
					params = structNew();
				}
				var ka = StructKeyArray(params);
				// convert params to hashmap
				for(i=1; i LTE ArrayLen(ka); i=i+1){
					parameters.put(ka[i], params[ka[i]]);
				}
				if(arguments.locale gt "") {
					parameters.put(JRParameter.REPORT_LOCALE, LocaleOb[ucase(locale)]);
				}
				if(arguments.resourcebundle gt "") {
					var rbStream = getLibraryLoader().create("java.io.ByteArrayInputStream").init(readBinaryFile(arguments.resourceBundle));
					var rb = getLibraryLoader().create("java.util.PropertyResourceBundle").init(rbStream);
					parameters.put(JRParameter.REPORT_RESOURCE_BUNDLE, rb);
				}
				/*
				dicking around to get groovy expressions to work-- might need to specifically
				use JRGroovyCompiler and set path.  Groovy works if all jars are in JVM classpath.

				  jasperclasspath = getJasperreportsClassPath();
				  system.setProperty("jasper.reports.compile.class.path",jasperclasspath);
				  system.setProperty("java.class.path",jasperclasspath);
				  system.setProperty("groovy.classpath",jasperclasspath);
				  jrprops = getLibraryLoader().create("net.sf.jasperreports.engine.util.JRProperties");
				  jrprops.setProperty(jrprops.COMPILER_CLASSPATH, jasperclasspath);
				*/

				if(datasource gt "" && listLast(datasource,".") == "xml") {
					daConnection = jrdatasource(datasource);
				} else if(datasource eq "empty") {
					daConnection = getLibraryLoader().create("net.sf.jasperreports.engine.JREmptyDataSource");
				} else if(datasource neq "") {
					var manager = getPageContext().getDataSourceManager();
					var dc = manager.getConnection(getPageContext(),datasource, javacast("null",""), javacast("null",""));
					daConnection = dc.getConnection();
				}

				if (datafile !="") {
					if(listLast(datafile,".") == "xml") {
				 		//JRloader = getLibraryLoader().create("net.sf.jasperreports.engine.util.JRLoader");
						var JRXPathQueryExecuterFactory = getLibraryLoader().create("net.sf.jasperreports.engine.query.JRXPathQueryExecuterFactory");
						parameters.put(JRXPathQueryExecuterFactory.PARAMETER_XML_DATA_DOCUMENT, xmlParse(datafile));
						parameters.put(JRXPathQueryExecuterFactory.XML_DATE_PATTERN, "yyyy-MM-dd");
						parameters.put(JRXPathQueryExecuterFactory.XML_NUMBER_PATTERN, "##,####0.####");
						parameters.put(JRXPathQueryExecuterFactory.XML_LOCALE, LocaleOb[ucase(localeLanguage)]);
					} else {
						throw(type="cfjasperreport.datafile.error", message="unsupported datafile type #datafile#");
					}
				}
				var jasperFillManager = getLibraryLoader().create("net.sf.jasperreports.engine.JasperFillManager");
				//JasperFillManager.fillReportToFile(fileName, null,
				    //            new JRXmlDataSource(new BufferedInputStream(new FileInputStream("northwind.xml")), "/Northwind/Customers"));
				//System.err.println("Filling time : " + (System.currentTimeMillis() - start));
				//System.exit(0);
				var jasperPrint = "";
					if(isQuery(newquery) OR newquery NEQ ""){
						if (isQuery(newquery)) {
							rs = newquery;
						}
						else {
							stmt = getLibraryLoader().create("java.sql.Statement");
							stmt = daConnection.createStatement();
							rs = getLibraryLoader().create("java.sql.ResultSet");
							rs = stmt.executeQuery(newquery);
						}
						drs = getLibraryLoader().create("net.sf.jasperreports.engine.JRResultSetDataSource");
						drs.init(rs);
						jasperPrint = getLibraryLoader().create("net.sf.jasperreports.engine.JasperPrint");
						try{
						  jasperPrint = jasperFillManager.fillReport(jasperReport, parameters, drs);
						}catch(JRException e){
							throw(type="cfjasperreport.error", message=e.printStackTrace());
						}
					}
					else if (datasource gt ""){
						try{
							if(isNull(daConnection)) {
								throw(type="cfjasperreport.error.nullconnection", detail="connection for #datasource# is null");
							}
							jasperPrint = jasperFillManager.fillReport(jasperReport, parameters, daConnection);
							try {
								daConnection.close();
							} catch(any e) {
								// we do not care, only certain datasources need closing
							}
							if(isDefined("manager")) {
								manager.releaseConnection(getPageContext(),dc);
							}
						}
						catch(JRException e){
							if(isDefined("manager")) {
								manager.releaseConnection(getPageContext(),dc);
							}
							throw(type="cfjasperreport.error", message=e.printStackTrace());
						}
					} else if (structKeyExists(arguments,"query") and isQuery(arguments.query)){
						try{
							drs = getLibraryLoader().create("net.sf.jasperreports.engine.data.JRMapArrayDataSource");
							var arrayQuery = querytoarray(query);
							drs.init(arrayQuery);
							jasperPrint = jasperFillManager.fillReport(jasperReport, parameters, drs);
						}
						catch(JRException e){
							throw(type="cfjasperreport.error", message=e.printStackTrace());
						}
					} else {
						try{
							jasperPrint = jasperFillManager.fillReport(jasperReport, parameters);
						}
						catch(JRException e){
							throw(type="cfjasperreport.error", message=e.printStackTrace());
						}
					}
					///virtualizer.setReadOnly(true);
					//jasperPrint = jasperFillManager.fillReport(jasperReport, parameters, jRXmlDataSource);
					var jasperExportManager = getLibraryLoader().create("net.sf.jasperreports.engine.JasperExportManager");
				    var expparam = getLibraryLoader().create("net.sf.jasperreports.engine.JRExporterParameter");
					var outStream = getLibraryLoader().create("java.io.ByteArrayOutputStream").init();
					var argy = '';
				     //exporter.setParameter(expparam.OUTPUT_FILE_NAME,outfile);
					if (exportType is "pdf") {
						argy = jasperExportManager.exportReportToPdf(jasperPrint);
					} else {
						exporterType = ucase(left(exportType,1)) & lcase(right(exportType,len(exportType)-1));
				    	jRExporterParameter = getLibraryLoader().create("net.sf.jasperreports.engine.JRExporterParameter");
						jasperRtfExporter = getLibraryLoader().create("net.sf.jasperreports.engine.export.JR#exporterType#Exporter");
					  	jasperRtfExporter.setParameter(jRExporterParameter.JASPER_PRINT, jasperPrint);
						jasperRtfExporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outstream);
						jasperRtfExporter.exportReport();
						argy = outstream;
					}
					outstream.close();
					return argy;
			</cfscript>
		</cflock>
	</cffunction>

	<cffunction name="_jrdatasource">
		<cfargument name="datasource">
		<cfargument name="datasourcexpath" default="" />
		<cfscript>
			var jRDataSource = "";
			var FileOb = getLibraryLoader().create("java.io.File");
			if(listLast(datasource,".") eq "csv") {
				jRDataSource = getLibraryLoader().create("net.sf.jasperreports.engine.data.JRCsvDataSource").init(FileOb.init(datasource),"UTF-8");
			} else if(datasource gt "" && listLast(datasource,".") == "xml") {
				var jRXmlDataSource = getLibraryLoader().create("net.sf.jasperreports.engine.data.JRXmlDataSource");
					jRDataSource = jRXmlDataSource.init(FileOb.init(datasource));
				if(arguments.datasourcexpath gt "") {
					jRDataSource.datasource(datasourcexpath);
				}
			} else {
				throw(type="cfjasperreport.datafile.error", message="unsupported datafile type #datafile#");
			}
			return jRDataSource;
		</cfscript>
	</cffunction>

	<cffunction name="_compile">
		<cfargument name="jrxml" type="string" required="yes" />
		<cfargument name="tofile" type="string" default="" />

		<cfif fileExists(arguments.jrxml)>
			<cfset var daJRXML = readJRXMLFile(arguments.jrxml) />
		<cfelseif isXML(arguments.jrxml)>
			<cfset var daJRXML = xmlparse(arguments.jrxml) />
		<cfelse>
			<cfthrow type="cfjasperreport.filenotfound" detail="the file #jrxml# could not be found or was not valid XML" />
		</cfif>
		<cfscript>
			var system = getLibraryLoader().create("java.lang.System");
			var classpath = system.getProperty("java.class.path");
			var daTitle = daJRXML.jasperReport.xmlAttributes.name;
			var daXM = toString(daJRXML);
			var xmlBuffer = getLibraryLoader().create("java.lang.String").init(daXM).getBytes();
			var xmlInputStream = getLibraryLoader().create("java.io.ByteArrayInputStream").init(xmlBuffer);
			var jRXmlLoader = getLibraryLoader().create("net.sf.jasperreports.engine.xml.JRXmlLoader");
			var jasperDesign = jRXmlLoader.load(xmlInputStream);
	 		var jasperCompileManager = getLibraryLoader().create("net.sf.jasperreports.engine.JasperCompileManager");
			var jasperVerify = jasperCompileManager.verifyDesign(jasperDesign);
			///virtualizer = getLibraryLoader().create("net.sf.jasperreports.engine.fill.JRFileVirtualizer");
			///virtualizer.init(2,javacast("String","/tmp"));
			///params["REPORT_VIRTUALIZER"] = virtualizer;
			// move the param structure to an array to evaluate
			if(arrayLen(jasperVerify) gt 0) {
				errors = "";
				var x = 0;
				for(x = 1; x lte arrayLen(jasperVerify); x++) {
					errors = listAppend(errors, jasperVerify[x].getMessage() & "(" & jasperVerify[x].getSource().getText() & ")");
				}
				throw(type="jasperreports.report.design.flaw",detail=errors);
			}
			try {
				if(tofile neq "") {
					var jasperReport = jasperCompileManager.compileReportToFile(tofile);
				} else {
					var jasperReport = jasperCompileManager.compileReport(jasperDesign);
				}
			} catch (any e) {
				throw(type="jasperreports.report.compile.error",detail=e.message & " -- " & e.detail);
			}
			xmlInputStream.close();
			return jasperReport;
		</cfscript>
	</cffunction>

	<cffunction name="onEndTag" output="yes" returntype="boolean">
		<cfargument name="attributes" type="struct" />
		<cfargument name="caller" type="struct" />
		<cfargument name="generatedContent" type="string" />
		<cfreturn false />
	</cffunction>

	<cffunction name="readJRXMLFile" output="false" returntype="any" access="private">
		<cfargument name="jrxmlfile" type="string" required="yes" />
		<cfset var daJR = "" />
		<cffile action="read" variable="daJR" file="#arguments.jrxmlfile#" charset="utf-8">
		<cfreturn xmlparse(daJR) />
	</cffunction>

	<cffunction name="readBinaryFile" output="false" returntype="any" access="private">
		<cfargument name="filepath" type="string" required="yes" />
		<cfset var daFile = "" />
		<cffile action="readbinary" variable="daFile" file="#arguments.filepath#">
		<cfreturn daFile />
	</cffunction>

	<cffunction name="getJasperreportsClassPath" output="false" returntype="any" access="private">
		<cfscript>
			var jarsArry = getLibraryLoader().create("net.sf.jasperreports.engine.JasperFillManager").getClass().getClassLoader().getURLs();
			var system = getLibraryLoader().create("java.lang.System");
			var classpath = system.getProperty("java.class.path");
			var delim = system.getProperty("path.separator");
			for(x = 1; x lte arrayLen(jarsArry); x++) {
				jarpath = replace(jarsArry[x].toString(),"file:","");
				classpath = listAppend(classpath,jarpath,delim);
			}
		</cfscript>
		<cfreturn classpath />
	</cffunction>

	<cffunction name="reportToFile" output="false" returntype="void" access="private">
		<cfargument name="fileContent" required="true" />
		<cfargument name="reportfile" type="string" required="yes" />
		<cfset var daJR = "" />
		<cffile action="write" output="#arguments.fileContent#" file="#arguments.reportfile#">
	</cffunction>

	<cffunction name="download" output="true" returntype="void" access="private">
		<cfargument name="fileName" required="true" />
		<cfargument name="fileContent" required="true" />
		<cfargument name="forceDownload" default="false" />
		<cfset var cvalue = "" />
		<cfset var out = "" />
		<cfset var content = "" />
		<cfset var context = "" />
		<cfset var response = "" />
		<cfsetting showdebugoutput="no">
		<cfsetting enablecfoutputonly="yes">
		<cfif arguments.forceDownload>
			<cfset cvalue = 'attachment;' />
		</cfif>
		<cfset cvalue = cvalue & "filename=#arguments.fileName#" />
		<cfheader name="Content-Disposition" value="#cvalue#" charset="utf-8">
		<!---
			<cfdump var="#filecontent#" abort>
			--->
		<!---
			Doesn't work for some reason, maybe application.cfc?
			<cfheader name="Content-Disposition" value="#cvalue#" charset="utf-8">
			<cfcontent type="application/#exportType#" reset="true"><cfoutput>#arguments.fileContent#</cfoutput>
			--->
		<cfscript>
			content = toBinary(arguments.fileContent);
			 context = getPageContext();
			 response = context.getResponse();
			 out = response.getOutputStream();
			 response.setContentType("application/#listLast(filename,'.')#");
			 response.setContentLength(arrayLen(content));
			 out.write(content);
			 out.flush();
			 out.close();
		</cfscript>
	</cffunction>

	<cffunction name="querytoarray" returntype="array" output="No">
		<cfargument name="q" required="Yes" type="query">
		<cfset var aTmp = arraynew(1)>
		<cfset var qmeta = getMetaData(q)>
		<cfset var types = {} />
		<cfloop array="#qmeta#" index="met">
			<cfset types[met.name] = met.typeName />
		</cfloop>
		<cfif q.recordcount>
			<cfloop query="q">
				<cfset stTmp = structNew()>
				<cfloop list="#lcase(q.columnlist)#" index="col">
					<cfif types[col] == "INTEGER">
						<cfset stTmp["#col#"] = javaCast("int",q[col][currentRow]) />
					<cfelse>
						<cfset stTmp["#col#"] = q[col][currentRow] />
					</cfif>
				</cfloop>
				<cfset arrayAppend(aTmp,stTmp)>
			</cfloop>
		<cfelse>
			<cfset stTmp = structNew()>
			<cfloop list="#lcase(q.columnlist)#" index="col">
				<cfset stTmp["#col#"] = "">
			</cfloop>
			<cfset arrayAppend(aTmp,stTmp)>
		</cfif>
		<cfreturn aTmp>
	</cffunction>

<cfscript>
	/**
	 * Access point for this component.  Used for thread context loader wrapping.
	 **/

	function onMissingMethod(missingMethodName,missingMethodArguments){
		return callMethod("_"&missingMethodName,missingMethodArguments);
	}

	function callMethod(methodName, args) {
		var cl = getLibraryLoader();
		jThread = cl.create("java.lang.Thread");
		cTL = jThread.currentThread().getContextClassLoader();
		//system.out.println(server.coldfusion.productname);
		if(findNoCase("railo",server.coldfusion.productname)) {
			jThread.currentThread().setContextClassLoader(cl.GETLOADER().getURLClassLoader());
		}
//		var tl = cl.create("com.googlecode.transloader.Transloader").DEFAULT;
//		var er = cl.create("org.jivesoftware.util.log.util.CommonsLogFactory");
//		var wee = tl.wrap(er.getClass());

		variables.switchThreadContextClassLoader = cl.getLoader().switchThreadContextClassLoader;
		return switchThreadContextClassLoader(this.runInThreadContext,arguments,cl.getLoader().getURLClassLoader());
    }
	function runInThreadContext(methodName,  args) {
		try{
			var theMethod = this[methodName];
			return theMethod(argumentCollection=args);
		} catch (any e) {
			try{
				stopServer();
			} catch(any err) {}
			jThread.currentThread().setContextClassLoader(cTL);
			throw(e);
		}
		jThread.currentThread().setContextClassLoader(cTL);
	}

</cfscript>

</cfcomponent>
