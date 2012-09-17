# How to set permissions on a folder during publish

## Q: How can I set permissions on a folder when I publish my web project using MSBuild and MSDeploy?

OK let me first say that this is way harder than it should be!

I think the reason why it is failing is because when you are publishing it cannot recognize the folder as being a folder in the IIS Application. The reason this is happening is because the full path is being transferred to the destination when the SetAcl provider is invoked. Instead of that we need an path which is relative to the IIS Application. For instance in your case it should be something like : "REST SERVICES/1.0.334/doc/public". The only way to do this is to create an MSDeploy parameter which gets populated with the correct value at publish time. You will have to do this in addition to creating your own SetAcl entry in the source manifest. Follow the steps below.

 1. In the same directory as your project create a file with the name {ProjectName}.wpp.targets (where {ProjectName} is the name of your Web application project)
 2. Inside the file paste the MSBuild content which is below this list
 3. Reload the project in Visual Studio (VS caches the project files in memory so this cache needs to be cleared).

**{ProjectName}.wpp.targets**

    <?xml version="1.0" encoding="utf-8"?>
    <Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      
      <Target Name="SetupCustomAcls" AfterTargets="AddIisSettingAndFileContentsToSourceManifest">   
        <!-- This must be declared inside of a target because the property 
        $(_MSDeployDirPath_FullPath) will not be defined at that time. -->
        <ItemGroup>
          <MsDeploySourceManifest Include="setAcl">
            <Path>$(_MSDeployDirPath_FullPath)\doc\public</Path>
            <setAclAccess>Read,Write,Modify</setAclAccess>
            <setAclResourceType>Directory</setAclResourceType>
            <AdditionalProviderSettings>setAclResourceType;setAclAccess</AdditionalProviderSettings>
          </MsDeploySourceManifest>
        </ItemGroup>
      </Target>
    
      <Target Name="DeclareCustomParameters" AfterTargets="AddIisAndContentDeclareParametersItems">
        <!-- This must be declared inside of a target because the property 
        $(_EscapeRegEx_MSDeployDirPath) will not be defined at that time. -->
        <ItemGroup>
          <MsDeployDeclareParameters Include="DocPublicSetAclParam">
            <Kind>ProviderPath</Kind>
            <Scope>setAcl</Scope>
            <Match>^$(_EscapeRegEx_MSDeployDirPath)\\doc\\public$</Match>
            <Value>$(_DestinationContentPath)/doc/public</Value>
            <ExcludeFromSetParameter>True</ExcludeFromSetParameter>
          </MsDeployDeclareParameters>
        </ItemGroup>
      </Target>
      
    </Project>

To explain this a bit, the target SetupCustomAcls will cause a new SetAcl entry to be placed inside of the source manifest used during publishing. This target is executed after the **AddIisSettingAndFileContentsToSourceManifest** target executes, via the AfterTargets attribute. We do this to ensure that the item value is created at the right time and because we need to ensure that the property **_MSDeployDirPath_FullPath** is populated.

The DeclareCustomParameters is where the custom MSDeploy parameter will be created. That target will execute after the **AddIisAndContentDeclareParametersItems** target. We do this to ensure that the property **_EscapeRegEx_MSDeployDirPath** is populated. Notice inside that target when I declare the value of the parameter (inside the Value element) that I use the property **_DestinationContentPath** which is the MSBuild property containing the path to where your app is being deployed, i.e. *REST Services/1.0.334*.

Can you try that out and let me know if it worked for you or not?