# Originally designed for use with ethminer.?
# Lynch & Diehl
#
# To do:
#
# Ensure worker id will work for various pools - nano, ethermine etc
# Add overclock input params for clock and mem
# Add overclock settings apply
# Possibly use PS background jobs rather than execs
# allow different settings based on GPU model i.e. 1060, 1070 etc

Param(
    # Folder path to the miner exe.
    [String]$minerPath="c:\mining\ethminer",

    # Miner executable name.
    [String]$minerExe="ethminer.exe",

    # Worker name, defaults to the computer name.  Will auto-append the GPU number if using multiple GPUs.
    [String]$workerName = $env:computername,

    # Your Ethereum Account Number.
    [String]$etherAcct = "0x96ae82e89ff22b3eff481e2499948c562354cb23",

    # The pool address to mine in.
#    [String]$poolUrl = "eth-us-west1.nanopool.org:9999 -FS eth-us-east1.nanopool.org:9999",
    [String]$poolUrl = "us2.ethermine.org:4444 -FS us1.ethermine.org:4444",

    # Additional arguments, defaults should suffice but can be changed if desired.
    [String]$addlArgs = "--cuda-parallel-hash 4",

    # Time in seconds to wait before checking GPU usage for all miners.
    [Int]$checkup = 30,

    # Minimum CPU usage to check for when deciding if the miner is fucntioning.
    [Int]$minGpuUse = 70
)

function getPoolStats() {
    $restUrl = "https://ethermine.org/api/miner_new/96Ae82E89FF22B3EFF481e2499948c562354CB23"
    $stats = Invoke-RestMethod -Uri $restUrl -ContentType "application/json"
    return $stats.workers
}

function sendEmail() {
  $EmailFrom = "cultclassik@gmail.com"
  $EmailTo = "8173721771@txt.att.net"
  $Subject = "Display Driver stopped"
  $Body = "Miner crashed on $host"
  $SMTPServer = "smtp.gmail.com"
  $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
  $SMTPClient.EnableSsl = $true
  #fill in your email address and password. if using gmail you may need to go to https://myaccount.google.com/security and turn on "Allow less secure Apps"
  $SMTPClient.credentials = new-object Management.Automation.PSCredential “youremail@gmail.com”, (“yourpassword” | ConvertTo-SecureString -AsPlainText -Force)
  $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}

Function getGpuUse([string]$gpuId) {
    # path to nvsmi exe
    Set-Location "C:\Program Files\NVIDIA Corporation\NVSMI"
    $util = .\nvidia-smi.exe --query-gpu="utilization.gpu" --format="csv,noheader,nounits" --id="$gpuId"
    [int]$intUtil = $util
    return $intUtil
}

Function goDig([string]$gpuId) {
Write-host "starting proc on $gpuId"

    $proc = Start-Process -FilePath $minerPath/$minerExe -ArgumentList "-U -S $poolUrl -O $etherAcct.$workerName-gpu$gpuId  --cuda-devices $gpuId $addlArgs" -Passthru
    return $proc.Id
}

Function getGpus() {
    $objGpu = Get-WmiObject -class "Win32_VideoController" -namespace "root\CIMV2"
    $gpus = -1
    foreach ($gpu in $objGpu) {
        if ($gpu.description -like "*nvidia*") {
            $gpus++
            Write-Host "Found GPU ($gpus) ::" $gpu.description
        }
    }
    return $gpus
}

Function recycle($minerPid, $g) {
  $testRunning = Get-Process -Id $minerPid  -ErrorAction SilentlyContinue
  if ($testRunning -eq $null) {
      Write-host "Not running, starting a new miner."
  } else {
      Write-host "Killing Miner.."
      Stop-Process -Id $minerPid -Force -ErrorAction SilentlyContinue
      Wait-Process -Id $minerPid
  }
  $newPid = goDig($g)
  $ledger.Set_Item("$g", "$newPid")
}

Function watcher() {
    $gpus = getGpus
    for ($i=0; $i -lt $gpus+1; $i++) {
        $myPid = goDig($i)
        $ledger.Set_Item("$i", "$myPid")
    }
   # Loop runs forever, killing and restarting the mining process on this GPU if GPU usage drops below threshold.
    while ($true) {
        Start-Sleep $checkup
        $stats = getPoolStats
        $current = Get-Date -Format g
        for ($g=0; $g -lt $gpus+1; $g++) {
            $gpuPerc = getGpuUse("$g")
            $minerPid = $ledger.Get_Item("$g")
            if ($gpuPerc -lt $minGpuUse) {
              Write-Host "$current : GPU $g $gpuPerc, waiting to recheck for possible recycle."
              # Wait another 10 seconds and recycle if usage still below threshold
              Start-Sleep 10
              if ($gpuPerc -lt $minGpuUse) {
                  Write-Host "$current : GPU $g usage is only $gpuPerc, recycling now."
                recycle $minerPid $g
              }
            } else {
                $statsGpu = "" #$stats."$workerName-gpu$g".hashrate
                Write-Host "$current : GPU $g $gpuPerc% : $statsGpu"
            }
        }
    }
}

# Init hashtable to store gpu ids and the miner pid associated with each gpu
$ledger = @{}
# Start mining!
watcher
