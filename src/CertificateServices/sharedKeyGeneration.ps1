#
# Copyright (c) Microsoft Corporation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# TODO: implement the extension version of this

# Do not store analysis information locally (cleans up kudu display)
$env:PSModuleAnalysisCachePath = 'nul'

# Generate a new API key
[Reflection.Assembly]::LoadWithPartialName("System.Security");
$aesProvider = new-object System.Security.Cryptography.AesCryptoServiceProvider;
$apiKey = [System.Convert]::ToBase64String($aesProvider.Key);

# Generate a new GUID to use for the local service path
$guidPath = $([guid]::NewGuid().ToString());

# Store the API key
$apiKeyFolder = $Env:CERTIFICATE_SERVICES_API_KEY_FOLDER;
$apiKeyFilename = 'certificate-service-' + $guidPath + '.key';
$apiKeyPath = Join-Path $apiKeyFolder $apiKeyFilename;
$apiKey | Out-File $apiKeyPath;

# TODO: Make this more efficient than saving the file with many roundtrips

# Place the path inside config
$templateFile=$Env:TRANSLATION_TEMPLATE_FILE;
$massagedFile=$Env:TRANSLATION_OUTPUT_FILE;
$replaceMarker="__LocalCertificateServicePath__";
$replaceValue=$guidPath;
(Get-Content $templateFile | out-string).Replace($replaceMarker, $replaceValue) | Set-Content $massagedFile;

# Place the extension directory
$appServiceExtensionPath = $Env:XDT_EXTENSIONPATH;
$isPrivateExtensionDeployment = [string]::IsNullOrEmpty($appServiceExtensionPath);

$localServicePhysicalPath = '%XDT_EXTENSIONPATH%';
if ($isPrivateExtensionDeployment -eq '1') {
  $localServicePhysicalPath = '%HOME%\site\wwwroot\src\CertificateServices\Certificates';
}

$templateFile=$massagedFile;
$replaceMarker="__LocalCertificateServicePhysicalPath__";
$replaceValue=$localServicePhysicalPath;
(Get-Content $templateFile | out-string).Replace($replaceMarker, $replaceValue) | Set-Content $massagedFile;

$templateFile=$massagedFile;
$replaceMarker="__LocalCertificateFilename__";
$replaceValue=$apiKeyFilename;
(Get-Content $templateFile | out-string).Replace($replaceMarker, $replaceValue) | Set-Content $massagedFile;

# Cleanup any keys that are older than a day old
$days = "-1"
$now = Get-Date
$cutoff = $now.AddDays($days)
Get-ChildItem $apiKeyFolder | Where-Object { $_.LastWriteTime -lt $cutoff } | Remove-Item

# Write to the app web.config of the main site to kick a definite reboot of the site
$wwwroot = '%HOME%\site\wwwroot'; # installed extensions should use this path
if ($isPrivateExtensionDeployment -eq '1') {
  $wwwroot = '..\..\app\';
}

$webConfig = Join-Path $wwwroot 'web.template.config';
if (Test-Path $webConfig) {
  echo 'Writing to the web.config to kick off a site restart...';

  $massagedFile=Join-Path $wwwroot 'web.config';
  $templateFile=$webConfig;
  $replaceMarker='__automatic_reboot_segment__';
  $replaceValue=$guidPath.substring(0, 6);
  $webConfig = Join-Path $wwwroot 'web.template.config';
  (Get-Content $templateFile | out-string).Replace($replaceMarker, $replaceValue) | Set-Content $massagedFile;
}
