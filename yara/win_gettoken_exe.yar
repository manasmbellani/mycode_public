rule WinGetTokenExe {
   meta:
      description = "Windows Information Stealing Malicous .NET Binary GetToken.exe"
      author = "manasmbellani"
      reference = "https://medium.com/@manasmbellani/malicious-batch-file-analysis-e3976f543cb1"
      date = "2022-05-10"
      hash1 = "6ad08fe301caae18941487412e96ceb0b561de4482da25ea4bb8eeb6c1a40983"
   strings:
      $x1 = "$abc9343a-9d57-4374-ae56-e1bea8098417" fullword ascii
      $x2 = "C:\\Users\\sinez\\source\\repos\\GetToken" fullword ascii
   condition:
      uint16(0) == 0x5a4d and filesize < 700KB and 2 of them
}
