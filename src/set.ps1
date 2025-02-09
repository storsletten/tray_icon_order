$baseKey = "HKCU:\Control Panel\NotifyIconSettings"
$filePath = "order.txt"

if (-not (Test-Path -Path $filePath)) {
 Write-Error "The file '${filePath}' does not exist."
 exit 1
}

$binaryData = @()
$regex = [Regex]::new("\d+$")

Get-Content -Path $filePath | ForEach-Object {
 $match = $regex.Match($_)
 if ($match.Success) {
  $number = [uint64]$match.Value
  $bytes = [BitConverter]::GetBytes($number)
  $binaryData += $bytes
 }
}

Set-ItemProperty -Path $baseKey -Name UIOrderList -Value ([byte[]]$binaryData)

Write-Host "Done."
