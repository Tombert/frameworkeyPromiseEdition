Frameworkey - Promise Edition
=========================

Promise based Express Server 
Framework, CMS

## Notes
Init app.coffee

1) Determine Routing - requestProcessor()

Concept is that routing is promised based. Controllers can prepends promises in the constructor prior to actual route function. There is one dedicated promise appended to the que that resolves the response to the user. It returns a HTML document or JSON.

@future
Admin Control Panel for Page Management, User Management, Feedback Form, etc.

@todo
Figure out a plugin system where sets of functionality are components 

