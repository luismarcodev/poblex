$ErrorActionPreference = 'Stop'

$backendRoot = Split-Path -Parent $PSScriptRoot
$userProfile = [Environment]::GetFolderPath('UserProfile')
$credentialPath = Join-Path $userProfile '.poblex-secrets\firebase-admin.json'

if (-not (Test-Path -LiteralPath $credentialPath)) {
  throw "Firebase service account not found at $credentialPath"
}

$credentialsJson = Get-Content -Raw -LiteralPath $credentialPath
$serviceAccount = $credentialsJson | ConvertFrom-Json

if ($serviceAccount.type -ne 'service_account') {
  throw 'The Firebase credentials file is not a service account.'
}

if ([string]::IsNullOrWhiteSpace($serviceAccount.project_id)) {
  throw 'The Firebase service account has no project_id.'
}

# Keep the private key outside the repository and expose it only to this
# backend process. Nest Config reads process variables before starting FCM.
$env:FCM_PROJECT_ID = $serviceAccount.project_id
$env:FCM_CREDENTIALS_JSON = $credentialsJson

Set-Location -LiteralPath $backendRoot
npm run start:dev
