<cfcomponent>

    <!--- checks whether the user making the current request is logged in --->
    <cffunction name="isUserLoggedIn">
        <cfreturn structKeyExists(session, "user") />
    </cffunction>

    <!--- checks whether the user making the current request is an admin --->
    <cffunction name="isUserAdmin">
        <cfreturn this.isUserLoggedIn() and session.user.is_admin eq "1" />
    </cffunction>

    <!--- gets username, or empty string if not logged in --->
    <cffunction name="getUsername">
        <cfif not this.isUserLoggedIn()>
            <cfreturn "" />
        </cfif>
        <cfreturn session.user.user_name />
    </cffunction>

    <!--- gets user ID, or 0 if not logged in --->
    <cffunction name="getUserId">
        <cfif not this.isUserLoggedIn()>
            <cfreturn 0 />
        </cfif>
        <cfreturn session.user.user_id />
    </cffunction>

    <!--- hashes a user's password --->
    <cffunction name="hashPassword">
        <cfargument name="password" required />
        <cfargument name="salt" required />

        <cfreturn hash(arguments.password & arguments.salt, "SHA-512") />
    </cffunction>

    <!--- sets whether a user is an admin --->
    <cffunction name="setAdmin">
        <cfargument name="user_id" type="number" required />
        <cfargument name="is_admin" type="boolean" required />

        <cfquery datasource="cf_db">
            UPDATE tda.users
            SET is_admin = CASE WHEN <cfqueryparam value="#arguments.is_admin#" cfsqltype="cf_sql_bit" /> THEN b'1' ELSE '0' END
            WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer" />;
        </cfquery>
    </cffunction>

    <!--- sets whether a user is deactivated --->
    <cffunction name="setDeactivated">
        <cfargument name="user_id" type="number" required />
        <cfargument name="is_deactivated" type="boolean" required />

        <cfquery datasource="cf_db">
            UPDATE tda.users
            SET is_deactivated = CASE WHEN <cfqueryparam value="#arguments.is_deactivated#" cfsqltype="cf_sql_bit" /> THEN b'1' ELSE '0' END
            WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer" />;
        </cfquery>
    </cffunction>

    <!--- 
        checks whether the given user can log in
        returns an error message if they cannot
    --->
    <cffunction name="validateSignIn" returntype="string">
        <cfargument name="username" required />
        <cfargument name="password" required />

        <!---
            A few different things to consider:
            1. is the username valid?
            2. is the password valid?
            3. is the user deactivated?
        --->

        <cfquery name="get_user" datasource="cf_db">
            SELECT
                password_hash,
                password_salt,
                is_deactivated
            FROM tda.users
            WHERE user_name = <cfqueryparam value="#arguments.username#" />
            LIMIT 1;
        </cfquery>

        <!--- user not found - for security, don't tell them that --->
        <cfif get_user.recordCount eq 0>
            <cfreturn "Incorrect username or password." />
        </cfif>

        <!--- wrong password - for security, don't tell them that --->
        <cfif get_user.password_hash neq this.hashPassword(arguments.password, get_user.password_salt) >
            <cfreturn "Incorrect username or password." />
        </cfif>

        <!--- block deactivated users --->
        <cfif get_user.is_deactivated>
            <cfreturn "This user is deactivated. Contact an admin for assistance." />
        </cfif>

        <!--- no errors, so return empty string --->
        <cfreturn "" />
    </cffunction>

    <!--- signs in a user --->
    <cffunction name="signIn">
        <cfargument name="username" required />

        <cfquery datasource="cf_db" name="get_user">
            SELECT
                user_id,
                user_name,
                is_admin
            FROM tda.users
            WHERE user_name = <cfqueryparam value="#arguments.username#" />
            LIMIT 1;
        </cfquery>

        <cfset session.user = structNew() />
        <cfset session.user.user_id = get_user.user_id />
        <cfset session.user.user_name = get_user.user_name />
        <cfset session.user.is_admin = get_user.is_admin />
    </cffunction>

    <!--- starts the password reset for the given username --->
    <cffunction name="handlePasswordResetRequest">
        <cfargument name="username" required />


        <!---
            Wait for a bit so the amount of time it takes to reset a valid username and fake username are about the same.
            For example, if it takes 
                0.1 seconds to check if a user exists
                3   seconds to send an email 
                10  seconds to sleep
            without waiting, this is 0.1 vs 3.1 for an invalid vs a valid username, which is noticeable.
            With waiting, this goes to 10.1 vs 13.1, which is less of a drastic difference.
            This prevents malicious users from using the response time to guess which usernames are valid.

            Not sure if this is a good defense, but I thought I'd throw it in there
        --->
        <cfsleep time="10000" />

        <!--- first, we need to check if the user exists --->
        <cfquery datasource="cf_db" name="get_user">
            SELECT 
                email_address,
                password_reset_token_expires,
                is_deactivated
            FROM tda.users
            WHERE user_name = <cfqueryparam value="#arguments.username#" />;
        </cfquery>
        <cfif get_user.recordCount eq 0>
            <cfreturn "User does not exist" />
        </cfif>

        <!--- cannot reset password if deactivated --->
        <cfif get_user.is_deactivated>
            <cfreturn "User is deactivated" />
        </cfif>

        <!--- ensure they don't already have a pending request --->
        <cfif 
            get_user.password_reset_token_expires neq ""
            and
            get_user.password_reset_token_expires gt now()
        >
            <cfreturn "User already has an active password reset request" />
        </cfif>

        <!--- generate a new URL token, then send it via a side-channel, such as email --->
        <cfset url_token = left(hash(generateSecretKey("AES"), "SHA-512"), 40) />
        <cfset url_token_expires = dateAdd("n", 15, now()) />
        
        <cfquery datasource="cf_db">
            UPDATE tda.users
            SET
                password_reset_token = <cfqueryparam value="#url_token#" />,
                password_reset_token_expires = <cfqueryparam value="#url_token_expires#" cfsqltype="cf_sql_timestamp" />
            WHERE user_name = <cfqueryparam value="#arguments.username#" />;
        </cfquery>

        <cfmodule template="../_tags/send_email.cfm" to="#get_user.email_address#" subject="To Do App: Password Reset">
            <cfoutput>
                Hello,

                To Do App has received your request to reset your password.
                <a href="#application.root#reset-password.cfm?token=#url_token#">Click here to reset your password.</a>

                If you did not make this request, you can ignore this email.
            </cfoutput>
        </cfmodule>

        <cfreturn "Sent email" />
    </cffunction>
</cfcomponent>