$TEL_TOKEN = ''
$CHAT_ID = ''

function Get-SysProxy {
    $proxies = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer
    if ($proxies) {
        if ($proxies -ilike "*=*") {
            $proxies -replace "=", "://" -split (';') | Select-Object -First 1
        }

        else {
            "http://" + $proxies
        }
    }    
}


function Test-ProxyConnectivity([string]$proxy) {


    try {
        (Invoke-WebRequest "https://www.google.com" -Proxy $proxy).StatusCode
        return $true
    }
    catch {
        Write-Host "connection failed, check to see if your proxy settings are valid or not."
        return $false
    }
}


function Send-Telegram {
    param (
        [string]$file,
        $proxy = $null
    )
    
        
    if ($null -eq $proxy) {
        $proxy = Get-SysProxy
    }
    else {
        return $false
    }

    if (Test-ProxyConnectivity($proxy)) {

        $file = Resolve-Path $file
        $file = Get-Content($file) -Raw
        Invoke-RestMethod -Proxy $proxy -Body $file -Method "POST" "https://api.telegram.org/bot$TEL_TOKEN/sendDocument\?chat_id\=$CHAT_ID"
    }
}


Send-Telegram -file "c:\Users\amir\Pictures\Screenshots\Screenshot 2024-04-09 234356.png"
