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
</cfcomponent>