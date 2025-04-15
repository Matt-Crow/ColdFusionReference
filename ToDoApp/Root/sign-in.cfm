<cfset variables.username = "" />
<cfset variables.error = "" />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    <cfset variables.username = form.username />

    <!--- check the user's credentials --->
    <cfquery name="get_user" datasource="cf_db">
        SELECT
            password_hash,
            password_salt
        FROM tda.users
        WHERE user_name = <cfqueryparam value="#variables.username#" />
        LIMIT 1;
    </cfquery>
    <cfif get_user.recordCount gt 0>

        <!--- username is good, now check password --->
        <cfset variables.users = createObject("component", "_services.UserService") />
        <cfif get_user.password_hash eq variables.users.hashPassword(password=form.password, salt=get_user.password_salt)>
            <cfset variables.users.signIn(variables.username) />
            <cflocation url="#cgi.context_path#/Root/index.cfm" />
        </cfif> 
    </cfif>

    <cfset variables.error = "Incorrect username or password." />
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