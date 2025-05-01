<cfset variables.users = createObject("component", "_services.UserService") />

<!--- redirect unauthorized users --->
<cfif not variables.users.isUserAdmin() >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<!--- check if we need to handle post request --->
<cfif not structIsEmpty(form)>
    <cfif form.action eq "set-admin-yes">
        <cfquery datasource="cf_db">
            UPDATE tda.users
            SET is_admin = b'1'
            WHERE user_id = <cfqueryparam value="#form.user_id#" cfsqltype="cf_sql_integer" />;
        </cfquery>
    <cfelseif form.action eq "set-admin-no">
        <cfquery datasource="cf_db">
            UPDATE tda.users
            SET is_admin = b'0'
            WHERE user_id = <cfqueryparam value="#form.user_id#" cfsqltype="cf_sql_integer" />;
        </cfquery>
    <cfelse>
        <cfthrow message="Unusuppered form action: #form.action#"/>
    </cfif>
</cfif>

<!--- load users --->
<cfquery datasource="cf_db" name="get_users" returnType="array">
    SELECT
        user_id,
        user_name,
        CASE 
            WHEN is_admin = b'1' THEN 'Yes' 
            ELSE 'No' 
        END AS admin_status
    FROM tda.users
    ORDER BY user_id;
</cfquery>

<!--- display the page --->
<h2>Admin</h2> 
<section style="margin: 1rem;">
    <h3>Users</h3>
    <form id="sign-in-form" action="<cfoutput>#cgi.request_url#</cfoutput>" method="post">
        <table class="tda-table">
            <thead>
                <tr>
                    <th><!--- checkbox ---></th>
                    <th>Name</th>
                    <th>Admin</th>
                </tr>
            </thead>
            <tbody>
                <cfloop array="#get_users#" item="user">
                    <tr>
                        <td><input type="radio" name="user_id" value="<cfoutput encodeFor="htmlattribute">#user.user_id#</cfoutput>" /></td>
                        <td><cfoutput encodeFor="html">#user.user_name#</cfoutput></td>
                        <td><cfoutput encodeFor="html">#user.admin_status#</cfoutput></td>
                    </tr>
                </cfloop>
            </tbody>
        </table>
        <p>Selected: <span id="selected-user-name">none</span></p>
        <fieldset id="selected-user-actions" disabled>
            <button name="action" value="set-admin-yes">Make admin</button>
            <button name="action" value="set-admin-no">Make not admin</button>
        </fieldset>
    </form>
</section>

<script type="module">
    // here's a very helpful trick for passing data from ColdFusion to JavaScript
    const users = JSON.parse("<cfoutput encodeFor="javascript">#serializeJSON(get_users)#</cfoutput>");

    document.addEventListener("DOMContentLoaded", () => {
        const userActions = document.querySelector("#selected-user-actions");
        const userRadioButtons = document.querySelectorAll("input[name='user_id']");
        for (const userRadioButton of userRadioButtons) {
            userRadioButton.addEventListener("change", () => {
                userActions.disabled = false;

                const selectedUser = users.find(user => user.user_id.toString() === userRadioButton.value);
                document.querySelector("#selected-user-name").innerText = selectedUser.user_name;
            });
        }
    });
</script>
