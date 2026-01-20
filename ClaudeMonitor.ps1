# --- CONFIGURATION ---
$Topic = "YOUR_UNIQUE_NTFY_TOPIC_HERE" 
$Threshold = 80
$Critical = 95
$MaxBlockCost = 28.00 
$LogFile = "$PSScriptRoot\debug_log.txt"
$StateFile = "$PSScriptRoot\last_alert.txt"
# ---------------------

try {
    $RawJson = & npx --yes ccusage blocks --json --no-color 2>&1 | Out-String
    if ($null -ne $RawJson -and $RawJson -ne "") {
        $Data = $RawJson | ConvertFrom-Json
        $ActiveBlock = $Data.blocks | Where-Object { $_.isActive -eq $true } | Select-Object -First 1

        if ($ActiveBlock) {
            $UsagePercent = [math]::Round(($ActiveBlock.costUSD / $MaxBlockCost) * 100, 1)
            $RemainingMins = if ($ActiveBlock.projection) { $ActiveBlock.projection.remainingMinutes } else { 0 }
            
            # Read last alert state
            $LastAlerted = if (Test-Path $StateFile) { Get-Content $StateFile | Out-String | ForEach-Object { $_.Trim() } } else { 0 }

            # RESET STATE: If usage drops (new window), clear the alert history
            if ([double]$UsagePercent -lt ([double]$LastAlerted - 5)) {
                "0" | Out-File -FilePath $StateFile -Force
                $LastAlerted = 0
            }

            # ALERT LOGIC: Notify if crossing threshold and usage is increasing
            if ($UsagePercent -gt $Threshold -and $UsagePercent -gt $LastAlerted) {
                $Priority = if ($UsagePercent -gt $Critical) { "urgent" } else { "high" }
                $Title = if ($UsagePercent -gt $Critical) { "🚨 CLAUDE CRITICAL" } else { "Claude Usage Alert" }
                
                $Headers = @{ "Title" = $Title; "Priority" = $Priority; "Tags" = "warning"; "Click" = "https://console.anthropic.com/" }
                $Body = "Usage: $UsagePercent% | Reset in: $RemainingMins mins"
                
                Invoke-RestMethod -Method Post -Uri "https://ntfy.sh/$Topic" -Headers $Headers -Body $Body
                
                $UsagePercent | Out-File -FilePath $StateFile -Force
                $AlertStatus = "NOTIFICATION SENT ($UsagePercent%)"
            } else {
                $AlertStatus = "No Alert Needed ($UsagePercent%)"
            }
            
            "[$(Get-Date -Format 'HH:mm')] $AlertStatus" | Out-File -FilePath $LogFile -Append
        }
    }
} catch {
    "ERROR: $($_.Exception.Message)" | Out-File -FilePath $LogFile -Append
}
exit 0