<# 
.SYNOPSIS 
    Script will clear all logs in Windows using Get-WinEvent and WevtUtil.exe

.EXAMPLE
    To clear ALL logs
        ./Invoke-ClearAllLogs.ps1
#>

Write-Host "[*] Clearing all Windows event logs..."
Get-WinEvent -ListLog * -Force | % { Wevtutil.exe cl $_.LogName }