# How to take your app offline during publish using MSBuild

## Q: How can I take my app offline, using app_offline.htm, during a build + publish using MSBuild?

I just recently blogged about this at http://sedodream.com/2012/01/08/HowToTakeYourWebAppOfflineDuringPublishing.aspx. It's more difficult than it should be and I'm working on simplifying that for a later version. In any case I've pasted all the content here for you.

I received a customer email asking how they can take their web application/site offline for the entire duration that a publish is happening from Visual Studio. An easy way to take your site offline is to drop an app_offline.htm file in the sites root directory. For more info on that you can read ScottGu’s post, link in below in resources section. Unfortunately Web Deploy itself doesn’t support this . If you want Web Deploy (aka MSDeploy) to natively support this feature please vote on it at http://aspnet.uservoice.com/forums/41199-general/suggestions/2499911-take-my-site-app-offline-during-publishing.

Since Web Deploy doesn’t support this it’s going to be a bit more difficult and it requires us to perform the following steps:

 1. Publish app_offline.htm Publish the app, and ensure that
 2. app_offline.htm is contained inside the payload being published
 3. Delete app_offline.htm

**1** will take the app offline before the publish process  begins. 

**2** will ensure that when we publish that app_offline.htm is not deleted (and therefore keep the app offline) 

**3** will delete the app_offline.htm and bring the site back online

Now that we know what needs to be done let’s look at the implementation. First for the easy part. Create a file in your Web Application Project (WAP) named app_offline-template.htm. This will be the file which will end up being the app_offline.htm file on your target server. If you leave it blank your users will get a generic message stating that the app is offline, but it would be better for you to place **static HTML** (no ASP.NET markup) inside of that file letting users know that the site will come back up and whatever other info you think is relevant to your users. When you add this file you should change the Build Action to None in the Properties grid. This will make sure that this file itself is not published/packaged. Since the file ends in .htm it will by default be published. See the image below.

![enter image description here][1]

