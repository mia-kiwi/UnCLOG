#####################################################################################
#                                                                                   #
#    Company: The A.F.S. Corporation                                                #
#    Department: Department Of Information Technology                               #
#    Division: Division Of Programming And Development                              #
#    Group: Internal Tools Development Group                                        #
#    Team: PowerShell Development Team                                              #
#                                                                                   #
#    Level: 0                                                                       #
#    Classification: PUBLIC                                                         #
#    Version: 24.0.6                                                                #
#                                                                                   #
#    Name: Universal Computer Logging And Operational Guidelines                    #
#    Description:                                                                   #
#    Language: PowerShell                                                           #
#    Contributor(s): DELANDM002                                                     #
#    Created: 2024-03-29                                                            #
#    Updated: 2024-04-03                                                            #
#                                                                                   #
#    SNAF: [UnCLOG24.0.6 ¦ LEVEL-0] - Universal Computer Logging and Operational    #
#          Guidelines                                                               #
#    DRL: DRL://afs/it/dpd/itdg/pdt#24.0.6                                          #
#    DID: UDIS-0000000000000000000Z                                                 #
#    Location: https://github.com/mia-kiwi/UnCLOG/                                  #
#                                                                                   #
#                                                                                   #
#####################################################################################

<#
.SYNOPSIS
Logs information about a specific event to a file.

.DESCRIPTION
This function logs information about a specific event to a file. The log file is created in the specified directory, with the name of the file being the date of the event. The log file is a JSON object.

.PARAMETER Identifier
The unique identifier of the log entry. If not specified, a new GUID is generated.

.PARAMETER Type
The type of the log entry. The default value is "Information".

.PARAMETER Severity
The severity of the log entry. The default value is "None".

.PARAMETER AppName
The name of the application that generated the log entry.

.PARAMETER Head
The title of the log entry.

.PARAMETER Body
The message of the log entry.

.PARAMETER Directory
The directory where the log file is created. The default value is "C:\Temp\UnCLOGS\".

.EXAMPLE
PS C:\> Write-UnCLog -Head "Test Log" -Body "This is a test log" -AppName "UnCLOG Tester" -Type Information -Severity Low
PS C:\> Write-UnCLog -Head "Test Log" -Body "This is a test log" -AppName "UnCLOG Tester" -Type Information -Severity Low -Directory "C:\Temp\UnCLOGS\AppName1"
#>
function Write-UnCLog {
    param(
        [parameter()]
        [string] $Identifier = ([System.Guid]::newguid()).ToString(),

        [parameter()]
        [ValidateSet("Success", "Information", "Warning", "Error", "Debug")]
        [string] $Type = "Information",

        [parameter()]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = "None",

        [parameter()]
        [Alias("Application", "App", "Name")]
        [string] $AppName = "",

        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Title", "Short")]
        [string] $Head,

        [parameter(Position = 1)]
        [Alias("Message", "Long")]
        [object] $Body,

        [parameter()]
        [Alias("Location", "Folder", "Path", "Dir")]
        [string] $Directory = 'C:\Temp\UnCLOGS\'
    )

    # Get and format the call stack
    $CallStack = @()
    foreach ($Frame in Get-PSCallStack) {
        $CallStack += @{
            Component = $Frame.FunctionName
            File      = $Frame.ScriptName
            Line      = $Frame.ScriptLineNumber
        }
    }

    # Create the log object
    $Log = @{
        Identifier  = $Identifier
        Application = $AppName
        Type        = $Type
        Severity    = $Severity
        Head        = $Head
        Datetime    = [DateTime]::UtcNow.ToString("o")
        Machine     = [System.Environment]::MachineName
        User        = "$env:USERDOMAIN\$env:USERNAME"
        Body        = $Body
        CallStack   = $CallStack
    }

    # /!\ This block slows down the function by around 10ms, but it's only executed once per log directory so we ballin /!\
    # Attempt to create the directory (even if it already exists, checking takes too long)
    try {
        [System.IO.Directory]::CreateDirectory($Directory) | Out-Null
    }
    catch {
        throw "Failed to create the log directory: $_"
    }

    try {
        $StreamWriter = [System.IO.StreamWriter]::New("$Directory\$($Log.DateTime.Substring(0,10)).unclog", $true)
        $StreamWriter.WriteLine([Newtonsoft.Json.JsonConvert]::SerializeObject($Log))
    }
    catch {
        Write-Warning "Failed to write to the log file for $($Log.Identifier) on $($Log.Datetime): $_"
    }
    finally {
        $StreamWriter.Flush()
        $StreamWriter.Close()
    }

    return $null
}

