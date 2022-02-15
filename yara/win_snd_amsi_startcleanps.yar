rule StartCleanPS {
   meta:
      description = "SnD_AMSI/StartCleanPS.exe - ETW and AMSI Bypass Script detection"
      author = "manasmbellani"
      reference = "https://github.com/whydee86/SnD_AMSI"
      date = "2022-02-15"
      hash1 = "6016752a8286bbb3e1762bf8322a88c5999016c7301d025da31cbc3f04f1a9ba"
   strings:
      $x1 = "Failed to get the address of 'AmsiScanBuffer'" ascii
      $x2 = "Failed to get the address of 'EtwEventWrite'" fullword ascii
      $x3 = "Powershell started successfully" fullword ascii
      $x4 = "SnD_AMSI\\Remote.nim" fullword ascii
      $x5 = "AMSI disabled" fullword ascii
   condition:
      uint16(0) == 0x5a4d and filesize < 700KB and 3 of them
}
