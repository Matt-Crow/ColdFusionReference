<cfset variables.users = createObject("component", "_services.UserService") />

<cfset variables.username_error = "" />
<cfset variables.email_error = "" />
<cfset variables.password_error = "" />

<cfset variables.username = "" />
<cfset variables.email = "" />

<!--- check for post request --->
<cfif not structIsEmpty(form)>
    <cfset variables.username = form.username />
    <cfset variables.email = form.email />

    <!--- server-side validation --->
    <cfif len(form.username) lt 5 or len(form.username) gt 20>
        <cfset variables.username_error = "Username must be between 5 and 20 characters." />
    </cfif>
    <cfif reFind("[^a-zA-Z0-9]", form.username)>
        <cfset variables.username_error = "Username may only contain alphanumeric characters." />
    </cfif>
    <cfif not isValid("email", form.email)>
        <cfset variables.email_error = "Email address must be a valid email." />
    </cfif>
    <cfif len(form.password) lt 5 or len(form.password) gt 20>
        <cfset variables.password_error = "Password must be between 5 and 20 characters." />
    </cfif>

    <cfquery name="user_with_that_name" datasource="cf_db">
        SELECT 1
        FROM tda.users
        WHERE LOWER(user_name) = <cfqueryparam value="#lcase(variables.username)#" sqltype="CF_SQL_VARCHAR" maxlength="20" />;
    </cfquery>
    <cfif user_with_that_name.recordCount gt 0>
        <cfset variables.username_error = "That username is already in use." />
    </cfif>

    <cfif variables.username_error eq "" and variables.email_error eq "" and variables.password_error eq "">

        <!---
            In the future, this should send a confirmation email,
            then only create the account once the user clicks a confirmation link in the email.
        --->

        <cfset variables.salt="#hash(generateSecretKey("AES"), "SHA-512")#" />
        <cfset variables.passwordHash=users.hashPassword(password=form.password, salt=variables.salt) />

        <cfquery datasource="cf_db">
            INSERT INTO tda.users (
                user_name,
                email_address,
                password_hash,
                password_salt
            ) VALUES (
                <cfqueryparam value="#variables.username#" />,
                <cfqueryparam value="#variables.email#" />,
                <cfqueryparam value="#variables.passwordHash#" />,
                <cfqueryparam value="#variables.salt#" />
            );
        </cfquery>

        <!--- sign the user in --->
        <cfset variables.users.signIn(variables.username) />
        <cflocation url="#application.root#index.cfm" />
    </cfif>
</cfif>

<h2>Sign up for an account</h2>
<form id="sign-up-form" action="<cfoutput>#cgi.request_url#</cfoutput>" method="post">
    <div class="tda-form-fields">
        <cfmodule template="../_tags/form_field_row.cfm"
            name="username"
            label="Username"
            type="text"
            value="#variables.username#"
            error="#variables.username_error#"
            />
        <cfmodule template="../_tags/form_field_row.cfm"
            name="email"
            label="Email address"
            type="email"
            value="#variables.email#"
            error="#variables.email_error#"
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

<!--- client-side validation --->
<script type="module">
    import {addFormValidation, field} from "./static/js/validation.js";
    
    document.addEventListener("DOMContentLoaded", () => {
        addFormValidation(
            "#sign-up-form",
            [
                field("Username", "[name='username']", "#username-error")
                    .matches(/^[a-zA-Z0-9]*$/, "Username may only contain alphanumeric characters.")
                    .length(5, 20),
                field("Email address", "[name='email']", "#email-error")
                    .required(),
                field("Password", "[name='password']", "#password-error")
                    .length(5, 20)        
            ]
        );
    });
</script>