@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

:: Heavily customized deployment script
:: - Primary App: Node.js
:: - Simulated Private Extension: .NET WebAPI x2 apps

:: ----------------------
:: KUDU Deployment Script
:: Version: 1.0.6-1.0.8
:: ----------------------

:: Prerequisites
:: -------------

:: Verify node.js installed
where node 2>nul >nul
IF %ERRORLEVEL% NEQ 0 (
  echo Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment.
  goto error
)

:: Setup
:: -----

setlocal enabledelayedexpansion

SET ARTIFACTS=%~dp0%..\artifacts

IF NOT DEFINED DEPLOYMENT_SOURCE (
  SET DEPLOYMENT_SOURCE=%~dp0%.
)

IF NOT DEFINED DEPLOYMENT_TARGET (
  SET DEPLOYMENT_TARGET=%ARTIFACTS%\wwwroot
)

IF NOT DEFINED NEXT_MANIFEST_PATH (
  SET NEXT_MANIFEST_PATH=%ARTIFACTS%\manifest

  IF NOT DEFINED PREVIOUS_MANIFEST_PATH (
    SET PREVIOUS_MANIFEST_PATH=%ARTIFACTS%\manifest
  )
)

IF NOT DEFINED KUDU_SYNC_CMD (
  :: Install kudu sync
  echo Installing Kudu Sync
  call npm install kudusync -g --silent
  IF !ERRORLEVEL! NEQ 0 goto error

  :: Locally just running "kuduSync" would also work
  SET KUDU_SYNC_CMD=%appdata%\npm\kuduSync.cmd
)

IF NOT DEFINED DEPLOYMENT_TEMP (
  SET DEPLOYMENT_TEMP=%temp%\___deployTemp%random%
  SET CLEAN_LOCAL_DEPLOYMENT_TEMP=true
)

IF DEFINED CLEAN_LOCAL_DEPLOYMENT_TEMP (
  IF EXIST "%DEPLOYMENT_TEMP%" rd /s /q "%DEPLOYMENT_TEMP%"
  mkdir "%DEPLOYMENT_TEMP%"
)

IF DEFINED MSBUILD_PATH goto MsbuildPathDefined
SET MSBUILD_PATH=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe
:MsbuildPathDefined


goto Deployment

:: Utility Functions
:: -----------------

:SelectNodeVersion

IF DEFINED KUDU_SELECT_NODE_VERSION_CMD (
  :: The following are done only on Windows Azure Websites environment
  call %KUDU_SELECT_NODE_VERSION_CMD% "%DEPLOYMENT_SOURCE%" "%DEPLOYMENT_TARGET%" "%DEPLOYMENT_TEMP%"
  IF !ERRORLEVEL! NEQ 0 goto error

  IF EXIST "%DEPLOYMENT_TEMP%\__nodeVersion.tmp" (
    SET /p NODE_EXE=<"%DEPLOYMENT_TEMP%\__nodeVersion.tmp"
    IF !ERRORLEVEL! NEQ 0 goto error
  )

  IF EXIST "%DEPLOYMENT_TEMP%\__npmVersion.tmp" (
    SET /p NPM_JS_PATH=<"%DEPLOYMENT_TEMP%\__npmVersion.tmp"
    IF !ERRORLEVEL! NEQ 0 goto error
  )

  IF NOT DEFINED NODE_EXE (
    SET NODE_EXE=node
  )

  SET NPM_CMD="!NODE_EXE!" "!NPM_JS_PATH!"
) ELSE (
  SET NPM_CMD=npm
  SET NODE_EXE=node
)

goto :EOF

:Deployment

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Private Extensions
:: ------------------

echo Private extension building and installing app services...

:: 1. Build the private extension
pushd .\src
CALL .\build-extension.cmd
popd
IF !ERRORLEVEL! NEQ 0 goto error

:: 2. Run extension uninstall/install
IF EXIST "%DEPLOYMENT_SOURCE%%CERTIFICATE_SERVICE_INSTALL%" (
  echo Installing private extension...
  pushd "%DEPLOYMENT_SOURCE%%CERTIFICATE_SERVICE_DIRECTORY%"
  :: for local testing only SET HOME=%systemdrive%\z\appservice\home
  CALL "%DEPLOYMENT_SOURCE%%CERTIFICATE_SERVICE_INSTALL%"
  popd

  IF !ERRORLEVEL! NEQ 0 goto error
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Deployment
:: ----------


SET NODE_APPLICATION_DIRECTORY=\app

echo Handling customized node.js deployment.

:: Changes: KuduSync happens after installation of modules now

:: 1. Select node version
call :SelectNodeVersion

:: 2. Clean all existing modules
IF EXIST "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%\node_modules" (
  pushd "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%"
  IF /I "%SKIP_NPM_CLEAN%" NEQ "1" (
REM    echo Existing npm modules found, removing...
REM    rmdir /s /q node_modules
    IF !ERRORLEVEL! NEQ 0 goto error
  )
  popd
)

:: 3. Customize npm
IF EXIST "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%\package.json" (
  pushd "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%"
  echo Installing npm packages at the deploy source of %DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%
  call :ExecuteCmd !NPM_CMD! config set color false
  IF !ERRORLEVEL! NEQ 0 goto error
  call :ExecuteCmd !NPM_CMD! config set progress false
  IF !ERRORLEVEL! NEQ 0 goto error
  popd
)

:: 4. Install npm packages
IF EXIST "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%\package.json" (
  pushd "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%"
  call :ExecuteCmd !NPM_CMD! install --production
  IF !ERRORLEVEL! NEQ 0 goto error
  popd
)

:: 5. Install npm development packages
IF EXIST "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%\package.json" (
  pushd "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%"
  call :ExecuteCmd !NPM_CMD! install --only=dev
  IF !ERRORLEVEL! NEQ 0 goto error
  popd
)


:: 6. Bower
IF EXIST "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%\bower.json" (
  echo Installing Bower components...
  pushd "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%"
  call node_modules\.bin\bower install
  IF !ERRORLEVEL! NEQ 0 goto error
  popd
)

:: 7. Grunt
IF EXIST "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%\Gruntfile.js" (
  pushd "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%"
  echo Grunting...
  call :ExecuteCmd !NPM_CMD! install grunt-cli
  IF !ERRORLEVEL! NEQ 0 goto error
  call node_modules\.bin\grunt --no-color default
  IF !ERRORLEVEL! NEQ 0 goto error
  popd
)

::8. Move web.config up from the app
IF EXIST "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%\web.config" (
  pushd "%DEPLOYMENT_SOURCE%%NODE_APPLICATION_DIRECTORY%"
  move web.config ..\
  popd
  IF !ERRORLEVEL! NEQ 0 goto error
)

:: 9. KuduSync
IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_SOURCE%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
  IF !ERRORLEVEL! NEQ 0 goto error
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Post deployment stub
IF DEFINED POST_DEPLOYMENT_ACTION call "%POST_DEPLOYMENT_ACTION%"
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
echo An error has occurred during web site deployment.
call :exitSetErrorLevel
call :exitFromFunction 2>nul

:exitSetErrorLevel
exit /b 1

:exitFromFunction
()

:end
endlocal
echo Finished successfully.