# pwsh 7 companion script for the zellij cwd-debug branch.
#
# What it does:
#   - Rewrites the prompt so every rendered prompt emits an OSC 7 cwd hint
#     via [Console]::Out.Write, bypassing PSReadLine's return-string
#     rendering (which silently strips OSC 7).
#   - Ships Test-Osc7 for diagnostic emission (three variants that all
#     end up in the zellij debug log tagged A/B/C).
#
# Usage — outer shell:
#   . C:\Users\DAVEOWEN\src\zellij\test-osc7.ps1
#   C:\Users\DAVEOWEN\src\zellij\target\debug\zellij.exe
#
# Inside pane 0 (dot-source again — pane runs a fresh pwsh):
#   . C:\Users\DAVEOWEN\src\zellij\test-osc7.ps1
#   cd C:\Users\DAVEOWEN\src\zellij
#   # Alt+n — new pane should land at ...\src\zellij, not at ~
#   # Ctrl+g Ctrl+q to quit

function global:Send-Osc7 {
    param([string]$Path)
    if (-not $Path) {
        $Path = $ExecutionContext.SessionState.Path.CurrentLocation.ProviderPath
    }
    $uriPath = ($Path -replace '\\', '/')
    if ($uriPath -notmatch '^/') { $uriPath = "/$uriPath" }
    $esc = [char]27
    $st  = "$esc\"
    [Console]::Out.Write("${esc}]7;file://${env:COMPUTERNAME}${uriPath}${st}")
    [Console]::Out.Flush()
}

function global:prompt {
    Send-Osc7
    "PS $($ExecutionContext.SessionState.Path.CurrentLocation.ProviderPath)> "
}

function global:Test-Osc7 {
    $esc = [char]27
    $st  = "$esc\"
    [Console]::Out.Write("${esc}]7;file:///test/A-console-out${st}"); [Console]::Out.Flush()
    Write-Host -NoNewline "${esc}]7;file:///test/B-write-host${st}"
    "${esc}]7;file:///test/C-pipeline${st}"
    Write-Host "Test-Osc7 done. Check the zellij debug log for cmd='7' entries."
}

# Inside a zellij pane: just install the prompt + helpers, don't clear the log
# or reprint the outer banner. That way re-dot-sourcing per pane is safe.
if ($env:ZELLIJ -or $env:ZELLIJ_SESSION_NAME) {
    Write-Host "OSC 7 prompt + helpers loaded (in-pane)."
    return
}

# Outer shell: clear the debug log so we're looking at fresh data.
$logPath = if ($env:ZELLIJ_CWD_DEBUG_LOG) { $env:ZELLIJ_CWD_DEBUG_LOG }
          else { Join-Path $env:TEMP 'zellij-cwd-debug.log' }
if (Test-Path $logPath) { Remove-Item $logPath }

Write-Host "OSC 7 prompt + helpers loaded (outer shell)."
Write-Host "Log path: $logPath (cleared)"
Write-Host ""
Write-Host "Next:"
Write-Host "  1) Launch zellij"
Write-Host "  2) In pane 0 dot-source again: . C:\Users\DAVEOWEN\src\zellij\test-osc7.ps1"
Write-Host "  3) cd C:\Users\DAVEOWEN\src\zellij"
Write-Host "  4) Alt+n  (new pane should land at ...\src\zellij)"
Write-Host "  5) Ctrl+g Ctrl+q"
