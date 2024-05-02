####################################################################################################
#                                                                                                  #
#    Company:        THE A.F.S. CORPORATION                                                        #
#    Department:     INFORMATION TECHNOLOGY                                                        #
#    Division:       PROGRAMMING AND DEVELOPMENT                                                   #
#    Group:                                                                                        #
#    Team:                                                                                         #
#                                                                                                  #
#    Level:          0                                                                             #
#    Classification: PUBLIC                                                                        #
#    Version:        24.0.9                                                                        #
#                                                                                                  #
#    Name:           UNCLOG                                                                        #
#    Title:          UNIVERSAL COMPUTER LOGGING AND OPERATIONAL GUIDELINES                         #
#    Description:                                                                                  #
#    Language:       POWERSHELL                                                                    #
#    Contributor(s): DELANDM002                                                                    #
#    Created:        2024-03-29                                                                    #
#    Updated:        2024-04-28                                                                    #
#                                                                                                  #
#    SNAF:           [UNCLOG24.0.9 ¦ LEVEL-0] - UNIVERSAL COMPUTER LOGGING AND OPERATIONAL         #
#                    GUIDELINES                                                                    #
#    DRL:            DRL://AFS/IT/DPD/UNCLOG                                                       #
#    DID:            UDIS-0000000000000000000Z                                                     #
#    Location:       PSXPEDITE-ALPHA                                                               #
#                                                                                                  #
#    2024 (c) THE A.F.S. CORPORATION. All rights reserved.                                         #
#                                                                                                  #
####################################################################################################

# ========== CONFIGURATION ========== #
$Script:UnCLOGConfig = @{
    Version         = '24.0.9'
    ShowLogs        = $true
    WriteLogs       = $true
    LogPath         = 'C:\Temp\UnCLOG'
    ApplicationName = 'UnCLOG'
}
# =================================== #

# ========== FUNCTIONS ========== #
<#
.SYNOPSIS
Retrieves a configuration value from the UnCLOG configuration hashtable.

.DESCRIPTION
The Get-ULConfig function retrieves a configuration value from the UnCLOG configuration hashtable. If a key is provided, the function attempts to retrieve the value from the configuration hashtable. If the key exists, the function returns the value; otherwise, the function returns the default value. If no key is provided, the function returns the entire configuration hashtable.

.PARAMETER Key
The key of the configuration value to retrieve.

.PARAMETER Default
The default value to return if the key does not exist in the configuration hashtable.

.EXAMPLE
Get-ULConfig -Key 'Version'

.EXAMPLE
Get-ULConfig -Key 'ShowLogs' -Default $false
#>
function Get-ULConfig {
    param(
        [Alias("Name", "Config", "Setting")]
        [string] $Key,

        [Alias("Value", "Fallback", "DefaultValue")]
        [object] $Default
    )

    # If a key is provided, attempt to retrieve the value from the configuration hashtable
    if ($Key) {
        # If the key exists, return the value; otherwise, return the default value (if provided)
        if ($Script:UnCLOGConfig.ContainsKey($Key)) {
            return $Script:UnCLOGConfig[$Key]
        }
        elseif ($Default) {
            return $Default
        }
        else {
            return $null
        }
    }
    else {
        # If no key is provided, return the entire configuration hashtable
        return $Script:UnCLOGConfig
    }
}

<#
.SYNOPSIS
Sets a configuration value in the UnCLOG configuration hashtable.

.DESCRIPTION
The Set-ULConfig function sets a configuration value in the UnCLOG configuration hashtable. If a hashtable is provided, the function sets the entire configuration hashtable. If a key and value are provided, the function sets the key-value pair in the configuration hashtable (or updates an existing key-value pair).

.PARAMETER Config
The configuration hashtable to set.

.PARAMETER Key
The key of the configuration value to set.

.PARAMETER Value
The value of the configuration value to set.

.EXAMPLE
Set-ULConfig -Config @{
    Version           = '24.0.8-B'
    ShowLogs          = $true
    WriteLogs         = $true
    LogPath           = 'C:\Temp\UnCLOG'
    ApplicationName   = 'UnCLOG'
}

