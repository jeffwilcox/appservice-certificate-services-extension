@echo off
SET THIS_DIRECTORY=%~dp0
echo Building and packaging extension...

SET EXTENSION_BUILD_LOCAL=..\extension

IF NOT EXIST .\tools (
  MKDIR .\tools
)

IF NOT EXIST .\extension (
  MKDIR .\extension
)

IF NOT EXIST .\tools\nuget.exe (
  CALL PowerShell.exe -ExecutionPolicy Bypass -Command "Invoke-WebRequest https://nuget.org/nuget.exe -OutFile tools\nuget.exe"
)

SET EXTENSION_BUILD_FOLDER=..\..\%EXTENSION_BUILD_LOCAL%
IF EXIST "%EXTENSION_BUILD_LOCAL%\README.md" (
  echo Cleaning previous build...
  RD /S /Q %EXTENSION_BUILD_LOCAL%
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


REM .\tools\nuget pack .\*.nuspec -BasePath .\build -OutputDirectory ..\extension
REM start ..\extension\
