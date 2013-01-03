<article class="docItem">
<article class="pageCenter">

# How to disable automatic folder permissions updates on publish

## Q: By default during publish folder permissions are set on App_Data. How can I prevent this from happening?

By default we will call the Web Deploy SetAcl provider on the App_Data folder, this behavior is controlled by an MSBuild property, IncludeSetAclProviderOnDestination. The default value for this property is true in *%ProgramFiles32%\MSBuild\Microsoft\VisualStudio\v10.0\Web\Microsoft.Web.Publishing.targets*. If you want to prevent the SetAcl provider from being called you can just set this property to false when publishing. In order to do this follow these steps.

 1. In the same directory as your project create a file with the name {ProjectName}.wpp.targets (*where {ProjectName} is the name of your Web application project*)
 2. Inside the file paste the MSBuild content which is below this list
 3. Reload the project in Visual Studio (VS caches the project files in memory so this cache needs to be cleared).

**{ProjectName}.wpp.targets**

    <?xml version="1.0" encoding="utf-8"?>
    <Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <PropertyGroup>
        <IncludeSetAclProviderOnDestination>false</IncludeSetAclProviderOnDestination>
      </PropertyGroup>    
    </Project>


Inside of this file you can see that I'm declaring that property and setting it's value to False. After you have this file it will automatically be picked up by our publishing process, both from Visual Studio as well as any publish operations from the command line.

Can you try that out and let me know if you have further issues?


</article>
</article>