function Write-UnCInfo {
    param(
        [parameter()]
        [string] $Identifier = ([System.Guid]::newguid()).ToString(),

        [parameter()]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = "None",

        [parameter()]
        [Alias("Application", "App", "Name")]
        [string] $AppName = "",

        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Title", "Short")]
        [string] $Head,

        [parameter(Position = 1)]
        [Alias("Message", "Long")]
        [object] $Body,

        [parameter()]
        [Alias("Location", "Folder", "Path", "Dir")]
        [string] $Directory = 'C:\Temp\UnCLOGS\'
    )

    Write-UnCLog -Identifier $Identifier -Severity $Severity -AppName $AppName -Head $Head -Body $Body -Directory $Directory -Type Information
}

function Write-UnCSuccess {
    param(
        [parameter()]
        [string] $Identifier = ([System.Guid]::newguid()).ToString(),

        [parameter()]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = "None",

        [parameter()]
        [Alias("Application", "App", "Name")]
        [string] $AppName = "",

        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Title", "Short")]
        [string] $Head,

        [parameter(Position = 1)]
        [Alias("Message", "Long")]
        [object] $Body,

        [parameter()]
        [Alias("Location", "Folder", "Path", "Dir")]
        [string] $Directory = 'C:\Temp\UnCLOGS\'
    )

    Write-UnCLog -Identifier $Identifier -Severity $Severity -AppName $AppName -Head $Head -Body $Body -Directory $Directory -Type Success
}

function Write-UnCWarning {
    param(
        [parameter()]
        [string] $Identifier = ([System.Guid]::newguid()).ToString(),

        [parameter()]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = "None",

        [parameter()]
        [Alias("Application", "App", "Name")]
        [string] $AppName = "",

        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Title", "Short")]
        [string] $Head,

        [parameter(Position = 1)]
        [Alias("Message", "Long")]
        [object] $Body,

        [parameter()]
        [Alias("Location", "Folder", "Path", "Dir")]
        [string] $Directory = 'C:\Temp\UnCLOGS\'
    )

    Write-UnCLog -Identifier $Identifier -Severity $Severity -AppName $AppName -Head $Head -Body $Body -Directory $Directory -Type Warning
}


function Write-UnCError {
    param(
        [parameter()]
        [string] $Identifier = ([System.Guid]::newguid()).ToString(),

        [parameter()]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = "None",

        [parameter()]
        [Alias("Application", "App", "Name")]
        [string] $AppName = "",

        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Title", "Short")]
        [string] $Head,

        [parameter(Position = 1)]
        [Alias("Message", "Long")]
        [object] $Body,

        [parameter()]
        [Alias("Location", "Folder", "Path", "Dir")]
        [string] $Directory = 'C:\Temp\UnCLOGS\'
    )

    Write-UnCLog -Identifier $Identifier -Severity $Severity -AppName $AppName -Head $Head -Body $Body -Directory $Directory -Type Error
}


function Write-UnCDebug {
    param(
        [parameter()]
        [string] $Identifier = ([System.Guid]::newguid()).ToString(),

        [parameter()]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = "None",

        [parameter()]
        [Alias("Application", "App", "Name")]
        [string] $AppName = "",

        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Title", "Short")]
        [string] $Head,

        [parameter(Position = 1)]
        [Alias("Message", "Long")]
        [object] $Body,

        [parameter()]
        [Alias("Location", "Folder", "Path", "Dir")]
        [string] $Directory = 'C:\Temp\UnCLOGS\'
    )

    Write-UnCLog -Identifier $Identifier -Severity $Severity -AppName $AppName -Head $Head -Body $Body -Directory $Directory -Type Debug
}
