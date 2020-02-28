<#
.SYNOPSIS
  This script was created because I can't update PSVersion after deploy for clients and I need to automate lot of information collect.

.DESCRIPTION
  This script give informations in PS2.0 like the cmdlet "get-netconnectionprofile" available in <PS3.0 (but not available in PS2.0).
  This script was tested on Windows 10 IoT and Windows 7 PosReady.

.PARAMETER <Parameter_Name>
    No parameter needed.

.NOTES
  Version:        1.0
  Author:         BFHRC7
  Creation Date:  2020-02-24
  Purpose/Change: Initial script development
  
.EXAMPLE
  Simple example : "getNetConnectionProfile7" return :

  >IsConnectedToInternet : True
  >Category              : Private
  >Description           : Network
  >Name                  : Network-Name
  >IsConnected           : True
#>

function getNetConnectionProfile7
{
    [CmdletBinding()]
    [OutputType([psobject])]
    Param
    (
        # Name of the network connection
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Network Category type
        [Parameter(Mandatory=$false, 
                   Position=1)]
        [ValidateSet('Public','Private','Domain')]
        $NetworkCategory
    )

    Begin
    {
        Write-Verbose 'Creating Network List Manager instance.'
        $NLMType = [Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B')
        $NetworkListManager = [Activator]::CreateInstance($NLMType)
        $Categories = @{
            0 = 'Public'
            1 = 'Private'
            2 = 'Domain'
        }
        Write-Verbose 'Retreiving network connections.'
        $Networks = $NetworkListManager.GetNetworks(1)
        If ($NetworkCategory)
        {
            Write-Verbose "Filtering results to match category '$NetworkCategory'."
            $Networks = $Networks | ?{$Categories[$_.GetCategory()] -eq $NetworkCategory}
        }
    }
    Process
    {
        If ($Name)
        {
            Write-Verbose "Filtering results to match name '$Name'."
            $Networks = $Networks | ?{$_.GetName() -eq $Name}
        }
        foreach ($Network in $Networks)
        {
            Write-Verbose "Creating output object for network $($Network.GetName())."
            New-Object -TypeName psobject -Property @{
                Category = $Categories[($Network.GetCategory())]
                Description = $Network.GetDescription()
                Name = $Network.GetName()
                IsConnected = $Network.IsConnected
                IsConnectedToInternet = $Network.IsConnectedToInternet
            }
        }
    }
    End
    {
    }
}

