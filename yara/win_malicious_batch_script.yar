rule WinMaliciousBatchScript {
   meta:
      description = "Windows Information Stealing Malicous Batch Script Leveraging GetToken.exe"
      author = "manasmbellani"
      reference = "https://medium.com/@manasmbellani/malicious-batch-file-analysis-e3976f543cb1"
      date = "2022-05-10"
      hash1 = "e523b1c3486bd9353c85d9699e5d35788dae77cbe6d3fc0fcb68cdb7fe654c27"
   strings:
      $x1 = "setlocal enableextensions" ascii
      $x2 = "enabledelayedexpansion" fullword ascii
      $x3 = "lHCmx" fullword ascii
      $x4 = "maxMg" fullword ascii
      $x5 = "DZgJN" fullword ascii
   condition:
      filesize < 700KB and 3 of them
}