Now for the hard part. For Web Application Projects we have a hook into the publish/package process which we refer to as “wpp.targets”. If you want to extend your publish/package process you can create a file named {ProjectName}.wpp.targets in the same folder as the project file itself. Here is the file which I created you can copy and paste the content into your wpp.targets file. I will explain the significant parts but wanted to post the entire file for your convince. Note: you can grab my latest version of this file from my github repo, the link is in the resource section below.

    <?xml version="1.0" encoding="utf-8"?>
    <Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      <Target Name="InitalizeAppOffline">
        <!-- 
        This property needs to be declared inside of target because this is imported before
        the MSDeployPath property is defined as well as others -->
        <PropertyGroup>
          <MSDeployExe Condition=" '$(MSDeployExe)'=='' ">$(MSDeployPath)msdeploy.exe</MSDeployExe>
        </PropertyGroup>    
      </Target>
    
      <PropertyGroup>
        <PublishAppOfflineToDest>
          InitalizeAppOffline;
        </PublishAppOfflineToDest>
      </PropertyGroup>
    
      <!--
        %msdeploy% 
          -verb:sync 
          -source:contentPath="C:\path\to\app_offline-template.htm" 
          -dest:contentPath="Default Web Site/AppOfflineDemo/app_offline.htm"
      -->
    
      <!--***********************************************************************
      Make sure app_offline-template.htm gets published as app_offline.htm
      ***************************************************************************-->
      <Target Name="PublishAppOfflineToDest" 
              BeforeTargets="MSDeployPublish" 
              DependsOnTargets="$(PublishAppOfflineToDest)">
        <ItemGroup>
          <_AoPubAppOfflineSourceProviderSetting Include="contentPath">
            <Path>$(MSBuildProjectDirectory)\app_offline-template.htm</Path>
            <EncryptPassword>$(DeployEncryptKey)</EncryptPassword>
            <WebServerAppHostConfigDirectory>$(_MSDeploySourceWebServerAppHostConfigDirectory)</WebServerAppHostConfigDirectory>
            <WebServerManifest>$(_MSDeploySourceWebServerManifest)</WebServerManifest>
            <WebServerDirectory>$(_MSDeploySourceWebServerDirectory)</WebServerDirectory>
          </_AoPubAppOfflineSourceProviderSetting>
    
          <_AoPubAppOfflineDestProviderSetting Include="contentPath">
            <Path>"$(DeployIisAppPath)/app_offline.htm"</Path>
            <ComputerName>$(_PublishMsDeployServiceUrl)</ComputerName>
            <UserName>$(UserName)</UserName>
            <Password>$(Password)</Password>
            <EncryptPassword>$(DeployEncryptKey)</EncryptPassword>
            <IncludeAcls>False</IncludeAcls>
            <AuthType>$(AuthType)</AuthType>
            <WebServerAppHostConfigDirectory>$(_MSDeployDestinationWebServerAppHostConfigDirectory)</WebServerAppHostConfigDirectory>
            <WebServerManifest>$(_MSDeployDestinationWebServerManifest)</WebServerManifest>
            <WebServerDirectory>$(_MSDeployDestinationWebServerDirectory)</WebServerDirectory>
          </_AoPubAppOfflineDestProviderSetting>
        </ItemGroup>
    
        <MSdeploy
              MSDeployVersionsToTry="$(_MSDeployVersionsToTry)"
              Verb="sync"
              Source="@(_AoPubAppOfflineSourceProviderSetting)"
              Destination="@(_AoPubAppOfflineDestProviderSetting)"
              EnableRule="DoNotDeleteRule"
              AllowUntrusted="$(AllowUntrustedCertificate)"
              RetryAttempts="$(RetryAttemptsForDeployment)"
              SimpleSetParameterItems="@(_AoArchivePublishSetParam)"
              ExePath="$(MSDeployPath)" />
      </Target>
    
      <!--***********************************************************************
      Make sure app_offline-template.htm gets published as app_offline.htm
      ***************************************************************************-->
      <!-- We need to create a replace rule for app_offline-template.htm->app_offline.htm for when the app get's published -->
      <ItemGroup>
        <!-- Make sure not to include this file if a package is being created, so condition this on publishing -->
        <FilesForPackagingFromProject Include="app_offline-template.htm" Condition=" '$(DeployTarget)'=='MSDeployPublish' ">
          <DestinationRelativePath>app_offline.htm</DestinationRelativePath>
        </FilesForPackagingFromProject>
    
        <!-- This will prevent app_offline-template.htm from being published -->
        <MsDeploySkipRules Include="SkipAppOfflineTemplate">
          <ObjectName>filePath</ObjectName>
          <AbsolutePath>app_offline-template.htm</AbsolutePath>
        </MsDeploySkipRules>
      </ItemGroup>
    
      <!--***********************************************************************
      When publish is completed we need to delete the app_offline.htm
      ***************************************************************************-->
      <Target Name="DeleteAppOffline" AfterTargets="MSDeployPublish">
        <!--
        %msdeploy% 
          -verb:delete 
          -dest:contentPath="{IIS-Path}/app_offline.htm",computerName="...",username="...",password="..."
        -->
        <Message Text="************************************************************************" />
        <Message Text="Calling MSDeploy to delete the app_offline.htm file" Importance="high" />
        <Message Text="************************************************************************" />
    
        <ItemGroup>
          <_AoDeleteAppOfflineDestProviderSetting Include="contentPath">
            <Path>$(DeployIisAppPath)/app_offline.htm</Path>
            <ComputerName>$(_PublishMsDeployServiceUrl)</ComputerName>
            <UserName>$(UserName)</UserName>
            <Password>$(Password)</Password>
            <EncryptPassword>$(DeployEncryptKey)</EncryptPassword>
            <AuthType>$(AuthType)</AuthType>
            <WebServerAppHostConfigDirectory>$(_MSDeployDestinationWebServerAppHostConfigDirectory)</WebServerAppHostConfigDirectory>
            <WebServerManifest>$(_MSDeployDestinationWebServerManifest)</WebServerManifest>
            <WebServerDirectory>$(_MSDeployDestinationWebServerDirectory)</WebServerDirectory>
          </_AoDeleteAppOfflineDestProviderSetting>
        </ItemGroup>
        
        <!-- 
        We cannot use the MSDeploy/VSMSDeploy tasks for delete so we have to call msdeploy.exe directly.
        When they support delete we can just pass in @(_AoDeleteAppOfflineDestProviderSetting) as the dest
        -->
        <PropertyGroup>
          <_Cmd>"$(MSDeployExe)" -verb:delete -dest:contentPath="%(_AoDeleteAppOfflineDestProviderSetting.Path)"</_Cmd>
          <_Cmd Condition=" '%(_AoDeleteAppOfflineDestProviderSetting.ComputerName)' != '' ">$(_Cmd),computerName="%(_AoDeleteAppOfflineDestProviderSetting.ComputerName)"</_Cmd>
          <_Cmd Condition=" '%(_AoDeleteAppOfflineDestProviderSetting.UserName)' != '' ">$(_Cmd),username="%(_AoDeleteAppOfflineDestProviderSetting.UserName)"</_Cmd>
          <_Cmd Condition=" '%(_AoDeleteAppOfflineDestProviderSetting.Password)' != ''">$(_Cmd),password=$(Password)</_Cmd>
          <_Cmd Condition=" '%(_AoDeleteAppOfflineDestProviderSetting.AuthType)' != ''">$(_Cmd),authType="%(_AoDeleteAppOfflineDestProviderSetting.AuthType)"</_Cmd>
        </PropertyGroup>
    
        <Exec Command="$(_Cmd)"/>
      </Target>  
    </Project>


