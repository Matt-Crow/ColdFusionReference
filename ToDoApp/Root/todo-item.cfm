<!---
    todo-item.cfm
    allows users to view, edit, or delete one of their todo items
--->

<cfset variables.users = new cfcs.UserService() />
<cfset variables.todos = new cfcs.TodoService().init(variables.users) />
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

<cfset variables.get_todo = variables.todos.getMyTodoItemById(url.id) />
<cfif isNull(variables.get_todo)>
    <cflocation url="todo-list.cfm" />
    <cfabort />
</cfif>

<!--- check if we are handling post --->
<cfif not structIsEmpty(form)>
    <cfif form.action eq "update">
        <cfset variables.error = variables.todos.updateTodoItemDescription(url.id, trim(form.description)) />
    <cfelseif form.action eq "complete">
        <cfset variables.error = variables.todos.completeTodoItemById(url.id) />
    <cfelseif form.action eq "delete">
        <cfset variables.error = variables.todos.deleteTodoItemById(url.id) />
    <cfelse>
        <cfset variables.error = "Invalid action: ""#form.action#""." />
    </cfif>

    <cfif variables.error eq "">
        <cflocation url="todo-list.cfm" />
        <cfabort />
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
        <button name="action" value="delete" class="tda-button-delete">Delete</button>
        <cfif get_todo.is_completed eq 0>
            <button name="action" value="complete">Complete</button>
        </cfif>
    </form>
</cfoutput>