<cfset variables.users = createObject("component", "_services.UserService") />

<!--- redirect unauthorized users --->
<cfif not variables.users.isUserAdmin() >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<!--- load users --->
<cfquery datasource="cf_db" name="get_users">
    SELECT
        user_id,
        user_name,
        CASE 
            WHEN is_admin = b'1' THEN 'Yes' 
            ELSE 'No' 
        END AS admin_status
    FROM tda.users;
</cfquery>

<!--- display the page --->
<h2>Admin</h2> 

<section style="margin: 1rem;">
    <h3>Users</h3>
    <table class="tda-table">
        <thead>
            <tr>
                <th><!--- checkbox ---></th>
                <th>Name</th>
                <th>Admin</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="get_users">
                <tr>
                    <td><input type="radio" name="user_id" value="<cfoutput encodeFor="htmlattribute">#get_users.user_id#</cfoutput>" /></td>
                    <td><cfoutput encodeFor="html">#get_users.user_name#</cfoutput></td>
                    <td><cfoutput encodeFor="html">#get_users.admin_status#</cfoutput></td>
                </tr>
            </cfloop>
        </tbody>
    </table>
</section>
