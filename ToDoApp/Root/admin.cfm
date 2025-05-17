<cfset variables.users = createObject("component", "_services.UserService") />

<!--- redirect unauthorized users --->
<cfif not variables.users.isUserAdmin() >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<!--- check if we need to handle post request --->
<cfif not structIsEmpty(form)>
    <cfset variables.users.setAdmin(form.user_id, structKeyExists(form, "is-admin")) />
    <cfset variables.users.setDeactivated(form.user_id, structKeyExists(form, "is-deactivated")) />
</cfif>

<!--- load users --->
<cfquery datasource="cf_db" name="get_users" returnType="array">
    SELECT
        user_id,
        user_name,
        CASE 
            WHEN is_admin = b'1' THEN 'Yes' 
            ELSE 'No' 
        END AS admin_status,
        CASE
            WHEN is_deactivated = b'1' THEN 'No'
            ELSE 'Yes'
        END AS active_status
    FROM tda.users
    ORDER BY
        is_deactivated,
        user_name;
</cfquery>

<!--- display the page --->
<cfoutput>
    <h2>Admin</h2> 
    <section style="margin: 1rem;">
        <h3>Users</h3>
        <form action="#encodeForHtmlAttribute(cgi.request_url)#" method="post">
            <table class="tda-table">
                <thead>
                    <tr>
                        <th><!--- checkbox ---></th>
                        <th>Name</th>
                        <th>Admin</th>
                        <th>Active</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop array="#get_users#" item="user">
                        <tr>
                            <td><input type="radio" name="user_id" value="#encodeForHtmlAttribute(user.user_id)#" /></td>
                            <td>#encodeForHtml(user.user_name)#</td>
                            <td>#encodeForHtml(user.admin_status)#</td>
                            <td>#encodeForHtml(user.active_status)#</td>
                        </tr>
                    </cfloop>
                </tbody>
            </table>
            <br />
            <fieldset id="selected-user-actions" disabled>
                <legend>Selected user: <span id="selected-user-name">none</span></legend>
                <div class="tda-form-fields">
                    <cfmodule template="../_tags/form_field_row.cfm"
                        name="is-admin"
                        label="Admin"
                        type="checkbox"
                        />
                    <cfmodule template="../_tags/form_field_row.cfm"
                        name="is-deactivated"
                        label="Deactivated"
                        type="checkbox"
                        />
                </div>
                <button value="submit">Submit</button>
            </fieldset>
        </form>
    </section>
</cfoutput>

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
                document.querySelector("#is-admin").checked = selectedUser.admin_status === "Yes";
                document.querySelector("#is-deactivated").checked = selectedUser.active_status === "No";
            });
        }
    });
</script>