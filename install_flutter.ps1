$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

Write-Host "Creando directorio C:\src..."
New-Item -ItemType Directory -Force -Path "C:\src" | Out-Null

Write-Host "Descargando Flutter SDK (rápido)..."
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.2-stable.zip" -OutFile "C:\src\flutter.zip"

Write-Host "Extrayendo Flutter SDK..."
Expand-Archive -Path "C:\src\flutter.zip" -DestinationPath "C:\src" -Force

Write-Host "Configurando variables de entorno..."
$userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if ($userPath -notlike "*C:\src\flutter\bin*") {
    $newPath = $userPath + ";C:\src\flutter\bin"
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
    $env:Path = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Process) + ";C:\src\flutter\bin"
}

Write-Host "Flutter instalado exitosamente."
Remove-Item -Path "C:\src\flutter.zip" -Force
