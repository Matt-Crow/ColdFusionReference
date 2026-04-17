<cfcomponent>
    <cfset this.name = "To Do App" />

    <!--- allow pages to access files outside of root --->
    <cfset this.appBasePath = getDirectoryFromPath(getCurrentTemplatePath()) />
    <cfset this.mappings["/cfcs"] = this.appBasePath & "../cfcs" />

    <!---
        onApplicationStart is called ONCE when the application starts for the first time.
        You may need to restart ColdFusion to pick up changes to this method.
    --->
    <cffunction name="onApplicationStart">
        <cfset application.root = "" />
        <cfset application.debug = false />
    </cffunction>

    <!--- called at the start of each request --->
    <cffunction name="onRequestStart">
        <cfinclude template="../Includes/page_start.cfm" />
    </cffunction>

    <!--- called at the end of each request --->
    <cffunction name="onRequestEnd">
        <cfinclude template="../Includes/page_end.cfm" />
    </cffunction>
</cfcomponent>