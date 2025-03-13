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
            <cfif structKeyExists(session, "user") >
                <p>Hello, <cfoutput encodeFor="html">#session.user.user_name#</cfoutput></p>
            </cfif>
        </header>
        <nav class="tda-site-navbar">
            <ul>
                <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/index.cfm">Home</a></li>
                <cfif structKeyExists(session, "user") >
                <li><a href="#">To Do List</a></li>
                    <cfif session.user.is_admin eq '1'>
                <li><a href="#">Admin</a></li>
                    </cfif>
                    <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/sign-out.cfm">Sign Out</a></li>
                <cfelse />
                <li><a href="#">Sign In</a></li>
                <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/sign-up.cfm">Sign Up</a></li>
                </cfif>
            </ul>
        </nav>
        <main id="main-content" class="tda-site-main">