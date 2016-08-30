@echo off
echo Building and packaging extension...

IF NOT EXIST .\tools (
  MKDIR .\tools
)

IF NOT EXIST .\extension (
  MKDIR .\extension
)

IF NOT EXIST .\tools\nuget.exe (
  CALL PowerShell.exe -ExecutionPolicy Bypass -Command "Invoke-WebRequest https://nuget.org/nuget.exe -OutFile tools\nuget.exe"
)

SET SCM_BUILD_ARGS=/p:OutputPath=..\..\..\extension
CALL "build-extension.cmd"

REM .\tools\nuget pack .\*.nuspec -BasePath .\build -OutputDirectory ..\extension
REM start ..\extension\
