<cfset variables.users = new cfcs.UserService() />

<cfif not variables.users.isUserLoggedIn() >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<cfset variables.username_error = "" />
<cfset variables.email_error = "" />
<cfset variables.success_message = "" />
<cfset variables.user_id = variables.users.getUserId() />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    
    <!--- server-side validation --->
    <cfset variables.username_error = users.validateUsername(form.username) />
    <cfset variables.email_error = users.validateEmailAddress(form.email) />

    <!--- check if they are changing their username --->
    <cfif variables.users.doesUserExist(form.username) and form.username neq users.getUsername()>
        <cfset variables.username_error = "The username '#form.username#' is already in use." />
    </cfif>

    <cfif variables.username_error eq "" and variables.email_error eq "">
        <cfquery datasource="cf_db">
            UPDATE tda.users
            SET
                user_name = <cfqueryparam value="#form.username#" />,
                email_address = <cfqueryparam value="#form.email#" />
            WHERE user_id = <cfqueryparam value="#variables.user_id#" cfsqltype="cf_sql_integer" />;
        </cfquery>
        <cfset session.user.user_name = form.username />
        <cfset variables.success_message = "Your profile has been updated!" />
    </cfif>
</cfif>

<!--- load the user's data --->
<cfquery datasource="cf_db" name="get_user">
    SELECT
        user_name,
        email_address
    FROM tda.users
    WHERE user_id = <cfqueryparam value="#variables.user_id#" cfsqltype="cf_sql_integer" />;
</cfquery>
<cfset variables.username = get_user.user_name />
<cfset variables.email = get_user.email_address />

<!--- display the page --->
<cfoutput>
    <h2>Your Profile</h2>
    <span class="tda-success">#encodeForHtml(variables.success_message)#</span>
    <form id="update-user-form" method="post">
        <div class="tda-form-fields">
            <cfmodule template="../customtags/username_field.cfm"
                value="#variables.username#"
                error="#variables.username_error#"
                />
            <cfmodule template="../customtags/form_field_row.cfm"
                name="email"
                label="Email address"
                type="email"
                value="#variables.email#"
                error="#variables.email_error#"
                />
            <input type="submit" value="Save Changes" />
        </div>
    </form>
</cfoutput>

<!--- client-side validation --->
<script type="module">
    import {addFormValidation, field} from "./static/js/validation.js";
    
    document.addEventListener("DOMContentLoaded", () => {
        addFormValidation(
            "#update-user-form",
            [
                field("Username", "[name='username']", "#username-error")
                    .matches(/^[a-zA-Z0-9]*$/, "Username may only contain alphanumeric characters.")
                    .length(5, 20),
                field("Email address", "[name='email']", "#email-error")
                    .required()      
            ]
        );
    });
</script>