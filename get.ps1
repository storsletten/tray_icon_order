$baseKey = "HKCU:\Control Panel\NotifyIconSettings"
$filePath = "order.txt"

$uiOrderListBytes = (Get-ItemProperty -Path $baseKey -Name UIOrderList).UIOrderList

if (-not $uiOrderListBytes) {
 Write-Error "Failed to read the UIOrderList value."
 exit 1
}

$textLines = @()

for ($i = 0; $i -lt $uiOrderListBytes.Length; $i += 8) {
 $subArray = $uiOrderListBytes[$i..($i+7)]
 $number = [BitConverter]::ToUInt64($subArray, 0)
 $subKeyPath = "${baseKey}\\$number"

 try {
  $executablePath = (Get-ItemProperty -Path $subKeyPath -Name ExecutablePath -ErrorAction Stop).ExecutablePath
 } catch {
  $executablePath = "<ExecutablePath not found>"
 }

 $clsidMatch = [Regex]::Match($executablePath, "^\{[0-9A-Fa-f\-]+\}\\")
 if ($clsidMatch.Success) {
  $clsid = $clsidMatch.Value.TrimEnd("\\")
  $name = $executablePath.Substring($clsid.Length + 1)
 } else {
  $clsid = ""
  $name = $executablePath
 }

 $textLines += "$name . $clsid $number"
}

$textLines | Out-File -FilePath $filePath -Encoding UTF8

Write-Host "Done."
