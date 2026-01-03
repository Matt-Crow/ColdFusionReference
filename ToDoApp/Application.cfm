<!---
    Application.cfm

    Configures the application.
    ColdFusion automatically CFIncludes this file at the start of every page.
--->

<cfapplication 
    name="To Do App"
    />

<cfset application.root = "#cgi.context_path#/Root/" />
<cfset application.debug = false />

<cfinclude template="./Includes/page_start.cfm" />