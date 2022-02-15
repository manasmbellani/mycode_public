rule StartCleanPS {
   meta:
      description = "YARA Rule for detecting NIM compiled files"
      author = "manasmbellani"
      reference = "https://nim-by-example.github.io/hello_world/"
      date = "2022-02-16"
      hash1 = "f1f306a0922d9ae9f02a191db4bc56d7cf4419edbe82339a9925199adf67e37f"
   strings:
      $x1 = "\\system\\iterators.nim"
      $x2 = "\\system\\io.nim"
      $x3 = "\\system\\avltree.nim"
      $x4 = "\\system\\osalloc.nim"
      $x5 = "\\system\\gc.nim"
      $x6 = "\\lib\\system.nim"
      $x7 = "\\system\\cellsets.nim"
      $x8 = "\\system\\fatal.nim"
      $x9 = "nimToCStringConv"
      $x10 = "nimGCunrefNoCycle"
      $x11 = "nim_program_result"
      $x12 = "nimZeroMem"
      $x13 = "nimGetProcAddr"
      $x14 = "nimRegisterThreadLocalMarker"
      $x15 = "\\system\\comparisons.nim"
      $x16 = "\\system\\gc_common.nim"
      $x17 = "\\system\\arithmetics.nim"
   condition:
      uint16(0) == 0x5a4d and filesize < 50MB and 8 of them      
}
