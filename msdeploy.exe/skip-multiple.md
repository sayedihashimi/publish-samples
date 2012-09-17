# MSDeploy how to skip multiple files

When publishing content using msdeploy.exe you can skip files with th -skip directive. Here you'll see how you can skip multiple items.

If you have the following files in the folder `C:\Data\Personal\My Repo\MSDeploy\MultiSkip`.

![file tree][1]

To sync source to dest the command would be:

    msdeploy -verb:sync 
        -source:contentPath="C:\Data\Personal\My Repo\MSDeploy\MultiSkip\Source" 
        -dest:contentPath="C:\Data\Personal\My Repo\MSDeploy\MultiSkip\Dest"

The changes are show in figure below.
![alt text][2]

With no skips there are 19 changes.

**Skip 1 folder**

Then the command to skip the sub03 directory would  be:

    msdeploy -verb:sync 
        -source:contentPath="C:\Data\Personal\My Repo\MSDeploy\MultiSkip\Source" 
        -dest:contentPath="C:\Data\Personal\My Repo\MSDeploy\MultiSkip\Dest" 
        -skip:objectName=dirPath,absolutePath="sub03"

The result would be:

![alt text][3]

So there are 14 added files.

**Skip 2 directories**

To skip 2 directories the command would be

    msdeploy -verb:sync 
        -source:contentPath="C:\Data\Personal\My Repo\MSDeploy\MultiSkip\Source" 
        -dest:contentPath="C:\Data\Personal\My Repo\MSDeploy\MultiSkip\Dest" 
        -skip:objectName=dirPath,absolutePath="sub03" 
        -skip:objectName=dirPath,absolutePath="sub02"

Then the result of that is
![alt text][4]
There are only 9 changes here so we can see that multiple skips does work.

  [1]: /images/0ChoV.png
  [2]: /images/ThEX5.png
  [3]: /images/p9VPT.png
  [4]: /images/Nm3sD.png