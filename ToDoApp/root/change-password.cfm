<cfset variables.users = new cfcs.UserService() />

<cfif not variables.users.isUserLoggedIn() >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<cfset variables.password_error = "" />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    
    <!--- server-side validation --->
    <cfset variables.password_error = variables.users.validatePassword(form.password) />
    
    <cfif variables.password_error eq "">
        <cfset variables.username = variables.users.getUsername() />
        
        <cfset variables.users.setPassword(variables.username, form.password) />

        <cfset variables.message = "Your password has been changed!" />
        <cflocation url="#application.root#index.cfm?message=#encodeForURL(variables.message)#" />
    </cfif>
</cfif>

<!--- display the page --->
<cfoutput>
    <h2>Change Password</h2>
    <form id="change-password-form" method="post">
        <div class="tda-form-fields">
            <cfmodule template="../customtags/password_field.cfm"
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
            "#change-password-form",
            [
                field("Password", "[name='password']", "#password-error")
                    .length(5, 20)        
            ]
        );
    });
</script>