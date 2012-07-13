<cfset datafile = getDirectoryFromPath(getCurrentTemplatePath()) & "/data/northwind.xml" />
<cf_jasperreport action="compile" jrxml="#getDirectoryFromPath(getCurrentTemplatePath())#/reports/OrdersReport.jrxml" resultsVar="subreport">
<cfset reportparams["OrdersReport"] = subreport />
<cfset JRParameter = createObject("java","net.sf.jasperreports.engine.JRParameter") />
<cfset JRXPathQueryExecuterFactory = createObject("java","net.sf.jasperreports.engine.query.JRXPathQueryExecuterFactory") />

<cfset reportparams["PARAMETER_XML_DATA_DOCUMENT"] = xmlparse(datafile) />
<!--- 
	parameters.put(JRXPathQueryExecuterFactory.PARAMETER_XML_DATA_DOCUMENT, document);
	parameters.put(JRXPathQueryExecuterFactory.XML_DATE_PATTERN, "yyyy-MM-dd");
	parameters.put(JRXPathQueryExecuterFactory.XML_NUMBER_PATTERN, "##,####0.####");
	parameters.put(JRXPathQueryExecuterFactory.XML_LOCALE, Locale.ENGLISH);
	parameters.put(JRParameter.REPORT_LOCALE, Locale.US);
	parameters.put(JRParameter.REPORT_LOCALE, Locale.US);
 --->
