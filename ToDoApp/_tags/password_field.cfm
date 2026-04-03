<cfparam name="attributes.error" type="string" default="" />

<cfif thisTag.executionMode eq "end">
    <cfoutput>
        <cfmodule template="form_field_row.cfm"
            name="password"
            label="Password"
            type="password"
            <!--- do not embed the password in the response, so don't set value --->
            error="#attributes.error#"
            />
    </cfoutput>
</cfif>