.EXAMPLE
Set-ULConfig -Key 'ShowLogs' -Value $false
#>
function Set-ULConfig {
    param(
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'SetAll')]
        [Alias("Settings", "Configuration")]
        [hashtable] $Config,

        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'SetKey')]
        [Alias("Name", "Config", "Setting")]
        [string] $Key,

        [parameter(Mandatory = $true, Position = 1, ParameterSetName = 'SetKey')]
        [object] $Value
    )

    # If a hashtable is provided, set the entire configuration hashtable
    if ($PSCmdlet.ParameterSetName -eq 'SetAll') {
        $Script:UnCLOGConfig = $Config
    }
    else {
        # If a key and value are provided, set the key-value pair in the configuration hashtable (or update an existing key-value pair)
        $Script:UnCLOGConfig[$Key] = $Value
    }
}

<#
.SYNOPSIS
Writes a log entry to the console and/or a log file.

.DESCRIPTION
The Write-ULog function writes a log entry to the console and/or a log file. The function accepts a message, details, severity, type, application, and path as parameters. The function writes the log entry to a log file in JSON format and displays the log entry in the console. The function also retrieves the call stack and includes it in the log entry.

.PARAMETER Message
The message to write to the log entry.

.PARAMETER Details
The details to write to the log entry.

.PARAMETER Severity
The severity of the log entry (None, Low, Medium, High, Critical).

.PARAMETER Type
The type of the log entry (Success, Information, Info, Warning, Error, Debug).

.PARAMETER Application
The application name to write to the log entry.

.PARAMETER Path
The path to write the log file to.

.EXAMPLE
Write-ULog -Message 'This is a test log entry.'

.EXAMPLE
Write-ULog -Message 'This is a test log entry.' -Severity 'High' -Type 'Error'

.EXAMPLE
Write-ULog -Message 'This is a test log entry.' -Details 'This is a test log entry with details.'
#>
function Write-ULog {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Head", "Short")]
        [string] $Message,

        [parameter(Position = 1)]
        [Alias("Body", "Long")]
        [object] $Details,

        [parameter(Position = 2)]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = 'Low',
    
        [parameter(Position = 3)]
        [ValidateSet("Success", "Information", "Info", "Warning", "Error", "Debug")]
        [string] $Type = 'Information',

        [Alias("App")]
        [string] $Application = (Get-ULConfig -Key 'ApplicationName' -Default 'UnCLOG'),

        [Alias("Dir")]
        [string] $Path = (Get-ULConfig -Key 'LogPath' -Default 'C:\Temp\UnCLOG')
    )

    # Get and format the call stack
    $CallStack = @(
        foreach ($Frame in (Get-PSCallStack)) {
            @{
                Component = $Frame.Command.ToString()
                Line      = $Frame.ScriptLineNumber
                File      = $Frame.ScriptName
            }
        }
    )

    # Create a log entry
    $Log = @{
        Application = $Application
        Type        = $Type
        Severity    = $Severity
        Message     = $Message
        Details     = $Details
        CallStack   = $CallStack
        Datetime    = ([datetime]::UtcNow).ToString("yyyy-MM-ddTHH:mm:ss.fffffffK")
        Machine     = [System.Environment]::MachineName
        User        = "$env:USERDOMAIN\$env:USERNAME"
    }

    if (Get-ULConfig -Key 'WriteLogs' -Default $true) {
        try {
            $SW = [System.IO.StreamWriter]::New("$Path\$($Log.DateTime.Substring(0,10)).unclog", $true)
            $SW.WriteLine([Newtonsoft.Json.JsonConvert]::SerializeObject($Log))
        }
        catch [System.IO.DirectoryNotFoundException] {
            [System.IO.Directory]::CreateDirectory($Path) | Out-Null

            $SW = [System.IO.StreamWriter]::New("$Path\$($Log.DateTime.Substring(0,10)).unclog", $true)
            $SW.WriteLine([Newtonsoft.Json.JsonConvert]::SerializeObject($Log))
        }
        catch {
            Write-Warning "Failed to write to the log file: $($_.Exception)"
        }
        finally {
            $SW.Flush()
            $SW.Close()
        }
    }

    if (Get-ULConfig -Key 'ShowLogs' -Default $true) {
        switch ($Type) {
            'Success' {
                $Colour = "Green"
            }
            'Information' {
                $Colour = "Cyan"
            }
            'Info' {
                $Colour = "Cyan"
            }
            'Warning' {
                $Colour = "Yellow"
            }
            'Error' {
                $Colour = "Red"
            }
            'Debug' {
                $Colour = "Magenta"
            }
            default {
                $Colour = "Magenta04/28/2024 14:44:06"
            }
        }

        Write-Host (@(($Log.Datetime).PadRight(33), ($Log.Severity).PadRight(8), ($Log.Type).PadRight(11), $Log.Message) -join "    ") -ForegroundColor $Colour
    }
}

