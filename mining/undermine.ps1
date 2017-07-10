param (
    [string]$minerPath = "c:\mining\ethminer",
    [string]$workerName = $env:computername,
    [string]$etherAcct = "0x96ae82e89ff22b3eff481e2499948c562354cb23",
    [string]$poolUrl = "eth-us-west1.nanopool.org:9999",
    [string]$addlArgs = "-U --cuda-parallel-hash 4"
)

# To do:
#
# Add overclock input params for clock and mem
# Add overclock settings apply

$global:miners = @{}

Function Get-GPUUtil ([string]$gpuID) {
    Set-Location "C:\Program Files\NVIDIA Corporation\NVSMI"
    $util = .\nvidia-smi.exe --query-gpu="utilization.gpu" --format="csv,noheader,nounits" --id="$gpuID"
    [int]$intUtil = $util
    return $intUtil
}

Function Get-GPUs() {
    $objGpu = Get-WmiObject -class "Win32_VideoController" -namespace "root\CIMV2"
    $gpus = -1
    foreach ($gpu in $objGpu) {
        if ($gpu.description -like "*nvidia*") {
            $gpus++
            # add the gpu id using the current count of $pids and a placeholder for the pid once we get it
            $globa:miners.Add("$gpus", "noPidYet")
            Write-Host "Found GPU ($gpus) ::" $gpu.description
        }
    }
    return $gpus
}

Function checkUp([string]$gpuID) {
    if ((Get-GPUUtil ($gpuID)) -lt 80)
    {
        Write-host "Start mining on GPU $i"
        Start-Sleep -Seconds 30
        if ((Get-GPUUtil ($gpuID)) -lt 80)
        {
            Write-Debug "Miner hung... restarting"
            $hungProc = Get-Process -Id $global:miners["$gpuID"]
            Stop-Process -InputObject $hungProc -Force -ErrorAction SilentlyContinue
            Wait-Process -InputObject $hungProc
            goDig($gpuID)
        }
    }
    else {Write-Debug "GPU$gpuID is slaving away like a process that knows what's good for it.."}
}

Function goDig([string]$gpuID) {
    Set-Location $minerPath
    $process = Start-Process ethminer.exe -PassThru -ArgumentList "-S $poolUrl -O $etherAcct.$workerName.$gpuID $addlArgs"
    $global:miners.Set_Item("$gpuID", "$process.Id")
}

Function startUp() {
    $gpus = Get-GPUs  
    for ($i=0; $i -lt $gpus+1; $i++) {
        goDig($i)
    }
}

startUp

$global:miners.Count