function tweakExp {
  $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  Set-ItemProperty $key -Name SuperHidden -Value 00000001
  Set-ItemProperty $key -Name ShowSuperHidden -Value 00000001
  Set-ItemProperty $key -Name HideFileExt -Value 00000000
  Set-ItemProperty $key -Name Hidden -Value 00000001
}


$keys = "SuperHidden","ShowSuperHidden","HideFileExt","Hidden"

$keys = "SuperHidden","ShowSuperHidden","HideFileExt","Hidden"
Foreach ($i in $keys)
{
    echo $i
}

configuration Registry {
  Node $ComputerName {
    Registry CreateReg {
      Key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
      ValueName =
      ValueType =
      ValueData = 00000001
    }
  }
}
