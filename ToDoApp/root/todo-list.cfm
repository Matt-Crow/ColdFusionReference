<cfset variables.users = new cfcs.UserService() />
<cfset variables.todos = new cfcs.TodoService().init(variables.users) />

<cfif not variables.users.isUserLoggedIn() >
    <cflocation url="#application.root#index.cfm" />
    <cfabort />
</cfif>

<cfset variables.user_id = variables.users.getUserId() />
<cfset variables.title = "" />
<cfset variables.description = "" />
<cfset variables.error = "" />

<!--- check if we need to handle post request --->
<cfif not structIsEmpty(form)>
    
    <!--- check whether we're handling a create or a delete --->
    <cfif structKeyExists(form, "delete")>
        <cfset variables.error = variables.todos.deleteTodoItemById(form.delete) />
    <cfelseif structKeyExists(form, "completed")>
        <cfset variables.error = variables.todos.completeTodoItemById(form.completed) />
    <cfelse>
        <cfset variables.title = trim(form.title) />
        <cfset variables.description = trim(form.description) />
        <cfset variables.error = variables.todos.createTodoItem(variables.title, variables.description) />

        <cfif variables.error eq "">

            <!--- clear form values --->
            <cfset variables.title = "" />
            <cfset variables.description = "" />
        </cfif>
    </cfif>
</cfif>

<cfset variables.get_todos = variables.todos.getMyTodoItems() />

<cfoutput>
    <h2>My Todos</h2>
    <span class="tda-error">
        #encodeForHTML(variables.error)#
    </span>
    <form id="create-todo-form" method="post">
        <div class="tda-form-fields">
            <cfmodule template="../customtags/form_field_row.cfm"
                name="title"
                label="Title"
                type="text"
                value="#variables.title#"
                />
            <cfmodule template="../customtags/form_field_row.cfm"
                name="description"
                label="Description"
                type="text"
                value="#variables.description#"
                />
            <input type="submit" name="create" />
        </div>
    </form>
    <table class="tda-table">
        <thead>
            <tr>
                <td>Title</td>
                <td>Description</td>
                <td>Date created</td>
                <td>Date completed</td>
                <td>Action</td>
            </tr>
        </thead>
        <tbody>
            <form method="post">
                <cfloop query="get_todos">
                    <tr>
                        <td><a href="todo-item.cfm?id=#encodeForHtmlAttribute(get_todos.todo_item_id)#">#encodeForHtml(get_todos.title)#</a></td>
                        <td>#encodeForHtml(get_todos.description)#</td>
                        <td>#dateTimeFormat(get_todos.date_created, "short")#</td>
                        <td>#dateTimeFormat(get_todos.date_completed, "short")#</td>
                        <td>
                            <button name="delete" value="#encodeForHtmlAttribute(get_todos.todo_item_id)#" class="tda-button-delete">Delete</button>
                            <cfif get_todos.date_completed eq "">
                                <button name="completed" value="#encodeForHtmlAttribute(get_todos.todo_item_id)#">Complete</button>
                            </cfif>
                        </td>
                    </tr>
                </cfloop>
            </form>
        </tbody>
    </table>
</cfoutput>

<!--- client-side validation --->
<script type="module">
    import {addFormValidation, field} from "./static/js/validation.js";
    
    document.addEventListener("DOMContentLoaded", () => {
        addFormValidation(
            "#create-todo-form",
            [
                field("Title", "[name='title']", "#title-error")
                    .required()
            ]
        );
    });
</script>