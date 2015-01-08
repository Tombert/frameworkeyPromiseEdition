Frameworkey - Promise Edition
=============================

*Frameworkey is an MVC framework designed around extensive use of Bluebird promises and controller-action composition*

Have you ever felt that the callback model of Node can get kind of tiring?  Have you ever wanted to elegantly chain controller actions "Unix-pipeline-style"?  Have you ever wanted to use the `return` keyword in a web development setting? **If you said yes to any of these questions, try out Frameworkey!**

Frameworkey is written (primarily) using Literate Coffeescript, with a dash of JavaScript and regular CoffeeScript thrown in. 

## Installation
Before using Frameworkey, you must install CoffeeScript.  From there, simply clone the repo and type `npm install`, and you're good to go!


## Running
Run the following command in the console

```
NODE_ENV=<environment_variable> coffee app.litcoffee
```

## Routing
Routing is the main reason Framework was built.  Routes are defined in the `config/routes.coffee` file (you may convert it to regular JavaScript if you'd like).  Routes are done in the format of

```
"METHOD /route" : "ControllerName.ActionName!ControllerName.errorHandler ControllerName.ActionName2 @ ControllerName.catchAllErrorHandler"
```

There are a few things to note here:
- You may attach as many controller-actions to a route as you'd like.
- You may handle errors individually by attaching a `!` followed by the error-handler to the end of the method.
- You may handle errors globally with a `$` followed by the error handler to the end of the chain.
- The results (either returned or promised) of the first function will be passed into the next function, and this will continue until the end of the chain. 
- You may break up your controllers with additional spaces or newlines if you'd like.

### Note about API vs HTML Pages
There is an imposed standard for managing whether a page is an API-style web-service vs a server-rendered web page.  If you'd like to make your page to be an API, make sure your last function returns an object with a `renderType` param with the choices of `HTML` or `JSON` (case insensitive), with the `HTML` type requiring a `page` parameter as well the name of the view you want to be run.  

This might seem frustrating to some people, but generally I just write a couple functions like this: 

```
makeAPI: (renderingItem) ->
	return {renderType: 'json', data: renderingItem}

makeDOM: (renderingItem) ->
      	return {renderType: 'html', data: renderingItem, page: 'testView'}
```

Due to the modular nature of the router, you only have to write these functions once, in one controller, and simply add them to the end of the route chain. 

## Policies

Policies aren't particularly hard to grasp, but are different than most frameworks out there.

Custom policies are defined in the `/policies` folder, and you may have as many as you'd like.

From there, policies can be attached to controllers and actions in the `/config/policies.coffee` file, which should be structured like so

```
	module.exports =
		someController:
			'someAction': ['yourDefinedPolicy']
			'*': 'catchAllPolicy'
```
Some notes about policies:
- You may list several policies in an array.  All the policies must return (or promise) `true` for the request to actually be satisfied.  To decline permission, either reject the Promise, return `false`, or resolve `false`. 
- You may omit using an array if you only have one policy to attach to the action.
- Anything that doesn't have a policy attached to it will fall back to whatever is attached to `*`.

While this is slightly different than tradition, it actually leads to a fairly pleasant programming experience.  Don't knock it before you try it. 
