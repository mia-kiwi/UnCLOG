#####################################################################################
#                                                                                   #
#    Company: The A.F.S. Corporation                                                #
#    Department: Department Of Information Technology                               #
#    Division: Division Of Programming And Development                              #
#    Group: Internal Tools Development Group                                        #
#    Team: Powershell Development Team                                              #
#                                                                                   #
#    Level: 0                                                                       #
#    Classification: PUBLIC                                                         #
#    Version: 24.0.3                                                                #
#                                                                                   #
#    Name: Universal Computer Logging And Operational Guidelines                    #
#    Description:                                                                   #
#    Language: PowerShell                                                           #
#    Contributor(s): DELANDM002                                                     #
#    Created: 2024-03-29                                                            #
#    Updated: 2024-04-02                                                            #
#                                                                                   #
#    SNAF: [UnCLOG24.0.3 ¦ LEVEL-0] - Universal Computer Logging and Operational    #
#          Guidelines                                                               #
#    DRL: DRL://afs/it/dpd/itdg/pdt#24.0.3                                          #
#    DID: UDIS-0000000000000000000Z                                                 #
#    Location: https://github.com/mia-kiwi/UnCLOG/                                  #
#                                                                                   #
#    Copyright (c) 2024, The A.F.S. Corporation. All rights reserved.               #
#                                                                                   #
#####################################################################################

function Write-UnCLog {
    param(
        [parameter()]
        [string] $Identifier = ([System.Guid]::newguid()).ToString(),

        [parameter()]
        [ValidateSet("Information", "Warning", "Error", "Debug")]
        [string] $Type = "Information",

        [parameter()]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = "None",

        [parameter()]
        [string] $AppName = "",

        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Title", "Short")]
        [string] $Head,

        [parameter(Position = 1)]
        [Alias("Message", "Long")]
        [string] $Body,

        [parameter()]
        [Alias("Location", "Folder", "Path", "Dir")]
        [string] $Directory = 'C:\UnCLOGS\'
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
