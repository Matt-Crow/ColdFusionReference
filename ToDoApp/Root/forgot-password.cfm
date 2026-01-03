<cfset username_error = "" />
<cfset message = "" />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    <!--- server-side validation --->
    <cfif len(form.username) eq 0>
        <cfset variables.username_error = "Username is required." />
    </cfif>
    
    <cfif len(variables.username_error) eq 0>
        <cfset users = createObject("component", "_services.UserService") />
        <cftry>
            <cfset password_reset_message = users.handlePasswordResetRequest(trim(form.username)) />
            <cfset message = "If this username exists, check your email inbox for a password reset link." />
            <cfcatch>
                <cfset logger = createObject("component", "_services.LoggingService") />
                <cfset logger.logError(cfcatch, "An error occurred while resetting a password") />
                <cfset message="An error occurred, please try again later." />
            </cfcatch>
        </cftry>
    </cfif>
</cfif>

<!--- display the form --->
<cfoutput>
    <h2>Forgot Password</h2>
    <p>#message#</p>
    <form id="forgot-password-form" action="forgot-password.cfm" method="post">
        <div class="tda-form-fields">
            <cfmodule template="../_tags/form_field_row.cfm"
                name="username"
                label="Username"
                type="text"
                error="#variables.username_error#"
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
            "#forgot-password-form",
            [
                field("Username", "[name='username']", "#username-error")
                    .required()
            ]
        );
    });
</script>