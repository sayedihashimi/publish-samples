<article class="docItem">
<article class="pageCenter">

# How do you include or exclude files using VS web deployment packages?

## Including Extra Files

Including extra files into the package is a bit harder but still no bigee if you are comfortable with MSBuild, and if you are not then read this.  In order to do this we need to hook into the part of the process that collects the files for packaging. The target we need to extend is called CopyAllFilesToSingleFolder. This target has a dependency property, PipelinePreDeployCopyAllFilesToOneFolderDependsOn, that we can tap into and inject our own target. So we will create a target named CustomCollectFiles and inject that into the process. We achieve this with the following (remember after the import statement).

    <PropertyGroup>
      <CopyAllFilesToSingleFolderForPackageDependsOn>
        CustomCollectFiles;
        $(CopyAllFilesToSingleFolderForPackageDependsOn);
      </CopyAllFilesToSingleFolderForPackageDependsOn>
    </PropertyGroup>

This will add our target to the process, now we need to define the target itself. Let’s assume that you have a folder named Extra Files that sits 1 level above your web project. You want to include all of those files. Here is the CustomCollectFiles target and we discuss after that.

    <Target Name="CustomCollectFiles">
      <ItemGroup>
        <_CustomFiles Include="..\Extra Files\**\*" />
    
        <FilesForPackagingFromProject  Include="%(_CustomFiles.Identity)">
          <DestinationRelativePath>Extra Files\%(RecursiveDir)%(Filename)%(Extension)</DestinationRelativePath>
        </FilesForPackagingFromProject>
      </ItemGroup>
    </Target>

Here what I did was create the item _CustomFiles and in the Include attribute told it to pick up all the files in that folder and any folder underneath it. If by any chance you need to <b>exclude</b> something from that list, add an `Exclude` attribute to `_CustomFiles`.

Then I use this item to populate the FilesForPackagingFromProject item. This is the item that MSDeploy actually uses to add extra files. Also notice that I declared the metadata DestinationRelativePath value. This will determine the relative path that it will be placed in the package. I used the statement Extra Files%(RecursiveDir)%(Filename)%(Extension) here. What that is saying is to place it in the same relative location in the package as it is under the Extra Files folder.

## Excluding files

If you open the project file of a web application created with VS 2010 towards the bottom of it you will find a line with.

    <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v10.0\WebApplications\Microsoft.WebApplication.targets" />

BTW you can open the project file inside of VS. Right click on the project pick Unload Project. Then right click on the unloaded project and select Edit Project.

This statement will include all the targets and tasks that we need. Most of our customizations should be after that import, if you are not sure put if after! So if you have files to exclude there is an item name, ExcludeFromPackageFiles, that can be used to do so. For example let’s say that you have file named Sample.Debug.js which included in your web application but you want that file to be excluded from the created packages. You can place the snippet below after that import statement.

    <ItemGroup>
      <ExcludeFromPackageFiles Include="Sample.Debug.xml">
        <FromTarget>Project</FromTarget>
      </ExcludeFromPackageFiles>
    </ItemGroup>

By declaring populating this item the files will automatically be excluded. Note the usage of the FromTarget metadata here. I will not get into that here, but you should know to always specify that.
  [1]: http://sedodream.com/2010/05/01/WebDeploymentToolMSDeployBuildPackageIncludingExtraFilesOrExcludingSpecificFiles.aspx

</article>
</article>