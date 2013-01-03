<article class="docItem">
<article class="pageCenter">

# File System Publishing

There are two ways to exclude files from being published when the File System web publish method is used.

1. Ensure that the Build Action is set to None for the file
1. Modify the publish profile (.pubxml) to exclude it


### Build Action set to None
By default for a [Web Appliction Project](http://msdn.microsoft.com/en-us/library/dd547590.aspx) the files included for publishing are only those needed to run the application. More details on this at [Web Publish FAQ](http://msdn.microsoft.com/en-us/library/ee942158.aspx#can_i_exclude_specific_files_or_folders_from_deployment). If you want to exclude files you can set the Build Action to None. You can find the build action under the Properties for a file in Solution Explorer.


### Modify Publish Profile (.pubxml)
You can exclude files from a File System publish by populating the MSBuild item list..

TODO: Finish this

### Another change here

</article>
</article>