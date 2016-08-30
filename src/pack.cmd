@echo off
SET THIS_DIRECTORY=%~dp0
pushd %THIS_DIRECTORY%
echo Building and packaging extension...

SET EXTENSION_BUILD_LOCAL=..\extension

IF NOT EXIST .\tools (
  MKDIR .\tools
)

IF EXIST ..\package (
  rd /s /q ..\package
)

IF NOT EXIST .\tools\nuget.exe (
  CALL PowerShell.exe -ExecutionPolicy Bypass -Command "Invoke-WebRequest https://nuget.org/nuget.exe -OutFile tools\nuget.exe"
)

SET EXTENSION_BUILD_FOLDER=..\..\%EXTENSION_BUILD_LOCAL%
IF EXIST "%EXTENSION_BUILD_LOCAL%\README.md" (
  echo Cleaning previous build...
  RD /S /Q %EXTENSION_BUILD_LOCAL%
)

IF NOT EXIST "%EXTENSION_BUILD_LOCAL%" (
  MKDIR "%EXTENSION_BUILD_LOCAL%"
)

IF NOT EXIST ..\package (
  MKDIR ..\package
)

CALL "build-extension.cmd"

echo.
echo Placing other files of interest for packaging...

:: Install/Uninstall
COPY "%THIS_DIRECTORY%CertificateServices\install.cmd" "%EXTENSION_BUILD_LOCAL%\"
COPY "%THIS_DIRECTORY%CertificateServices\uninstall.cmd" "%EXTENSION_BUILD_LOCAL%\"

:: API key generation scripts
COPY "%THIS_DIRECTORY%CertificateServices\sharedKeyGeneration.ps1" "%EXTENSION_BUILD_LOCAL%\"
COPY "%THIS_DIRECTORY%CertificateServices\applicationHost.template.xdt" "%EXTENSION_BUILD_LOCAL%\"

:: README and LICENSE
COPY "%THIS_DIRECTORY%..\README.md" "%EXTENSION_BUILD_LOCAL%\"
COPY "%THIS_DIRECTORY%..\LICENSE" "%EXTENSION_BUILD_LOCAL%\"

:: What Git commit is this?
:: * Assumes that this project is being built from a cloned Git repo
IF EXIST "%ProgramFiles(x86)%\Git\bin\git.exe" (
  "%ProgramFiles(x86)%\Git\bin\git.exe" rev-parse HEAD >> "%EXTENSION_BUILD_LOCAL%\commit.txt"
  "%ProgramFiles(x86)%\Git\bin\git.exe" remote get-url origin >> "%EXTENSION_BUILD_LOCAL%\repo.txt"
)
IF EXIST "%ProgramFiles%\Git\bin\git.exe" (
  "%ProgramFiles%\Git\bin\git.exe" rev-parse HEAD >> "%EXTENSION_BUILD_LOCAL%\commit.txt"
  "%ProgramFiles%\Git\bin\git.exe" remote get-url origin >> "%EXTENSION_BUILD_LOCAL%\repo.txt"
)

:: Package up the extension
.\tools\nuget pack CertificateServices.nuspec -BasePath ..\extension -OutputDirectory ..\package

:: Show us the prize
CALL start ..\package\

:end
popd
