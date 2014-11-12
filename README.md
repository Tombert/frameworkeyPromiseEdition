Frameworkey - Promise Edition
=========================
*Frameworkey is an MVC framework designed around extensive use of Bluebird promises.*

Have you ever felt that the callback model of Node can get kind of tiring?  Have you ever wanted to elegantly chain controller actions "Unix-pipeline-style"?  Have you ever wanted to use the `return` keyword in a web development setting? **If you said yes to any of these questions, try out Frameworkey!**

## Installation
Before using Frameworkey, you must install CoffeeScript.

## Running
Run the following command in the console
```
coffee app.coffee
```
## Notes

#### 1) Determine Routing - processRequest( request )

Routing is promised based. Controllers can prepends promises in the constructor prior to actual route function. There is one dedicated promise appended to the que that resolves the response to the user. It returns a HTML document or JSON.

#### 2) Map Request to Route

#### 3) Santize Input

#### 4) Pass clean input (unless fails sanity test) to promised controller function

#### 5) Process que of promises

#### 6) End of que has 1 last promise that returns a HTML response or JSON

## Thoughts
Controller processes models. 

event -> dynamic construction of promise chain -> resolve

###### @future
Admin Control Panel for Page Management, User Management, Feedback Form, etc.

###### @todo
Figure out a plugin system where sets of functionality are components (promised based?). Plugins are pre-made que's of actions. You can then mix/match actions from plugins

