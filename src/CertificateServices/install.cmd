@echo off
setlocal enabledelayedexpansion

echo Installing extension...

:: Create the certificate services API key folder
SET CERTIFICATE_SERVICES_API_KEY_FOLDER=%HOME%\site\apikeys
IF NOT EXIST "%CERTIFICATE_SERVICES_API_KEY_FOLDER%" (
  echo Creating the local API key folder: %CERTIFICATE_SERVICES_API_KEY_FOLDER%
  mkdir "%CERTIFICATE_SERVICES_API_KEY_FOLDER%"
)

:: Building and configuring local service keys
SET TRANSLATION_TEMPLATE_FILE=applicationHost.template.xdt
SET TRANSLATION_OUTPUT_FILE=%HOME%\site\applicationHost.xdt
IF EXIST "%TRANSLATION_TEMPLATE_FILE%" (
  echo Translating and building applicationHost.xdt...
  CALL PowerShell.exe -ExecutionPolicy Bypass -File .\sharedKeyGeneration.ps1
  IF !ERRORLEVEL! NEQ 0 goto error
)

goto end

:: Execute command routine that will echo out when error
:ExecuteCmd
setlocal
set _CMD_=%*
call %_CMD_%
if "%ERRORLEVEL%" NEQ "0" echo Failed exitCode=%ERRORLEVEL%, command=%_CMD_%
exit /b %ERRORLEVEL%

:error
endlocal
echo An error has occurred during web site deployment.
call :exitSetErrorLevel
call :exitFromFunction 2>nul

:exitSetErrorLevel
exit /b 1

:exitFromFunction
()

:end
endlocal
echo Extension installation done
