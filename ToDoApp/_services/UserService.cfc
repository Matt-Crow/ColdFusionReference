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
        <cfargument name="password" />
        <cfargument name="salt" />

        <cfreturn hash(arguments.password & arguments.salt, "SHA-512") />
    </cffunction>

    <!--- signs in a user --->
    <cffunction name="signIn">
        <cfargument name="username" />

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