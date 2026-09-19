$ErrorActionPreference = "Stop"

Write-Output "1. Instalando OpenJDK 17..."
winget install --id Microsoft.OpenJDK.17 -e --accept-source-agreements --accept-package-agreements --silent

Write-Output "2. Baixando Flutter SDK..."
winget install --id Google.Flutter -e --accept-source-agreements --accept-package-agreements --silent

Write-Output "3. Configurando Android SDK..."
$AndroidHome = "C:\Android\android-sdk"
if (-Not (Test-Path -Path $AndroidHome)) {
    New-Item -ItemType Directory -Force -Path "$AndroidHome\cmdline-tools" | Out-Null
}

$ZipPath = "C:\Android\cmdline-tools.zip"
Write-Output "Baixando Android Command Line Tools..."
Invoke-WebRequest -Uri "https://dl.google.com/android/repository/commandlinetools-win-11479570_latest.zip" -OutFile $ZipPath

Write-Output "Extraindo Android Tools..."
Expand-Archive -Path $ZipPath -DestinationPath "$AndroidHome\cmdline-tools" -Force
if (Test-Path "$AndroidHome\cmdline-tools\cmdline-tools") {
    Rename-Item -Path "$AndroidHome\cmdline-tools\cmdline-tools" -NewName "latest" -Force
}

Write-Output "Configurando Variáveis de Ambiente..."
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidHome, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $AndroidHome, "User")

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$NewPaths = ";$AndroidHome\cmdline-tools\latest\bin;$AndroidHome\platform-tools"
if ($UserPath -notlike "*$AndroidHome*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath$NewPaths", "User")
}

$env:ANDROID_HOME = $AndroidHome
$env:Path += $NewPaths

Write-Output "Aceitando Licenças do Android e Baixando Plataformas..."
$yes_script = "while(\$true) { Write-Output 'y' }"
powershell -Command $yes_script | & "$AndroidHome\cmdline-tools\latest\bin\sdkmanager.bat" --licenses
& "$AndroidHome\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "platforms;android-34" "build-tools;34.0.0"

Write-Output "Instalação Completa! O terminal precisará ser reiniciado para carregar o Flutter."
