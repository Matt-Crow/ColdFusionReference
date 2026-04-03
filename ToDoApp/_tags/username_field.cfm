<cfparam name="attributes.value" type="string" default="" />
<cfparam name="attributes.error" type="string" default="" />

<cfif thisTag.executionMode eq "end">
    <cfoutput>
        <cfmodule template="form_field_row.cfm"
            name="username"
            label="Username"
            type="text"
            value="#attributes.value#"
            error="#attributes.error#"
            />
    </cfoutput>
</cfif>