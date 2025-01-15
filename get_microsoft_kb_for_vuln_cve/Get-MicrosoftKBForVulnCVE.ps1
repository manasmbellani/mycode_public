<#
    .SYNOPSIS
    Script to get the KB Article links 
#>

param (
    [Parameter(Mandatory=$true)][string]$CVE
)

Write-Host "[*] Loading MsrcSecurityUpdates..."
Import-Module MsrcSecurityUpdates

Write-Host "[*] Identifying CVRF Document for CVE: $CVE..."
$CvrfUpdate = (Get-MsrcSecurityUpdate -Vulnerability "$CVE")
$CvrfId = $CvrfUpdate.value.ID

if ($CvrfId) {
    Write-Host "[*] Getting CVRF Document with CVRF ID: $CvrfId..."
    $CvrfDocument = (Get-MsrcCvrfDocument -ID $CvrfId)

    Write-Host "[*] Obtain the Product's tree..."
    $ProductTrees = ($CvrfDocument.ProductTree.FullProductName)


    Write-Host "[*] Looking up vulnerability URLs in CVRF with ID: $CvrfId and mapping against full product names..."
    $RemediationsList = ($CvrfDocument.Vulnerability | Where-Object { $_.CVE -eq "$CVE" } | Select-Object -ExpandProperty Remediations) 
    foreach($remediation in $RemediationsList) {
        # Get the URL
        $remediationUrl = ($remediation | Select-Object -ExpandProperty URL)

        # Find the proper name for each product ID in the remediation info
        $remediationProductIds = ($remediation | Select-Object -ExpandProperty ProductID)
        foreach($remediationProductId in $remediationProductIds) {
            foreach($productTree in $ProductTrees) {
                $foundProductIDInTree = $false
                if ($productTree.ProductID.Trim() -eq $remediationProductId.Trim()) {
                    # Print the information about each product ID found
                    $productName = $productTree.Value.Trim()
                    Write-Host "[+] $remediationProductId; $productName; $remediationUrl"
                    $foundProductIDInTree = $true
                    break
                }
            }
            if(-Not $foundProductIDInTree) {
                Write-Host "[+] $remediationProductId; ; $remediationUrl"
            }
        }
    }

} else {
    Write-Host "[-] No CVRF ID Found for CVE: $CVE"
}
