# Sets a pwsh prompt that emits OSC 7 with the current PSDrive location.
# The OSC 7 escape is embedded in the prompt string (not Write-Host) so it
# goes through the normal output stream that ConPTY forwards — pwsh 7's
# Write-Host in a prompt routes through the PSHost UI and can be swallowed
# by PSReadLine's rendering path.
#
#   . C:\Users\DAVEOWEN\src\zellij\test-osc7.ps1
#   C:\Users\DAVEOWEN\src\zellij\target\debug\zellij.exe

function global:prompt {
    $loc = $ExecutionContext.SessionState.Path.CurrentLocation.ProviderPath
    $uriPath = ($loc -replace '\\', '/')
    if ($uriPath -notmatch '^/') { $uriPath = "/$uriPath" }
    $esc = [char]27
    $st  = "$esc\"   # ST terminator: ESC + backslash
    $osc7 = "$esc]7;file://$env:COMPUTERNAME$uriPath$st"
    "$osc7`PS $loc> "
}

# Clear any prior log so we're only looking at fresh data.
$logPath = if ($env:ZELLIJ_CWD_DEBUG_LOG) { $env:ZELLIJ_CWD_DEBUG_LOG }
          else { Join-Path $env:TEMP 'zellij-cwd-debug.log' }
if (Test-Path $logPath) { Remove-Item $logPath }

Write-Host "OSC 7 prompt loaded (embedded-in-return-string form)."
Write-Host "Log path: $logPath (cleared)"
Write-Host "Launch zellij, cd somewhere, then Alt+n."
