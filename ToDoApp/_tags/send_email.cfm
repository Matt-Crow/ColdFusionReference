<!---
    send_email.cfm
    Wrapper around cfmail
--->

<cfparam name="attributes.to" />
<cfparam name="attributes.subject" />
<cfparam name="attributes.type" default="html" />

<cfif thisTag.executionMode eq "end">

    <!--- prevent output from showing on screen --->
    <cfset emailContent = thisTag.generatedContent />
    <cfset thisTag.generatedContent = "" />

    <cfmail
        from="noreply@todoapp.com"
        to="#attributes.to#"
        subject="#attributes.subject#"
        type="#attributes.type#"
    >
        <cfoutput>#emailContent#</cfoutput>
    </cfmail>
</cfif>