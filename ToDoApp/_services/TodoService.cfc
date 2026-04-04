<!---
    TodoService
    Provides services related to todo items
--->
<cfcomponent>

    <!--- depends on an instance of UserService --->
    <cffunction name="init">
        <cfargument name="users" required />

        <cfset this.users = arguments.users />

        <cfreturn this />
    </cffunction>

    <!--- checks whether the logged in user can touch a given todo item --->
    <cffunction name="isUserAllowedToTouch">
        <cfargument name="todo_item_id" />

        <cfif not this.users.isUserLoggedIn()>
            <cfreturn false />
        </cfif>

        <cfset variables.user_id = this.users.getUserId() />
        <cfquery datasource="cf_db" name="get_todo_item">
            SELECT 1
            FROM tda.todo_items
            WHERE todo_item_id = <cfqueryparam value="#arguments.todo_item_id#" cfsqltype="cf_sql_integer" />
                AND creator_user_id = <cfqueryparam value="#variables.user_id#" cfsqltype="cf_sql_integer" />;
        </cfquery>
        <cfif get_todo_item.recordCount eq 0>
            <cfreturn false />
        </cfif>

        <cfreturn true />
    </cffunction>

    <!---
        Deletes the todo item with the given ID.
        Returns an error message,
        or an empty string on success.
    --->
    <cffunction name="deleteTodoItemById">
        <cfargument name="todo_item_id" type="number" required />

        <cfif not this.isUserAllowedToTouch(arguments.todo_item_id)>
            <cfreturn "You are not authorized to delete this todo item." />
        </cfif>

        <cfquery datasource="cf_db">
            DELETE FROM tda.todo_items
            WHERE todo_item_id = <cfqueryparam value="#arguments.todo_item_id#" cfsqltype="cf_sql_integer" />;
        </cfquery>

        <cfreturn "" />
    </cffunction>

    <!---
        Flags the todo item with the given ID as complete.
        Returns an error message,
        or an empty string on success.
    --->
    <cffunction name="completeTodoItemById">
        <cfargument name="todo_item_id" type="number" required />
        
        <cfif not this.isUserAllowedToTouch(arguments.todo_item_id)>
            <cfreturn "You are not authorized to delete this todo item." />
        </cfif>

        <cfquery datasource="cf_db">
            UPDATE tda.todo_items
            SET
                is_completed = b'1',
                date_completed = CURRENT_TIMESTAMP
            WHERE todo_item_id = <cfqueryparam value="#arguments.todo_item_id#" cfsqltype="cf_sql_integer" />
                AND date_completed IS NULL;
        </cfquery>

        <cfreturn "" />
    </cffunction>
</cfcomponent>