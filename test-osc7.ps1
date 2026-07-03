# Sets a pwsh prompt that emits OSC 7 with the current PSDrive location.
# Dot-source this file, then launch zellij, then cd around and open new panes.
#
#   . C:\Users\DAVEOWEN\src\zellij\test-osc7.ps1
#   C:\Users\DAVEOWEN\src\zellij\target\debug\zellij.exe
#
# Then inside zellij: cd somewhere, Alt+n. New pane should land at the cd'd dir.

function global:prompt {
    $loc = $ExecutionContext.SessionState.Path.CurrentLocation.ProviderPath
    $uriPath = ($loc -replace '\\', '/')
    if ($uriPath -notmatch '^/') { $uriPath = "/$uriPath" }
    $esc = [char]27
    $osc7 = "${esc}]7;file://${env:COMPUTERNAME}${uriPath}${esc}\"
    Write-Host -NoNewline $osc7
    "PS $loc> "
}

Write-Host "OSC 7 prompt loaded. Launch zellij, cd somewhere, then Alt+n."
$logPath = if ($env:ZELLIJ_CWD_DEBUG_LOG) { $env:ZELLIJ_CWD_DEBUG_LOG }
          else { Join-Path $env:TEMP 'zellij-cwd-debug.log' }
Write-Host "Log path: $logPath"
Write-Host "  (override with `$env:ZELLIJ_CWD_DEBUG_LOG = '...' before launching zellij)"
