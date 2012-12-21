# How to publish from the command line using MSBuild

In Visual Studio 2012 (_as well as the publish updates available in the [Azure SDK][1] for VS 2010_) we have simplified command line publishing for web projects. We have done that by using Publish Profiles. To publish from the command follow the steps below.

1. Create a publish profile
1. Publish from the command line using msbuild.exe and pass in the profile

### Publish using a publish profile
In Visual Studio for a web project you can create a publish profile using the publish dialog. When you create that profile it is automatically stored in your project under _Properties\PublishProfiles_, for VB apps they will be located under _My Project\PublishProfiles_. You can use the created profile to publish from the command line with a command line the following.

    msbuild mysln.sln /p:DeployOnBuild=true /p:PublishProfile=<profile-name>

If you want to store the publish profile (.pubxml file) in some other location you can pass in the path as the value for the `PublishProfile` property.

Publish profiles are MSBuild files. If you need to customize the publish process you can do so directly inside of the .pubxml file.

### Publish without a publish profile

If your end goal is to pass in properties from the command line without a publish profile. I would recommend the following. Create a sample publish profile in Visual Studio. Inspect that publish profile to determine what MSBuild properties you need to pass in on the command line. FYI not all publish method support command line publishing (i.e. FTP/FPSE).

On a somewhat different, but related, note if you are building the .csproj/.vbproj instead of the .sln and you are using Visual Studio 2012 you should also pass in `/p:VisualStudioVersion=11.0`. For more details as to why see http://sedodream.com/2012/08/19/VisualStudioProjectCompatabilityAndVisualStudioVersion.aspx.


  [1]: http://www.windowsazure.com/en-us/develop/net/