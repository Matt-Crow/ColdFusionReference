<cfset variables.username_error = "" />
<cfset variables.password_error = "" />

<cfset variables.username = "" />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    <cfset variables.username = form.username />

    <!--- server-side validation --->
    <cfif len(form.username) lt 5 or len(form.username) gt 20>
        <cfset variables.username_error = "Username must be between 5 and 20 characters." />
    </cfif>
    <cfif reFind("[^a-zA-Z0-9]", form.username)>
        <cfset variables.username_error = "Username may only contain alphanumeric characters." />
    </cfif>
    <cfif len(form.password) lt 5 or len(form.password) gt 20>
        <cfset variables.password_error = "Password must be between 5 and 20 characters." />
    </cfif>

    <!--- todo check if username is already in use --->

    <cfif variables.username_error eq "" and variables.password_error eq "">
        <!--- todo log the user in --->
        <cflocation url="#cgi.context_path#/Root/index.cfm" />
    </cfif>
</cfif>

<h2>Sign up for an account</h2>
<form action="<cfoutput>#cgi.request_url#</cfoutput>" method="post">
    <div class="tda-form-fields">
        <cfmodule template="../_tags/form_field_row.cfm"
            name="username"
            label="Username"
            type="text"
            value="#variables.username#"
            error="#variables.username_error#"
            />
        <cfmodule template="../_tags/form_field_row.cfm"
            name="password"
            label="Password"
            type="password"
            <!--- do not embed the password in the response, so don't set value --->
            error="#variables.password_error#"
            />
        <input type="submit" />
    </div>
</form>