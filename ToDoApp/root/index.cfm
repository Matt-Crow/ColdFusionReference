<cfparam name="url.message" default="" />
<cfoutput>
    <span class="tda-success">#encodeForHTML(decodeFromURL(url.message))#</span>
    <p>Welcome to the To Do App!</p>
    <p>On this website, you can track items that need to be done, either by you or your team.</p>
    <p>To get started, log in or sign up using the link above.</p>
</cfoutput>