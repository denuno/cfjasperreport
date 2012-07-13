<cfcomponent>
	
    <cffunction name="validate" returntype="string" output="no"
    	hint="validate a config input value">
        <cfargument name="config" type="struct" required="yes">
    	<cfargument name="name" type="string" required="yes">
        <cfargument name="type" required="no" default="">
        <cfargument name="message" required="no" default="">
        
        
        <cfif len(config[arguments.name]) EQ 0>
        	<cfthrow message="">
        </cfif>
              
                
    </cffunction>
    
    
</cfcomponent>