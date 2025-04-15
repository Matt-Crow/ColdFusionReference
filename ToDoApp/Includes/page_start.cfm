<cfset variables.users = createObject("component", "_services.UserService") />

<!DOCTYPE HTML>
<html lang="en-US">
    <head>
        <title>To Do App</title>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width" />

        <link rel="stylesheet" type="text/css" href="<cfoutput>#cgi.context_path#</cfoutput>/Root/static/css/style.css" />
    </head>
    <body>
        <a href="#main-content">Skip to main content</a>
        <header class="tda-site-header">
            <h1>To Do App</h1>
            <cfif variables.users.isUserLoggedIn() >
                <p>Hello, <cfoutput encodeFor="html">#variables.users.getUsername()#</cfoutput></p>
            </cfif>
        </header>
        <nav class="tda-site-navbar">
            <ul>
                <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/index.cfm">Home</a></li>
                <cfif variables.users.isUserLoggedIn() >
                    <li><a href="#">To Do List</a></li>
                    <cfif variables.users.isUserAdmin() >
                        <li><a href="#">Admin</a></li>
                    </cfif>
                    <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/sign-out.cfm">Sign Out</a></li>
                <cfelse />
                    <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/sign-in.cfm">Sign In</a></li>
                    <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/sign-up.cfm">Sign Up</a></li>
                </cfif>
            </ul>
        </nav>
        <main id="main-content" class="tda-site-main">