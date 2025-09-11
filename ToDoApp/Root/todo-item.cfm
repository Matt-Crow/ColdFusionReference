<!---
    todo-item.cfm
    allows users to view or edit one of their todo items
--->

<cfset variables.users = createObject("component", "_services.UserService") />

<cfif not variables.users.isUserLoggedIn() >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<cfif not structKeyExists(url, "id")>
    <cflocation url="todo-list.cfm" />
    <cfabort />
</cfif>

<cfquery datasource="cf_db" name="get_todo">
    SELECT
        creator_user_id,
        title,
        description,
        is_completed,
        date_created,
        date_completed
    FROM tda.todo_items
    WHERE todo_item_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer" />;
</cfquery>

<!--- verify the user has permission to access it --->
<cfif not get_todo.creator_user_id eq variables.users.getUserId()>
    <cflocation url="todo-list.cfm" />
    <cfabort />
</cfif>

<!--- check if we are handling post --->
<cfif not structIsEmpty(form)>
    <cfquery datasource="cf_db">
        UPDATE tda.todo_items
        SET description = <cfqueryparam value="#form.description#" />
        WHERE todo_item_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer" />;
    </cfquery>

    <!--- go back to list - the value of get_todo.description is outdated now anyway --->
    <cflocation url="todo-list.cfm" />
    <cfabort />
</cfif>


<cfoutput encodeFor="html">
    <h2>#get_todo.title#</h2>
    <form id="update-todo-form" action="#cgi.request_url#" method="post">
        <div class="tda-form-fields">
            <cfmodule template="../_tags/form_field_row.cfm"
                name="description"
                label="Description"
                type="text"
                value="#get_todo.description#"
                />
        </div>
        <p>Created on #dateTimeFormat(get_todo.date_created, "short")#.</p>
        <cfif get_todo.is_completed eq 1>
            <p>Completed on #dateTimeFormat(get_todo.date_completed, "short")#.</p>
        </cfif>
        <input type="submit" value="Save Changes" />
    </form>
</cfoutput>