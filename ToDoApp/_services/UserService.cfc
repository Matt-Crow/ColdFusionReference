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

    <!--- hashes a user's password --->
    <cffunction name="hashPassword">
        <cfargument name="password" required />
        <cfargument name="salt" required />

        <cfreturn hash(arguments.password & arguments.salt, "SHA-512") />
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
</cfcomponent>