@echo off
echo Installing extension...

:: Create the shared API key folder

:: Generate an API key, storing it in a randomly named file

:: Translate the applicationHost.config
SET TRANSLATION_TEMPLATE_FILE=applicationHost.template.xdt
SET TRANSLATION_OUTPUT_FILE=%HOME%\site\applicationHost.xdt
SET TRANSLATION_TEMPLATE_REPLACEMENT_MARKER=[DeploymentGuid]
SET TRANSLATION_TEMPLATE_REPLACEMENT_VALUE=HelloWorld
IF EXIST "%TRANSLATION_TEMPLATE_FILE%" (
  echo Translating and building applicationHost.xdt replacing "%TRANSLATION_TEMPLATE_REPLACEMENT_MARKER%" with "%TRANSLATION_TEMPLATE_REPLACEMENT_VALUE%"
  CALL PowerShell.exe -ExecutionPolicy Bypass -Command "&{"^
    "$templateFile=\"%TRANSLATION_TEMPLATE_FILE%\";"^
    "$massagedFile=\"%TRANSLATION_OUTPUT_FILE%\";"^
    "$replaceMarker=\"%REPLACEMENTMARKER%\";"^
    "$replaceValue=\"%TRANSLATION_TEMPLATE_REPLACEMENT_VALUE%\";"^
    "(Get-Content $templateFile | out-string).Replace($replaceMarker, $replaceValue) | Set-Content $massagedFile;"^
    "\"};"
)