##1 Publish app_offline.htm

The implementation for #1 is contained inside the target PublishAppOfflineToDest. The msdeploy.exe command that we need to get executed is.

    msdeploy.exe 
        -source:contentPath='C:\Data\Personal\My Repo\sayed-samples\AppOfflineDemo01\AppOfflineDemo01\app_offline-template.htm' 
        -dest:contentPath='"Default Web Site/AppOfflineDemo/app_offline.htm"',UserName='sayedha',Password='password-here',ComputerName='computername-here',IncludeAcls='False',AuthType='NTLM' -verb:sync -enableRule:DoNotDeleteRule

In order to do this I will leverage the MSDeploy task. Inside of the PublishAppOfflineToDest target you can see how this is accomplished by creating an item for both the source and destination.

##2 Publish the app, and ensure that app_offline.htm is contained inside the payload being published

This part is accomplished by the fragment

    <!--***********************************************************************
    Make sure app_offline-template.htm gets published as app_offline.htm
    ***************************************************************************-->
    <!-- We need to create a replace rule for app_offline-template.htm->app_offline.htm for when the app get's published -->
    <ItemGroup>
      <!-- Make sure not to include this file if a package is being created, so condition this on publishing -->
      <FilesForPackagingFromProject Include="app_offline-template.htm" Condition=" '$(DeployTarget)'=='MSDeployPublish' ">
        <DestinationRelativePath>app_offline.htm</DestinationRelativePath>
      </FilesForPackagingFromProject>
    
      <!-- This will prevent app_offline-template.htm from being published -->
      <MsDeploySkipRules Include="SkipAppOfflineTemplate">
        <ObjectName>filePath</ObjectName>
        <AbsolutePath>app_offline-template.htm</AbsolutePath>
      </MsDeploySkipRules>
    </ItemGroup>

The item value for FilesForPackagingFromProject here will convert your app_offline-template.htm to app_offline.htm in the folder from where the publish will be processed. Also there is a condition on it so that it only happens during publish and not packaging. We do not want app_offline-template.htm to be in the package (but it’s not the end of the world if it does either).

The element for MsDeploySkiprules will make sure that app_offline-template.htm itself doesn’t get published. This may not be required but it shouldn’t hurt.

##3 Delete app_offline.htm

Now that our app is published we need to delete the app_offline.htm file from the dest web app. The msdeploy.exe command would be:

%msdeploy% 
      -verb:delete 
      -dest:contentPath="{IIS-Path}/app_offline.htm",computerName="...",username="...",password="..." 

This is implemented inside of the DeleteAppOffline target. This target will automatically get executed after the publish because I have included the attribute AfterTargets=”MSDeployPublish”. In that target you can see that I am building up the msdeploy.exe command directly, it looks like the MSDeploy task doesn’t support the delete verb.

If you do try this out please let me know if you run into any issues. I am thinking to create a Nuget package from this so that you can just install that package. That would take a bit of work so please let me know if you are interested in that.

##Resources

 1. [The latest version of my AppOffline wpp.targets file][2]
 2. [ScottGu’s blog on app_offline.htm][3]


  [1]: images/IzAgq.png
  [2]: http://sedodream.com/ct.ashx?id=bc2ced18-9064-4f51-9167-05ec5595291c&url=https://github.com/sayedihashimi/sayed-samples/blob/master/AppOfflineDemo01/AppOfflineDemo01/AppOfflineDemo01.wpp.targets
  [3]: http://sedodream.com/ct.ashx?id=bc2ced18-9064-4f51-9167-05ec5595291c&url=http://weblogs.asp.net/scottgu/archive/2006/04/09/442332.aspx