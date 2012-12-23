<cfcomponent displayname="TestTag"  extends="mxunit.framework.TestCase">

	<cfimport taglib="/cfjasperreport/tag/cfjasperreport" prefix="jr" />

	<cffunction name="beforeTests" returntype="void" access="public">
		<cfset workpath = "#getDirectoryFromPath(getMetadata(this).path)#../../data/work" />
		<cftry>
			<cfset directoryDelete(workpath,true) />
			<cfcatch></cfcatch>
		</cftry>
		<cfset directoryCreate(workpath) />

		<cfset datapath = "#getDirectoryFromPath(getMetadata(this).path)#../../data" />
		<cftry>
			<jr:jasperreport jrxml="#datapath#/simpleTest.jrxml" exportfile="/tmp/delme.pdf" exporttype="pdf"/>
			<cfcatch>
				<cfif cfcatch.type == "cfjasperreport.filenotfound">
				<cfthrow message="test data dir incorrect! : #datapath#/test.jrxml" />
				</cfif>
				<cfset debug(cfcatch) />
				<cfif findNoCase("is not defined in directory",cfcatch.message) OR
						findNoCase("no definition for the class",cfcatch.message)>
					<cfset install = createObject("component","tests.cfjasperreport.extension.TestInstall") />
					<cfset install.beforeTests() />
					<cfset install.setUp() />
					<cfset install.testInstallDevCustomTag(uninstall=false) />
					<cfadmin action="restart"
						type="server"
						password="#session.passwordserver#"
						remoteClients=""/>
					<cfthrow message="had to install the tag.  Try again now" detail="had to install the tag.  Try again now. (#cfcatch.message#)">
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setUp" returntype="void" access="public">
		<cfset variables.defaultconfig = {"mixed":{"isBuiltInTag":true,"installTestPlugin":true}} />
 	</cffunction>

	<cffunction name="teardown" returntype="void" access="public">
	</cffunction>

	<cffunction name="testjasperreportsFileNotFound">
		<cftry>
			<jr:jasperreport jrxml="#datapath#/not-here.jrxml" dsn="jasperreport" exportfile="#workpath#/idcards-dsn.pdf" exporttype="pdf"/>
			<cfcatch>
				<cfset assertEquals("cfjasperreport.filenotfound",cfcatch.type)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="testjasperreportsTagPdf">
		<jr:jasperreport jrxml="#datapath#/test.jrxml" exportfile="#workpath#/rockn.pdf" exporttype="pdf"/>
	</cffunction>

	<cffunction name="testjasperreportsTagAvery5160Pdf">
		<jr:jasperreport jrxml="#datapath#/avery5160.jrxml" exportfile="#workpath#/avery5160.pdf" exporttype="pdf"/>
	</cffunction>

	<cffunction name="testjasperreportsCFQueryTagAvery5160BarcodePdf">
		<cfset variables.defaultconfig = {"mixed":{"isBuiltInTag":true,"installTestPlugin":true}} />
		<cfset var myQuery = QueryNew("")>
		<cfset var idArray = ArrayNew(1)>
		<cfset idArray[1] = "111111">
		<cfset idArray[2] = "222222">
		<cfset idArray[3] = "333333">
		<cfset idArray[4] = "444444">
		<cfset idArray[5] = "555555">
		<cfset nColumnNumber = QueryAddColumn(myQuery, "personId", "Integer",idArray)>
		<cfset var FastFoodArray = ArrayNew(1)>
		<cfset FastFoodArray[1] = "French Fries">
		<cfset FastFoodArray[2] = "Hot Dogs">
		<cfset FastFoodArray[3] = "Fried Clams">
		<cfset FastFoodArray[4] = "Thick Shakes">
		<cfset FastFoodArray[5] = "Shick Shakes">
		<cfset nColumnNumber = QueryAddColumn(myQuery, "FastFood", "VarChar",FastFoodArray)>
		<cfset var FineCuisineArray = ArrayNew(1)>
		<cfset FineCuisineArray[1] = "Lobster">
		<cfset FineCuisineArray[2] = "Flambe">
		<cfset FineCuisineArray[3] = "Tlambe">
		<cfset FineCuisineArray[4] = "Slambe">
		<cfset FineCuisineArray[5] = "Alambe">
		<cfset nColumnNumber2 = QueryAddColumn(myQuery, "FineCuisine", "VarChar",FineCuisineArray)>
		<cfset var HealthFoodArray = ArrayNew(1)>
		<cfset HealthFoodArray[1] = "Bean Curd">
		<cfset HealthFoodArray[2] = "Yogurt">
		<cfset HealthFoodArray[3] = "Tofu">
		<cfset HealthFoodArray[4] = "Sofu">
		<cfset HealthFoodArray[5] = "Aofu">
		<cfset nColumnNumber3 = QueryAddColumn(myQuery, "HealthFood", "VarChar",HealthFoodArray)>
		<jr:jasperreport jrxml="#datapath#/cfqueryFood.jrxml" query="#myQuery#" exportfile="#workpath#/cfqueryFood.pdf" exporttype="pdf"/>
	</cffunction>

	<cffunction name="testjasperreportsTagAvery5160BarcodePdf">
		<cfset var myQuery = QueryNew("")>
		<cfset var idArray = ArrayNew(1)>
		<cfset idArray[1] = "1">
		<cfset idArray[2] = "2">
		<cfset idArray[3] = "3">
		<cfset idArray[4] = "4">
		<cfset idArray[5] = "5">
		<cfset nColumnNumber = QueryAddColumn(myQuery, "personId", "Integer",idArray)>
		<cfset var FastFoodArray = ArrayNew(1)>
		<cfset FastFoodArray[1] = "French Fries">
		<cfset FastFoodArray[2] = "Hot Dogs">
		<cfset FastFoodArray[3] = "Fried Clams">
		<cfset FastFoodArray[4] = "Thick Shakes">
		<cfset FastFoodArray[5] = "Shick Shakes">
		<cfset nColumnNumber = QueryAddColumn(myQuery, "firstName", "VarChar",FastFoodArray)>
		<cfset var FineCuisineArray = ArrayNew(1)>
		<cfset FineCuisineArray[1] = "Lobster">
		<cfset FineCuisineArray[2] = "Flambe">
		<cfset FineCuisineArray[3] = "Tlambe">
		<cfset FineCuisineArray[4] = "Slambe">
		<cfset FineCuisineArray[5] = "Alambe">
		<cfset nColumnNumber2 = QueryAddColumn(myQuery, "lastName", "VarChar",FineCuisineArray)>
		<cfset var HealthFoodArray = ArrayNew(1)>
		<cfset HealthFoodArray[1] = "Bean Curd">
		<cfset HealthFoodArray[2] = "Yogurt">
		<cfset HealthFoodArray[3] = "Tofu">
		<cfset HealthFoodArray[4] = "Sofu">
		<cfset HealthFoodArray[5] = "Aofu">
		<cfset nColumnNumber3 = QueryAddColumn(myQuery, "HealthFood", "VarChar",HealthFoodArray)>
		<jr:jasperreport jrxml="#datapath#/avery5160.jrxml" query="#myQuery#" exportfile="#workpath#/avery5160.pdf" exporttype="pdf"/>
	</cffunction>

	<cffunction name="testjasperreportsTagBarcodePdf">
		<jr:jasperreport jrxml="#datapath#/barcode.jrxml" exportfile="#workpath#/barcode.pdf" exporttype="pdf"/>
	</cffunction>

	<cffunction name="testjasperreportsTagXls">
		<jr:jasperreport jrxml="#datapath#/test.jrxml" exportfile="#workpath#/rockn.xls" exporttype="xls"/>
	</cffunction>

	<cffunction name="testjasperreportsTagUTF8">
		<jr:jasperreport jrxml="#datapath#/testUTF.jrxml" exportfile="#workpath#/rockn.pdf" exporttype="pdf"/>
	</cffunction>

</cfcomponent>
