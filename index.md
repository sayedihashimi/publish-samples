# Web Application Project Deployment Overview for Visual Studio and ASP.NET #

This topic provides an overview of the tasks that are required to publish (deploy) a Visual Studio web application project to a server where others can access the application over the Internet.

- Visual Studio 2012
- Visual Studio Express 2012 for Web
- Visual Studio 2010 with the [Visual Studio Web Publish Update](http://go.microsoft.com/fwlink/?LinkID=208120)
- Visual Web Developer 2010 Express with the [Visual Studio Web Publish Update](http://go.microsoft.com/fwlink/?LinkID=208120)

The topic contains the following sections:

- [Typical Deployment Scenarios](http://msdn.microsoft.com/en-us/library/dd394698#deployment_scenarios)
- [Basic Deployment Tasks](http://msdn.microsoft.com/en-us/library/dd394698#basic_deployment_tasks)
- [Configuring Database Deployment in Visual Studio](http://msdn.microsoft.com/en-us/library/dd394698#dbdeployment)
- [Other Deployment Tasks](http://msdn.microsoft.com/en-us/library/dd394698#other_tasks)
- [Backup and Restore](http://msdn.microsoft.com/en-us/library/dd394698#backup)

Some of the tasks listed here apply only to web application projects. For information about how to deploy web site projects, see [Web Deployment Content Map for Visual Studio and ASP.NET](http://msdn.microsoft.com/en-us/library/bb386521).

# Typical Deployment Scenarios #

You can deploy a web application project by using one-click publish or a deployment package:

- One-click publish refers to a feature in Visual Studio that lets you deploy directly from the Visual Studio IDE by clicking a button. Visual Studio connects to a destination server, copies project files to it, and performs other deployment tasks.

- A web deployment package is a .zip file that contains all the information needed for deployment. You create the package from the command line or in Visual Studio, and you install it on the destination server by using the command line or IIS Manager.

Which of these methods you use depends on your scenario and your personal preference. One-click publish is typically the best choice for smaller organizations that do not implement a continuous integration (CI) development process. You would typically deploy to a hosting company where your application runs either in a shared hosting environment or on a dedicated server. (In a shared hosting environment, a single server is used to host sites for multiple hosting company clients.)

![deploy image](/images/IC372329.png)

***

## Check out our Web Publishing [FAQs](faq.md). ##



***
Sample edit here