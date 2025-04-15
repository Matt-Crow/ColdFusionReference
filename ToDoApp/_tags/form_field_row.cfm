<!---
    form_field_row.cfm
    Displays a row in a form with a label, form field, and error section.
--->

<cfparam name="attributes.name" type="string" />
<cfparam name="attributes.label" type="string" />
<cfparam name="attributes.type" type="string" />
<cfparam name="attributes.value" type="string" default="" />
<cfparam name="attributes.error" type="string" default="" />

<cfif thisTag.executionMode eq "end">
    <cfoutput>
        <label for="#attributes.name#">#attributes.label#</label>
        <input type="#attributes.type#" id="#attributes.name#" name="#attributes.name#" value="#encodeForHTMLAttribute(attributes.value)#" />
        <span class="tda-error" id="#attributes.name#-error">#attributes.error#</span>
    </cfoutput>
</cfif>