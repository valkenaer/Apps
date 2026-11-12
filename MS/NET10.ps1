Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"
$SiteServer = $Env:COMPUTERNAME

   $ExpVer          = "10.0.15"
   $GUIDRT          = "{888E927F-F300-4F16-882A-B9A04F9513FB}"                # 1ST RUN RANDOM
   $ExpectedVersion = "80.60.61788"
   $Manu            = "Microsoft"
   $AppName         = "NET Desktop Runtime"
 $AppFullName       = "$AppName $ExpVer [2026-11]"
   $PrevVersion     = "Windows Desktop Runtime [2026-10]"


$Location         = "\\$SiteServer\Sources$\Applications\$Manu\$AppName\$ExpVer"
$ProcName         = "abacab4e.exe"
$InstStr          = "windowsdesktop-runtime-$ExpVer-win-x64.exe /install /quiet /norestart"
      $UninstStr = "windowsdesktop-runtime-$ExpVer-win-x64.exe /Uninstall /Quiet /Norestart"
          $AppDesc = "The .NET Desktop Runtime $ExpVer enables you to run existing Windows desktop applications. This release includes the .NET Runtime; you don't need to install it separately."
          $HKLMKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$GUIDRT"
$ConsoleFolderPath = "\Applications\$Manu"


if (!(test-path d:\Sources\Applications\$Manu\$AppName\$ExpVer)){Write-Warning "Import path not found";Break}

$DevColl00   = "Computer All Physical (incl Spark)"
$DevColl07   = "BSCC0750_BSCC0750"

$clause1 = New-CMDetectionClauseRegistryKeyValue -Hive LocalMachine -KeyName $HKLMKey -ValueName "DisplayVersion" -PropertyType String -ExpressionOperator IsEquals -ExpectedValue $ExpectedVersion -Value

If (Get-CMApplication $PrevVersion) {
    Remove-CMApplicationDeployment -Name $PrevVersion -CollectionName $DevColl00 -Force
    Remove-CMApplication $PrevVersion -Force
}

New-CMApplication -Name $AppFullName -Description $AppDesc -Publisher $Manu -SoftwareVersion $ExpectedVersion 
Add-CMScriptDeploymentType -ContentLocation $Location -ApplicationName $AppFullname -DeploymentTypeName $AppFullName -InstallCommand $InstStr -UninstallCommand $UninstStr -AddDetectionClause $clause1 -MaximumRuntimeMins 20 -InstallationBehaviorType InstallForSystem -UserInterActionMode Hidden
Start-CMContentDistribution -ApplicationName $AppFullName -DistributionPointGroupName "BSC_DPG"

New-CMApplicationDeployment -CollectionName $DevColl00 -Name $AppFullName -DeployAction Install -DeployPurpose Required -UserNotification HideAll -OverrideServiceWindow $true -AvailableDateTime "10/10/2026 08:00" -TimeBaseOn LocalTime -Verbose

$MoveApp = Get-CMApplication -Name $AppFullName

If($ConsoleFolderPath) {
    $MoveApp | Move-CMObject -FolderPath "$($SiteCode):\Application$($ConsoleFolderPath)"
}

