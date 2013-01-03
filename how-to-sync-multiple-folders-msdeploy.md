<article class="docItem">
<article class="pageCenter">

# How to sync multiple folders with Web Deploy (MSDeploy)

I received a email from someone asking how you could use Web Deploy to sync multiple folders. I thought I’d share with you what I wrote to him.

*From:* Sayed Hashimi 
*Sent:* Tuesday, December 18, 2012 11:28 PM 

You actually can do this, but it’s not based on skips, it’s an opt-in approach. What I mean is that you would have to specify all the folders that you wanted to sync.

MSDeploy is a provider based model. There is an composite provider, manifest, which can be used when multiple providers are required. In your case the actual provider that you want to use is contentPath. This is the provider that knows how to sync folders. If you want to sync multiple folders you can create a source manifest which has the source folders and a dest manifest which has all the target folders.

In my example I have the following folders.

* c:\temp\publish\souce\01
* c:\temp\publish\souce\02
* c:\temp\publish\souce\03

I only want to sync 01 and 03 so I create the manifest with the following content.

    <?xml version="1.0" encoding="utf-8"?>
    <sitemanifest>
      <contentPath path="C:\Temp\publish\Source\01"/>
      <contentPath path="C:\Temp\publish\Source\03"/>
    </sitemanifest>

The dest manifest file will contain.

    <?xml version="1.0" encoding="utf-8"?>
    <sitemanifest>
      <contentPath path="C:\Temp\publish\Dest\01"/>
      <contentPath path="C:\Temp\publish\Dest\03"/>
    </sitemanifest>

Then to do the sync you can use the command.

    msdeploy -verb:sync 
    -source:manifest="C:\Temp\publish\SourceManifest.xml" 
    -dest:manifest="C:\Temp\publish\DestManifest.xml" 
    -enableRule:DoNotDelete 
    -useCheckSum 
    -disableRule:BackupRule

### Drawbacks from using this approach

* You must use full paths in the source/dest manifests.
* Your source/dest manifests must have matching contentPath elements
* This approach requires two files; source manifest & dest manifest

### How you can make this even better

The real issue I have with this approach is that it requires both a source & dest manifest. If you can easily auto generate these files from a list of shares that would be great. If you are maintaining these files “by hand” you should be careful to make sure both files are updated.

With a bit of more work you can boil it down to a single source manifest if you have a common root folder, and you want the files to be reflected in the same relative structure underneath that. They way that you would do this is to use the MSDeploy auto provider trick. With MSDeploy you can pass –dest:auto and MSDeploy will essentially reflect the source settings to the destination. You can then create an MSDeploy parameter which will be used to update the path of that common root folder.

</article>
</article>