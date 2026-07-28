Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"
$SiteServer = $Env:COMPUTERNAME


$Product     = "Nessus Agent"
$Arch        = "x64"
$AppDesc     = "The Nessus platform (officially known as Tenable Nessus) is a vulnerability assessment solution that enables organizations to proactively identify and fix security weaknesses or vulnerabilities across their attack surface before cyberattackers can exploit them."
$DPGName     = "BSC_DPG"
$Purp        = "Required"
$key         = "b274e69840623b7fad37ddd94875ae037631a5f14c86cf02fd5784b750695a29"
$srvprt      = "10.133.110.12:8834"

$ConsoleFolderPath = "\Applications\Inventory and Monitoring"

 ################################################################################################################################

                           
                           $SWVersion = "11.1.3"
                               $fam   = "Clients"                        # Clients or Servers
                          $nssgrp     = "PROD-CLIENTS-WINDOWS"           # CLIENTS or SERVERS      

#################################################################################################################################

           $MSILocation = "\\$SiteServer\Sources$\Applications\Tenable\Nessus\Agent\$SWVersion\NessusAgent-$SWVersion-x64.msi"
             $newstr    =  "msiexec.exe /i NessusAgent-$SWVersion-$Arch.msi NESSUS_GROUPS=`"$nssgrp`" NESSUS_SERVER=`"$srvprt`" NESSUS_KEY=$key /qn"
           $AppFullName = "$Product $SWVersion Windows $fam ($arch)"


New-CMApplication -Name $AppFullName -Description $AppDesc -Publisher $PublName -SoftwareVersion $SWVersion
Add-CMMsiDeploymentType -ApplicationName $AppFullName -ContentLocation $MSILocation -Force
Set-CMMSIDeploymentType -ApplicationName $AppFullname -DeploymentTypeName "$Product ($Arch) - Windows Installer (*.msi file)" -InstallCommand $newstr -MaximumRuntimeMins 20
Start-CMContentDistribution -ApplicationName $AppFullName -DistributionPointGroupName $DPGName


# $DevColl00 = "Computer Model OptiPlex SFF Plus 7020"
$DevColl01 = "Workstations Windows 11 version 24H2"
$DevColl02 = "Workstations Windows 11 version 25H2"
# $DevColl =   "All Computer with Windows Server **"

New-CMApplicationDeployment -Name $AppFullName -CollectionName $DevColl01 -DeployAction Install -DeployPurpose $Purp -UserNotification HideAll -AvailableDateTime (Get-Date) -TimeBaseOn LocalTime -Verbose
New-CMApplicationDeployment -Name $AppFullName -CollectionName $DevColl02 -DeployAction Install -DeployPurpose $Purp -UserNotification HideAll -AvailableDateTime (Get-Date) -TimeBaseOn LocalTime -Verbose

$MoveApp = Get-CMApplication -Name $AppFullName

If($ConsoleFolderPath) {
    $MoveApp | Move-CMObject -FolderPath "$($SiteCode):\Application$($ConsoleFolderPath)"
}

