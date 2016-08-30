@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

:: Build our private extension

:: Setup
:: -----

setlocal enabledelayedexpansion

SET NUGETCOMMAND=nuget
IF EXIST .\tools\nuget.exe (
  SET NUGETCOMMAND=.\tools\nuget.exe
)

IF NOT DEFINED CERTIFICATES_EXTENSION_DEPLOYMENT_TEMP (
  SET CERTIFICATES_EXTENSION_DEPLOYMENT_TEMP=certext%random%
)

IF NOT DEFINED DEPLOYMENT_TEMP (
  SET DEPLOYMENT_TEMP=%temp%\___deployTemp%CERTIFICATES_EXTENSION_DEPLOYMENT_TEMP%
  SET CLEAN_LOCAL_DEPLOYMENT_TEMP=true
)

IF DEFINED CLEAN_LOCAL_DEPLOYMENT_TEMP (
  IF EXIST "%DEPLOYMENT_TEMP%" rd /s /q "%DEPLOYMENT_TEMP%"
  mkdir "%DEPLOYMENT_TEMP%"
)

IF DEFINED MSBUILD_PATH goto MsbuildPathDefined
SET MSBUILD_PATH=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe
:MsbuildPathDefined


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Certificates Extension
:: ------------------

SET CERTIFICATES_SERVICE_NAME=Certificates
SET CERTIFICATE_SERVICE_NAME=CertificateServices
SET CERTIFICATE_TOKEN_GENERATION_APP_NAME=GetAuthenticationToken
SET CERTIFICATE_TOKEN_GENERATION_APP_DIRECTORY=Tools

SET CERTIFICATE_SERVICE_DIRECTORY=%CERTIFICATE_SERVICE_NAME%\
SET CERTIFICATE_SERVICE_SOLUTION=CertificateServices.sln

SET CERTIFICATE_SERVICE_PACKAGES=%CERTIFICATE_SERVICE_DIRECTORY%packages.config
SET CERTIFICATE_SERVICE_PROJECT=%CERTIFICATE_SERVICE_DIRECTORY%CertificateService\CertificateService.csproj
SET CERTIFICATES_PROJECT=%CERTIFICATE_SERVICE_DIRECTORY%Certificates\Certificates.csproj
SET CERTIFICATE_SERVICE_CONSOLE_PROJECT=%CERTIFICATE_SERVICE_DIRECTORY%GetAuthenticationToken\GetAuthenticationToken.csproj
SET CERTIFICATE_SERVICE_IN_PLACE_DEPLOYMENT=1

:: 1. Restore NuGet packages
echo call :ExecuteCmd %NUGETCOMMAND% restore "%CERTIFICATE_SERVICE_SOLUTION%"
call :ExecuteCmd %NUGETCOMMAND% restore "%CERTIFICATE_SERVICE_SOLUTION%"
IF !ERRORLEVEL! NEQ 0 goto error

:: 2. Build to the temporary path - certificate service
echo.
echo Building %CERTIFICATE_SERVICE_NAME%
IF DEFINED EXTENSION_BUILD_FOLDER (
  call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATE_SERVICE_PROJECT%" /nologo /verbosity:m /t:WebFileSystemPublish /p:webpublishmethod=filesystem /p:Configuration=Release /p:UseSharedCompilation=false /p:PublishUrl=%EXTENSION_BUILD_FOLDER%\%CERTIFICATE_SERVICE_NAME%
) ELSE (
  IF /I "%CERTIFICATE_SERVICE_IN_PLACE_DEPLOYMENT%" NEQ "1" (
    call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATE_SERVICE_PROJECT%" /nologo /verbosity:m /t:Build /t:pipelinePreDeployCopyAllFilesToOneFolder /p:_PackageTempDir="%DEPLOYMENT_TEMP%";AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release;UseSharedCompilation=false /p:SolutionDir="%CERTIFICATE_SERVICE_DIRECTORY%" %SCM_BUILD_ARGS%
  ) ELSE (
    call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATE_SERVICE_PROJECT%" /nologo /verbosity:m /t:Build /p:AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release;UseSharedCompilation=false /p:SolutionDir="%CERTIFICATE_SERVICE_DIRECTORY%" %SCM_BUILD_ARGS%
  )
)
IF !ERRORLEVEL! NEQ 0 goto error

:: 3. Build to the temporary path - certificates
echo.
echo Building %CERTIFICATES_SERVICE_NAME%
IF DEFINED EXTENSION_BUILD_FOLDER (
  call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATES_PROJECT%" /nologo /verbosity:m /t:WebFileSystemPublish /p:webpublishmethod=filesystem /p:Configuration=Release /p:UseSharedCompilation=false /p:PublishUrl=%EXTENSION_BUILD_FOLDER%\%CERTIFICATES_SERVICE_NAME%
) ELSE (
  IF /I "%CERTIFICATE_SERVICE_IN_PLACE_DEPLOYMENT%" NEQ "1" (
    call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATES_PROJECT%" /nologo /verbosity:m /t:Build /t:pipelinePreDeployCopyAllFilesToOneFolder /p:_PackageTempDir="%DEPLOYMENT_TEMP%";AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release;UseSharedCompilation=false /p:SolutionDir="%CERTIFICATE_SERVICE_DIRECTORY%" %SCM_BUILD_ARGS%
  ) ELSE (
    call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATES_PROJECT%" /nologo /verbosity:m /t:Build /p:AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release;UseSharedCompilation=false /p:SolutionDir="%CERTIFICATE_SERVICE_DIRECTORY%" %SCM_BUILD_ARGS%
  )
)
IF !ERRORLEVEL! NEQ 0 goto error

:: 4. Build the console app
echo.
echo Building %CERTIFICATE_TOKEN_GENERATION_APP_NAME%
IF DEFINED EXTENSION_BUILD_FOLDER (
  call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATE_SERVICE_CONSOLE_PROJECT%" /nologo /verbosity:m /t:Rebuild /p:OutputPath=%EXTENSION_BUILD_FOLDER%\%CERTIFICATE_TOKEN_GENERATION_APP_DIRECTORY%;Configuration=Release;UseSharedCompilation=false /p:SolutionDir="%CERTIFICATE_SERVICE_DIRECTORY%" %SCM_BUILD_ARGS%
) ELSE (
  call :ExecuteCmd "%MSBUILD_PATH%" "%CERTIFICATE_SERVICE_CONSOLE_PROJECT%" /nologo /verbosity:m /t:Build /p:Configuration=Release;UseSharedCompilation=false /p:SolutionDir="%CERTIFICATE_SERVICE_DIRECTORY%" %SCM_BUILD_ARGS%
)
IF !ERRORLEVEL! NEQ 0 goto error


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
echo An error has occurred during the extension build.
call :exitSetErrorLevel
call :exitFromFunction 2>nul

:exitSetErrorLevel
exit /b 1

:exitFromFunction
()

:end
endlocal
echo Finished extension build successfully.