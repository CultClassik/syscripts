# Originally designed for use with ethminer.﻿
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
    [String]$minerPath="d:\mining\ethminer",

    # Miner executable name.
    [String]$minerExe="ethminer.exe",

    # Worker name, defaults to the computer name.  Will auto-append the GPU number if using multiple GPUs.
    [String]$workerName = $env:computername,

    # Your Ethereum Account Number.
    [String]$etherAcct = "0x96ae82e89ff22b3eff481e2499948c562354cb23",

    # The pool address to mine in.
    [String]$poolUrl = "eth-us-west1.nanopool.org:9999",

    # Additional arguments, defaults should suffice but can be changed if desired.
    [String]$addlArgs = "--cuda-parallel-hash 4",

    # Time in seconds to wait before checking GPU usage for all miners.
    [Int]$checkup = 5,

    # Minimum CPU usage to check for when deciding if the miner is fucntioning.
    [Int]$minGpuUse = 80
)

Function getGpuUse([string]$gpuId) {
    # path to nvsmi exe
    Set-Location "C:\Program Files\NVIDIA Corporation\NVSMI"
    $util = .\nvidia-smi.exe --query-gpu="utilization.gpu" --format="csv,noheader,nounits" --id="$gpuId"
    [int]$intUtil = $util
    return $intUtil
}

Function goDig($gpuId) {
    $proc = Start-Process -FilePath $minerPath/$minerExe -ArgumentList "-U -S $poolUrl -O $etherAcct.$workerName.$gpuId  --cuda-devices $gpuId $addlArgs" -Passthru
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

Function watcher() {
   # Loop runs forever, killing and restarting the mining process on this GPU if GPU usage drops below threshold.
    while ($true) {
        Start-Sleep $checkup
        foreach ($g in $ledger.Keys) {
            $gpuPerc = getGpuUse("$g")
            $minerPid = $ledger[$g]
            if ($gpuPerc -lt $minGpuUse) {
                Write-Host "GPU $g usage is only $gpuPerc!"
                Write-Host "PID::$minerPid"
                $testRunning = Get-Process -Id $minerPid  -ErrorAction SilentlyContinue
                if($testProc -eq $null) {
                    Write-host "Not running, starting a new miner."
                } else {
                    Write-host "Killing Miner.."
                    Stop-Process -Id $minerPid -Force -ErrorAction SilentlyContinue
                    Wait-Process -Id $minerPid
                }
                $ledger[$g] = goDig($g)

            } else {
                Write-Host "GPU $g usage looking good at $gpuPerc, carry on."
            }
        }
    }
}

Function startUp() {
    $gpus = getGpus
    for ($i=0; $i -lt $gpus+1; $i++) {
        $myPid = goDig($i)
        $ledger.Set_Item("$i", "$pid")
        watcher
    }
}

# Init hashtable to store gpu ids and the miner pid associated with each gpu
$ledger = @{}
# Start mining!
startUp
