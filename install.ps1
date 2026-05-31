function Copy-Commands {
    param($Source, $Dest)
    if (-not (Test-Path $Source)) { Write-Host "  (none)"; return }
    if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest | Out-Null }

    $new = 0; $updated = 0

    Get-ChildItem "$Source\*.md" | ForEach-Object {
        $destFile = Join-Path $Dest $_.Name
        if (-not (Test-Path $destFile)) {
            Copy-Item $_.FullName $destFile
            Write-Host "  + $($_.Name)" -ForegroundColor Green
            $new++
        } elseif ((Get-FileHash $_.FullName).Hash -ne (Get-FileHash $destFile).Hash) {
            Copy-Item $_.FullName $destFile
            Write-Host "  ↑ $($_.Name) (updated)" -ForegroundColor Yellow
            $updated++
        }
    }
    Write-Host "  → $new new, $updated updated"
}

function Copy-Skills {
    param($Source, $Dest)
    if (-not (Test-Path $Source)) { Write-Host "  (none)"; return }
    if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest | Out-Null }

    $new = 0; $updated = 0

    Get-ChildItem $Source -Directory | ForEach-Object {
        $skillName = $_.Name
        $destSkill = Join-Path $Dest $skillName
        if (-not (Test-Path $destSkill)) { New-Item -ItemType Directory -Path $destSkill | Out-Null }

        Get-ChildItem $_.FullName -File | ForEach-Object {
            $destFile = Join-Path $destSkill $_.Name
            if (-not (Test-Path $destFile)) {
                Copy-Item $_.FullName $destFile
                Write-Host "  + $skillName\$($_.Name)" -ForegroundColor Green
                $new++
            } elseif ((Get-FileHash $_.FullName).Hash -ne (Get-FileHash $destFile).Hash) {
                Copy-Item $_.FullName $destFile
                Write-Host "  ↑ $skillName\$($_.Name) (updated)" -ForegroundColor Yellow
                $updated++
            }
        }
    }
    Write-Host "  → $new new, $updated updated"
}

$base = $env:USERPROFILE

Write-Host "Commands:"
Copy-Commands (Join-Path $PSScriptRoot "commands") "$base\.claude\commands"

Write-Host "Skills:"
Copy-Skills (Join-Path $PSScriptRoot "skills") "$base\.claude\skills"

Write-Host "Done."
