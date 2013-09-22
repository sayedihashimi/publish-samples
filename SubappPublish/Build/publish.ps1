param(
    [switch]
    $BuildProjects,

    [switch]
    $PublishAll,

    [switch]
    $PublishMySiteBin,

    [switch]
    $PublishAdminArea,

    [switch]
    $PublishHrArea
)

function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $path = Split-Path $Invocation.MyCommand.Path
    return ("{0}\" -f $path)
}

# we need to build the msbuild command
function Get-MSBuildCommandArgs(){
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $logsDir
    )

    $cmdArgs = @()
    $cmdArgs += ("{0}publish.proj" -f $scriptDir)
    $cmdArgs += '/p:Configuration=release'
    $cmdArgs += '/p:VisualStudioVersion=11.0'

    if($BuildProjects){
        $cmdArgs += "/p:BuildBeforePublish=true"
    }

    foreach($target in (Get-PublishTargetsFromParams)){
        $cmdArgs += ("/t:{0}" -f $target)
    }

    $logFileBaseName = ("publish-$(get-date -f yyyy.MM.dd.ss.ff)")

    # add logging parameters here
    # /flp1:"v=d;logfile=logs\%~n0.d.log" /flp2:"v=diag;logfile=logs\%~n0.diag.log"
    $cmdArgs += ('/flp1:"v=d;logfile={0}{1}.d.log" ' -f $logsDir, $logFileBaseName)
    $cmdArgs += ('/flp2:"v=diag;logfile={0}{1}.diag.log" ' -f $logsDir, $logFileBaseName)

    return $cmdArgs
}

function Get-PublishTargetsFromParams(){
    $pubTargets = @()
        
    if($PublishAll){
        # if PublishAll is passed we do not need to add any additional targets
        # for any other publish targets
        $pubTargets += "PublishMySiteAll"
    }
    else{
        if($PublishMySiteBin){
            $pubTargets += "PublishMySiteBin"
        }
        if($PublishAdminArea){
            $pubTargets += "PublishAdminArea"
        }
        if($PublishHrArea){
            $pubTargets += "PublishHrArea"
        }
    }

    return $pubTargets
}
function Get-MSBuildPath(){
    return "$env:windir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
}

# begin script

$scriptDir = (Get-ScriptDirectory)
$logsDir = (Join-Path -Path $scriptDir -ChildPath "logs\")
if(!(Test-Path $logsDir)){
    mkdir $logsDir
}
$msbuildCmd = (Get-MSBuildPath)
$allArgs  = (Get-MSBuildCommandArgs -logsDir $logsDir)
"Calling msbuild.exe with the following parameters. [$msbuildCmd] [$allArgs] " | Write-Host
& $msbuildCmd $allArgs