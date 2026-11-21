# Systel Clearance Local Server
$port = 8080
$path = $PSScriptRoot
if (-not $path) { $path = "C:\Users\Yasser Awad\.gemini\antigravity\scratch\systel_settlement" }

$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback|vEthernet' } | Select-Object -First 1).IPAddress

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SYSTEL TELECOM - LIVE CLEARANCE SERVER" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Local:   http://localhost:$port" -ForegroundColor Yellow
if ($ip) {
    Write-Host "Mobile:  http://$($ip):$port (افتـح الرابط من موبايل المهندس على نفس شبكة الواي فاي)" -ForegroundColor Cyan
}
Write-Host "==========================================================" -ForegroundColor Cyan

# Open in browser
Start-Process "http://localhost:$port"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:$port/")
try {
    $listener.Start()
} catch {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $response = $context.Response
    $reqPath = $context.Request.Url.LocalPath
    if ($reqPath -eq "/" -or $reqPath -eq "") { $reqPath = "/index.html" }
    $filePath = Join-Path $path $reqPath.TrimStart('/')
    
    if (Test-Path $filePath) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        if ($ext -eq ".html") { $response.ContentType = "text/html; charset=utf-8" }
        elseif ($ext -eq ".js") { $response.ContentType = "application/javascript" }
        elseif ($ext -eq ".css") { $response.ContentType = "text/css" }
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
    }
    $response.Close()
}
