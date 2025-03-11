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
        </header>
        <nav class="tda-site-navbar">
            <ul>
                <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/index.cfm">Home</a></li>
                <li><a href="#">To Do List</a></li>
                <li><a href="#">Admin</a></li>
                <li><a href="#">Sign In</a></li>
                <li><a href="<cfoutput>#cgi.context_path#</cfoutput>/Root/sign-up.cfm">Sign Up</a></li>
            </ul>
        </nav>
        <main id="main-content" class="tda-site-main">