<cfcomponent>

    <!--- logs an error --->
    <cffunction name="logError">
        <cfargument name="error" required />
        <cfargument name="message" default="An error occurred." />

        <!--- write to the log --->
        <cfsavecontent variable="dump">
            <cfdump var="#arguments.error#" />
        </cfsavecontent>
        <cflog text="#arguments.message# #dump#" type="error" />

        <cfif application.debug>
            <cfdump var="#arguments.error#" label="#arguments.message#" />
        </cfif>
    </cffunction>

</cfcomponent>