<#
.SYNOPSIS
Validates packages by simulating docs CI steps

.PARAMETER Package
An object describing a package configuration to validate in the format used by
docker image, which is the wrapping of docs CI build commands.

#>

param(
  [object] $Package
)
."$PSScriptRoot\..\common\scripts\common.ps1"

function GetResult($success, $package, $output) { 
  return @{ Success = $success; Package = $package; Output = $output }
}

$image = "$($env:IMAGEID)"

Write-Host "docker run --restart=on-failure:3 -e TARGET_PACKAGE="$($Package.name)" $image"
$installOutput = docker run --restart=on-failure:3 -e TARGET_PACKAGE="$($Package.name)" $image 2>&1

# The docker exit codes: https://docs.docker.com/engine/reference/run/#exit-status
if ($LASTEXITCODE -eq 125 -Or $LASTEXITCODE -eq 126 -Or $LASTEXITCODE -eq 127) {
  LogWarning "The `docker` command does not work with exit code $LASTEXITCODE. Skipvalidation of $($Package.name)."
}
elseif ($LASTEXITCODE -ne 0) {
  LogWarning "Package install failed: $($Package.name)"
  return GetResult $false $package $installOutput
}
return GetResult $true $package $installOutput
