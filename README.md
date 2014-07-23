Frameworkey - Promise Edition
=========================

Promise based Express Server 
Framework, CMS

## Notes

#### 1) Determine Routing - processRequest( request )

Routing is promised based. Controllers can prepends promises in the constructor prior to actual route function. There is one dedicated promise appended to the que that resolves the response to the user. It returns a HTML document or JSON.

#### 2) Map Request to Route

#### 3) Santize Input

#### 4) Pass clean input (unless fails sanity test) to promised controller function

#### 5) Process que of promises

#### 6) End of que has 1 last promise that returns a HTML response or JSON

###### @future
Admin Control Panel for Page Management, User Management, Feedback Form, etc.

###### @todo
Figure out a plugin system where sets of functionality are components (promised based?)

