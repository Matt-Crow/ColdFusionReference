<cfset variables.username = "" />
<cfset variables.error = "" />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    <cfset variables.username = form.username />
    
    <cfset variables.users = createObject("component", "_services.UserService") />
    <cfset variables.error = variables.users.validateSignIn(variables.username, form.password) />
    <cfif variables.error eq "">
        <cfset variables.users.signIn(variables.username) />
        <cflocation url="#application.root#index.cfm" />
    </cfif>
</cfif>

<h2>Sign in</h2>
<span class="tda-error">
    <cfoutput encodeFor="html">#variables.error#</cfoutput>
</span>
<form id="sign-in-form" action="<cfoutput>#cgi.request_url#</cfoutput>" method="post">
    <div class="tda-form-fields">
        <cfmodule template="../_tags/form_field_row.cfm"
            name="username"
            label="Username"
            type="text"
            value="#variables.username#"
            />
        <cfmodule template="../_tags/form_field_row.cfm"
            name="password"
            label="Password"
            type="password"
            <!--- do not embed the password in the response, so don't set value --->
            />
        <input type="submit" />
    </div>
</form>
<a href="<cfoutput>#application.root#</cfoutput>forgot-password.cfm">Forgot Password?</a>

<!--- client-side validation --->
<script type="module">
    import {addFormValidation, field} from "./static/js/validation.js";
    
    document.addEventListener("DOMContentLoaded", () => {
        addFormValidation(
            "#sign-in-form",
            [
                field("Username", "[name='username']", "#username-error")
                    .required(),
                field("Password", "[name='password']", "#password-error")
                    .required()
            ]
        );
    });
</script>