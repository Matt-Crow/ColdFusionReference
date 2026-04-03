<cfset variables.username = "" />
<cfset variables.username_error = "" />
<cfset variables.password_error = "" />
<cfset variables.error = "" />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    <cfset variables.username = form.username />

    <!--- server-side validation --->
    <cfset variables.username_error = users.validateUsername(form.username) />
    <cfset variables.password_error = users.validatePassword(form.password) />
    
    <cfif not structKeyExists(url, "token")>
        <cfset variables.error = "Missing URL token." />
    </cfif>

    <cfif variables.error eq "" and variables.username_error eq "" and variables.password_error eq "">

        <cfset variables.users = createObject("component", "_services.UserService") />
        <cfset variables.error = variables.users.handlePasswordReset(form.username, form.password, url.token) />
        <cfif variables.error eq "">
            <cfset variables.message = "Your password has been reset!" />
            <cflocation url="#application.root#index.cfm?message=#encodeForURL(variables.message)#" />
        </cfif>
    </cfif>
</cfif>

<cfoutput>
    <h2>Reset Password</h2>
    <span class="tda-error">#encodeForHTML(variables.error)#</span>
    <form id="reset-password-form" method="post">
        <div class="tda-form-fields">
            <cfmodule template="../_tags/username_field.cfm"
                value="#variables.username#"
                error="#variables.username_error#"
                />
            <cfmodule template="../_tags/password_field.cfm"
                error="#variables.password_error#"
                />
            <input type="submit" />
        </div>
    </form>
</cfoutput>

<!--- client-side validation --->
<script type="module">
    import {addFormValidation, field} from "./static/js/validation.js";
    
    document.addEventListener("DOMContentLoaded", () => {
        addFormValidation(
            "#reset-password-form",
            [
                field("Username", "[name='username']", "#username-error")
                    .matches(/^[a-zA-Z0-9]*$/, "Username may only contain alphanumeric characters.")
                    .length(5, 20),
                field("Password", "[name='password']", "#password-error")
                    .length(5, 20)        
            ]
        );
    });
</script>