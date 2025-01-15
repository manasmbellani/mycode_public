# get_microsoft_kb_for_vuln_cve

Script to get the appropriate KB articles and the Catalog links to download the KBs to resolve a particular vulnerability / CVE

Leverages the MsrcSecurityUpdates API: https://github.com/Microsoft/MSRC-Microsoft-Security-Updates-API

## Setup

```
Install-Module MsrcSecurityUpdates -Force
```

## Usage

```
./Get-MicrosoftKBForVulnCVE.ps1 -CVE CVE-2024-49138
```
