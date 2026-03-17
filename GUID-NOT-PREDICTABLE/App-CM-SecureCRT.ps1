Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"
$SiteServer = $Env:COMPUTERNAME

           $ExpVer    = "9.7.1"
           $MinVer    = "3815"
             $GUID    = "{5919E6A9-0AF4-4696-89A1-33F64D005DE0}"     #FIRST_FAKE

     $Manu         = "VanDyke"
     $AppName      = "SecureCRT"
     $AppDesc      = "SecureCRT client for Windows, macOS, and Linux combines rock-solid terminal emulation with the strong encryption, broad range of authentication options, and data integrity of the SSH (Secure Shell) protocol for secure network administration and end user access."
     $InstStr      = "scrt-x64-bsafe.$ExpVer.$MinVer.exe /S /v`" /qn /norestart ALLUSERS=1`""
     $ExeLocation  = "\\host1417\Sources$\Applications\$Manu\$AppName\$ExpVer"
     $HKLMKey      = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$GUID"
     $UninstStr    = "MsiExec.exe /I$GUID"
     $ProcName     = "securecrt.exe"
     $DTName       = "SecureCRT"
     $AppFullName  = "$Manu Software $AppName $ExpVer"
     $DPGName      = "BSC_DPG"
$ConsoleFolderPath = "\Applications\Productivity Tools"
     $DevColl      = "BSC-P Beheer VDI's"   # $DevColl      = "BSCC0750_BSCC0750"


# $clause1 = New-CMDetectionClauseRegistryKeyValue -Hive LocalMachine -KeyName $HKLMKey -ValueName "DisplayVersion" -PropertyType String -Existence

$clause1 = New-CMDetectionClauseRegistryKeyValue -Hive LocalMachine -KeyName $HKLMKey -ValueName "DisplayVersion" -PropertyType String -ExpressionOperator IsEquals -ExpectedValue $ExpVer -Value

New-CMApplication -Name $AppFullName -Description $AppDesc -Publisher $Manu -SoftwareVersion $ExpVer
Add-CMScriptDeploymentType -ContentLocation $ExeLocation -ApplicationName $AppFullName -DeploymentTypeName $AppName -InstallCommand $InstStr -UninstallCommand $UninstStr -AddDetectionClause $clause1 -MaximumRuntimeMins 20 -InstallationBehaviorType InstallForSystem -UserInterActionMode Hidden

        $msi_dt = Get-CMDeploymentType -ApplicationName $AppFullName -DeploymentTypeName $DTName
        Add-CMDeploymentTypeInstallBehavior -InputObject $msi_dt -ExeFileName $ProcName
  
Start-CMContentDistribution -ApplicationName $AppFullName -DistributionPointGroupName $DPGName
New-CMApplicationDeployment -CollectionName $DevColl -Name $AppFullName -DeployAction Install -DeployPurpose Required -UserNotification HideAll -OverrideServiceWindow $true -AvailableDateTime (Get-Date) -AutoCloseExecutable $true -TimeBaseOn LocalTime -Verbose


$MoveApp = Get-CMApplication -Name $AppFullName

If($ConsoleFolderPath) {
    $MoveApp | Move-CMObject -FolderPath "$($SiteCode):\Application$($ConsoleFolderPath)"
}

#     "9.7.0"    "{5919E6A9-0AF4-4696-89A1-33F64D005DE0}"
#     "9.7.1"    "{5919E6A9-0AF4-4696-89A1-33F64D005DE0}"
