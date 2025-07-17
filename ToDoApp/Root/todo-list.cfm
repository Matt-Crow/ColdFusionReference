<cfset variables.users = createObject("component", "_services.UserService") />

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
    <cfset variables.title = trim(form.title) />
    <cfset variables.description = trim(form.description) />

    <!--- validation --->
    <cfif variables.title eq "">
        <cfset variables.error &= "Title is required. " />
    </cfif>

    <cfif variables.error eq "">
        <cfquery datasource="cf_db">
            INSERT INTO tda.todo_items (creator_user_id, title, description)
            VALUES (
                <cfqueryparam value="#variables.user_id#" cfsqltype="cf_sql_integer" />,
                <cfqueryparam value="#variables.title#" />,
                <cfqueryparam value="#variables.description#" />
            );
        </cfquery>

        <!--- clear form values --->
        <cfset variables.title = "" />
        <cfset variables.description = "" />
    </cfif>
</cfif>

<cfquery datasource="cf_db" name="get_todos">
    SELECT 
        title,
        description,
        date_created
    FROM tda.todo_items
    WHERE creator_user_id = <cfqueryparam value="#variables.user_id#" cfsqltype="cf_sql_integer" />
        AND is_completed = b'0'
    ORDER BY date_created;
</cfquery>

<cfoutput>
    <h2>My Todos</h2>
    <span class="tda-error">
        #encodeForHTML(variables.error)#
    </span>
    <form id="create-todo-form" action="#cgi.request_url#" method="post">
        <div class="tda-form-fields">
            <cfmodule template="../_tags/form_field_row.cfm"
                name="title"
                label="Title"
                type="text"
                value="#variables.title#"
                />
            <cfmodule template="../_tags/form_field_row.cfm"
                name="description"
                label="Description"
                type="text"
                value="#variables.description#"
                />
            <input type="submit" />
        </div>
    </form>
    <table class="tda-table">
        <thead>
            <tr>
                <td>Title</td>
                <td>Description</td>
                <td>Date created</td>
            </tr>
        </thead>
        <tbody>
            <cfloop query="get_todos">
                <tr>
                    <td>#encodeForHtml(get_todos.title)#</td>
                    <td>#encodeForHtml(get_todos.description)#</td>
                    <td>#dateTimeFormat(get_todos.date_created, "short")#</td>
                </tr>
            </cfloop>
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