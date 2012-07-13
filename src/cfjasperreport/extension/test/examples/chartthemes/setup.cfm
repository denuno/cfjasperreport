<cfset thisDir = getDirectoryFromPath(getCurrentTemplatePath()) />
<cfset resourcebundle = thisDir & "reports/AllCharts.properties" />
<cfloop from="1" to="7" index="i">
	<cf_jasperreport action="jrdatasource" datasource="#thisdir#/data/categoryDatasource.csv" resultsvar="ds">
	<cfset ds.setUseFirstRowAsHeader(true) />
	<cfset reportparams["categoryDatasource#i#"] = ds />
</cfloop>
<cfloop from="1" to="2" index="i">
	<cf_jasperreport action="jrdatasource" datasource="#thisdir#/data/pieDatasource.csv" resultsvar="ds">
	<cfset ds.setUseFirstRowAsHeader(true) />
	<cfset reportparams["pieDatasource#i#"] = ds />
</cfloop>
<cf_jasperreport action="jrdatasource" datasource="#thisdir#/data/timePeriodDatasource.csv" resultsvar="ds">
	<cfset ds.setUseFirstRowAsHeader(true) />
<cfset reportparams["timePeriodDatasource1"] = ds />
<cfloop from="1" to="3" index="i">
	<cf_jasperreport action="jrdatasource" datasource="#thisdir#/data/timeSeriesDatasource.csv" resultsvar="ds">
	<cfset ds.setUseFirstRowAsHeader(true) />
	<cfset reportparams["timeSeriesDatasource#i#"] = ds />
</cfloop>
<cfloop from="1" to="5" index="i">
	<cf_jasperreport action="jrdatasource" datasource="#thisdir#/data/xyDatasource.csv" resultsvar="ds">
	<cfset ds.setUseFirstRowAsHeader(true) />
	<cfset reportparams["xyDatasource#i#"] = ds />
</cfloop>

<!--- 
	<parameter name="categoryDatasource1" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="categoryDatasource2" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="categoryDatasource3" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="categoryDatasource4" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="categoryDatasource5" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="categoryDatasource6" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="categoryDatasource7" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="pieDatasource1" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="pieDatasource2" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="timePeriodDatasource1" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="timeSeriesDatasource1" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="timeSeriesDatasource2" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="timeSeriesDatasource3" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="xyDatasource1" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="xyDatasource2" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="xyDatasource3" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="xyDatasource4" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	<parameter name="xyDatasource5" class="net.sf.jasperreports.engine.data.JRCsvDataSource"/>
	--->
<!--- 
	<cfset font = createObject("java","java.awt.Font") />
	<cfset ge = createObject("java","java.awt.GraphicsEnvironment").getLocalGraphicsEnvironment() />
	<cfset fontFile = createObject("java","java.io.File").init("/workspace/railotags/src/cfjasperreport/src/extension/test/examples/charts/fonts/dejavu/DejaVuSerif.ttf") />
	<cfdump var="#fontfile.exists()#">
	<cfset ge.registerFont(font.createFont(font.TRUETYPE_FONT, fontFile)) />
	--->
