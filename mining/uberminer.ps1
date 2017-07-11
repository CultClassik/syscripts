# Originally designed for use with ethminer.

# To do:
#
# Ensure worker id will work for various pools - nano, ethermine etc
# Add overclock input params for clock and mem
# Add overclock settings apply
# Possibly use PS background jobs rather than execs
# allow different settings based on GPU model i.e. 1060, 1070 etc

param (
    # Folder path to the miner exe.
    [string]$minerPath = "c:\mining\ethminer",

    # Miner executable name.
    [string]$minerExe = "ethminer.exe",

    # Worker name, defaults to the computer name.  Will auto-append the GPU number if using multiple GPUs.
    [string]$workerName = $env:computername,

    # Your Ethereum Account Number
    [string]$etherAcct = "0x96ae82e89ff22b3eff481e2499948c562354cb23",

    # The pool address to mine in.
    [string]$poolUrl = "eth-us-west1.nanopool.org:9999",

    # Additional arguments, defaults should suffice but can be changed if desired.
    [string]$addlArgs = "--cuda-parallel-hash 4"
)

$processManager = {
    Function getGpuUse ([string]$gpuId) {
        # path to nvsmi exe
        Set-Location "C:\Program Files\NVIDIA Corporation\NVSMI"
        $util = .\nvidia-smi.exe --query-gpu="utilization.gpu" --format="csv,noheader,nounits" --id="$gpuId"
        [int]$intUtil = $util
        return $intUtil
    }

    Function goDig([string]$gpuId) {
        Set-Location $minerPath
        $proc = [diagnostics.process]::start("$minerPath\$minerExe -U -S $poolUrl -O $etherAcct.$workerName.$gpuId  --cuda-devices $gpuId $addlArgs")
        $proc.WaitToStart()
        return $proc.Id
    }

    Function watcher([string]$gpuId) {
        # Initial mining process starts here
        $minerPid = goDig($gpuId)

        # Loop runs forever, killing and restarting the mining process on this GPU if GPU usage drops below threshold.
        while ($true) {
            Start-Sleep 20
            $gpuPerc = getGpuUse($gpuId)
            if ($gpuPerc -lt 80) {
                Write-Host "GPU $gpuId usage is only $gpuPerc, killing the miner."
                Stop-Process -Id $minerPid -Force -ErrorAction SilentlyContinue
                Wait-Process -Id $minerPid
                $minerPid = goDig($gpuId)
            } else {
                Write-Host "GPU $gpuId usage looking good at $gpuPerc, carry on."
            }
        }
    }
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


Function startUp() {
    $gpus = getGpus
    for ($i=0; $i -lt $gpus+1; $i++) {
        Start-Process -FilePath PowerShell -ArgumentList "-Command & {$processManager watcher('$i')}"
    }
}

# Start mining!
startUp