function Write-ULSuccess {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Head", "Short")]
        [string] $Message,

        [parameter(Position = 1)]
        [Alias("Body", "Long")]
        [object] $Details,

        [parameter(Position = 2)]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = 'Low',

        [Alias("App")]
        [string] $Application = (Get-ULConfig -Key 'ApplicationName' -Default 'UnCLOG'),

        [Alias("Dir")]
        [string] $Path = (Get-ULConfig -Key 'LogPath' -Default 'C:\Temp\UnCLOG')
    )

    Write-ULog -Message $Message -Details $Details -Severity $Severity -Type 'Success' -Application $Application -Path $Path
}

function Write-ULInfo {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Head", "Short")]
        [string] $Message,

        [parameter(Position = 1)]
        [Alias("Body", "Long")]
        [object] $Details,

        [parameter(Position = 2)]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = 'Low',

        [Alias("App")]
        [string] $Application = (Get-ULConfig -Key 'ApplicationName' -Default 'UnCLOG'),

        [Alias("Dir")]
        [string] $Path = (Get-ULConfig -Key 'LogPath' -Default 'C:\Temp\UnCLOG')
    )

    Write-ULog -Message $Message -Details $Details -Severity $Severity -Type 'Information' -Application $Application -Path $Path
}

function Write-ULWarning {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Head", "Short")]
        [string] $Message,

        [parameter(Position = 1)]
        [Alias("Body", "Long")]
        [object] $Details,

        [parameter(Position = 2)]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = 'Medium',

        [Alias("App")]
        [string] $Application = (Get-ULConfig -Key 'ApplicationName' -Default 'UnCLOG'),

        [Alias("Dir")]
        [string] $Path = (Get-ULConfig -Key 'LogPath' -Default 'C:\Temp\UnCLOG')
    )

    Write-ULog -Message $Message -Details $Details -Severity $Severity -Type 'Warning' -Application $Application -Path $Path
}

function Write-ULError {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Head", "Short")]
        [string] $Message,

        [parameter(Position = 1)]
        [Alias("Body", "Long")]
        [object] $Details,

        [parameter(Position = 2)]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = 'High',

        [Alias("App")]
        [string] $Application = (Get-ULConfig -Key 'ApplicationName' -Default 'UnCLOG'),

        [Alias("Dir")]
        [string] $Path = (Get-ULConfig -Key 'LogPath' -Default 'C:\Temp\UnCLOG')
    )

    Write-ULog -Message $Message -Details $Details -Severity $Severity -Type 'Error' -Application $Application -Path $Path
}

function Write-ULDebug {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [Alias("Head", "Short")]
        [string] $Message,

        [parameter(Position = 1)]
        [Alias("Body", "Long")]
        [object] $Details,

        [parameter(Position = 2)]
        [ValidateSet("None", "Low", "Medium", "High", "Critical")]
        [string] $Severity = 'None',

        [Alias("App")]
        [string] $Application = (Get-ULConfig -Key 'ApplicationName' -Default 'UnCLOG'),

        [Alias("Dir")]
        [string] $Path = (Get-ULConfig -Key 'LogPath' -Default 'C:\Temp\UnCLOG')
    )

    Write-ULog -Message $Message -Details $Details -Severity $Severity -Type 'Debug' -Application $Application -Path $Path
}
# =============================== #
