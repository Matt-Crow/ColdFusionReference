<!---
    todo-item.cfm
    allows users to view, edit, or delete one of their todo items
--->

<cfset variables.users = createObject("component", "_services.UserService") />
<cfset variables.todos = createObject("component", "_services.TodoService").init(variables.users) />
<cfset variables.error = "" />

<cfif not structKeyExists(url, "id")>
    <cflocation url="todo-list.cfm" />
    <cfabort />
</cfif>

<!--- verify the user has permission to access it --->
<cfif not variables.todos.isUserAllowedToTouch(url.id) >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<cfquery datasource="cf_db" name="get_todo">
    SELECT
        title,
        description,
        is_completed,
        date_created,
        date_completed
    FROM tda.todo_items
    WHERE todo_item_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer" />;
</cfquery>

<!--- check if we are handling post --->
<cfif not structIsEmpty(form)>
    <cfif form.action eq "update">
        <cfquery datasource="cf_db">
            UPDATE tda.todo_items
            SET description = <cfqueryparam value="#form.description#" />
            WHERE todo_item_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer" />;
        </cfquery>

        <!--- go back to list - the value of get_todo.description is outdated now anyway --->
        <cflocation url="todo-list.cfm" />
        <cfabort />
    <cfelseif form.action eq "complete">
        <cfset variables.error = variables.todos.completeTodoItemById(url.id) />
        <cfif variables.error eq "">
            <cflocation url="todo-list.cfm" />
            <cfabort />
        </cfif>
    <cfelseif form.action eq "delete">
        <cfset variables.error = variables.todos.deleteTodoItemById(url.id) />
        <cfif variables.error eq "">
            <cflocation url="todo-list.cfm" />
            <cfabort />
        </cfif>
    </cfif>
</cfif>


<cfoutput encodeFor="html">
    <h2>#get_todo.title#</h2>
    <span class="tda-error">#encodeForHtml(variables.error)#</span>
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
        <button name="action" value="update">Save Changes</button>
        <button name="action" value="complete">Complete</button>
        <button name="action" value="delete" class="tda-button-delete">Delete</button>
    </form>
</cfoutput>