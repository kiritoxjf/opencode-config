[CmdletBinding()]
param(
    [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginsPath = Join-Path $repoRoot "plugins.json"
$mcpPath = Join-Path $repoRoot "mcp.json"
$variablesPath = Join-Path $repoRoot "variables.json"

function Get-ExistingConfigPath {
    param([string]$RequestedPath)

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RequestedPath)
    }

    $configDirectory = Join-Path $env:USERPROFILE ".config\opencode"
    $jsoncPath = Join-Path $configDirectory "opencode.jsonc"
    $jsonPath = Join-Path $configDirectory "opencode.json"

    if (Test-Path $jsoncPath) { return $jsoncPath }
    if (Test-Path $jsonPath) { return $jsonPath }
    return $jsoncPath
}

function ConvertFrom-Jsonc {
    param([Parameter(Mandatory)][string]$Text)

    # Match complete strings first so comment markers and commas in strings survive.
    $stringsAndComments = '"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*[\s\S]*?\*/'
    $withoutComments = [regex]::Replace($Text, $stringsAndComments, {
        param($match)
        if ($match.Value.StartsWith('"')) { return $match.Value }
        return ' '
    })
    $stringsAndTrailingCommas = '"(?:\\.|[^"\\])*"|,(?=\s*[}\]])'
    $normalized = [regex]::Replace($withoutComments, $stringsAndTrailingCommas, {
        param($match)
        if ($match.Value.StartsWith('"')) { return $match.Value }
        return ''
    })
    $parsed = ConvertFrom-Json -InputObject $normalized
    return $parsed
}

function Read-JsonFile {
    param([Parameter(Mandatory)][string]$Path)
    return ConvertFrom-Jsonc ([IO.File]::ReadAllText($Path))
}

function Add-Or-SetProperty {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][AllowEmptyCollection()]$Value
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        $Object | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
    } else {
        $property.Value = $Value
    }
}

function Read-SecretValue {
    param([Parameter(Mandatory)][string]$Prompt)

    $secureValue = Read-Host -Prompt $Prompt -AsSecureString
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    }
}

function Read-VariableValues {
    param([Parameter(Mandatory)]$Definitions)

    $values = @{}
    $index = 0
    foreach ($definition in $Definitions.variables) {
        $index++
        Write-Host "[$index/$(@($Definitions.variables).Count)] $($definition.name)" -ForegroundColor Cyan
        $name = [string]$definition.name
        $label = [string]$definition.label
        $required = [bool]$definition.required
        $secret = [bool]$definition.secret

        do {
            $valid = $true
            if ($secret) {
                $value = Read-SecretValue -Prompt "$label [$name]"
            } else {
                $value = Read-Host -Prompt "$label [$name]"
            }

            if ($required -and [string]::IsNullOrWhiteSpace($value)) {
                Write-Warning "变量 $name 不能为空，请重新输入。"
                $valid = $false
            } elseif ($definition.PSObject.Properties['pattern'] -and $value -notmatch $definition.pattern) {
                Write-Warning "输入格式不正确：$($definition.hint)"
                $valid = $false
            }
        } while (-not $valid)

        $values[$name] = $value
    }

    return $values
}

function ConvertTo-JsonStringContent {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Value)

    $jsonString = ConvertTo-Json -InputObject $Value -Compress
    return $jsonString.Substring(1, $jsonString.Length - 2)
}

function Resolve-TemplateValues {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][hashtable]$Values
    )

    # One pass: values containing {{...}} are literal user data, not templates.
    return [regex]::Replace($Text, '\{\{([A-Za-z_][A-Za-z0-9_]*)\}\}', {
        param($match)
        $name = $match.Groups[1].Value
        if (-not $Values.ContainsKey($name)) {
            throw "模板使用了 variables.json 未声明的变量: $name"
        }
        return ConvertTo-JsonStringContent ([string]$Values[$name])
    })
}

$configPath = Get-ExistingConfigPath $ConfigPath
$pluginsText = [IO.File]::ReadAllText($pluginsPath)
$mcpText = [IO.File]::ReadAllText($mcpPath)
$variableDefinitions = Read-JsonFile $variablesPath

# Fail before prompting if the existing configuration cannot be read.
$configExists = Test-Path -LiteralPath $configPath
if ($configExists) {
    $originalText = [IO.File]::ReadAllText($configPath)
    $config = ConvertFrom-Jsonc $originalText
} else {
    $config = [PSCustomObject]@{ '$schema' = 'https://opencode.ai/config.json' }
}
if ($config -isnot [PSCustomObject]) { throw 'OpenCode 配置顶层必须是 JSON 对象。' }

$declared = @{}
foreach ($definition in $variableDefinitions.variables) {
    $name = [string]$definition.name
    if ($name -cnotmatch '^[A-Z_][A-Z0-9_]*$' -or $declared.ContainsKey($name)) {
        throw "变量名无效或重复: $name"
    }
    $declared[$name] = ''
}
# Validate JSON and placeholders before collecting any sensitive input.
$null = ConvertFrom-Jsonc (Resolve-TemplateValues $pluginsText $declared)
$null = ConvertFrom-Jsonc (Resolve-TemplateValues $mcpText $declared)

Write-Host "将更新 OpenCode 配置: $configPath" -ForegroundColor Cyan
Write-Host "逐项输入本机路径和 Token；仅写入本机配置，不设置系统环境变量。" -ForegroundColor Yellow
$values = Read-VariableValues $variableDefinitions
$plugins = @(ConvertFrom-Jsonc (Resolve-TemplateValues $pluginsText $values))
$mcp = ConvertFrom-Jsonc (Resolve-TemplateValues $mcpText $values)

Add-Or-SetProperty -Object $config -Name "plugins" -Value $plugins
$mcpProperty = $config.PSObject.Properties["mcp"]
if ($null -eq $mcpProperty -or $null -eq $mcpProperty.Value) {
    Add-Or-SetProperty -Object $config -Name "mcp" -Value ([PSCustomObject]@{})
}
if ($config.mcp -isnot [PSCustomObject]) { throw '现有 mcp 配置必须是 JSON 对象。' }
Add-Or-SetProperty -Object $config.mcp -Name "servers" -Value $mcp.servers

$json = $config | ConvertTo-Json -Depth 100
$null = ConvertFrom-Jsonc $json
$configDirectory = Split-Path -Parent $configPath
New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
$temporaryPath = Join-Path $configDirectory ([IO.Path]::GetRandomFileName())
$backupPath = $null
try {
    [IO.File]::WriteAllText($temporaryPath, $json, (New-Object System.Text.UTF8Encoding($false)))
    if ($configExists) {
        if ([IO.File]::ReadAllText($configPath) -cne $originalText) {
            throw '输入期间配置已被其他程序修改，请重新运行脚本。'
        }
        $backupPath = "$configPath.bak-$([guid]::NewGuid().ToString('N'))"
        [IO.File]::Replace($temporaryPath, $configPath, $backupPath)
    } else {
        [IO.File]::Move($temporaryPath, $configPath)
    }
} finally {
    if (Test-Path -LiteralPath $temporaryPath) { Remove-Item -LiteralPath $temporaryPath -Force }
}

Write-Host "OpenCode 的 plugins 和 mcp.servers 已更新。" -ForegroundColor Green
if ($backupPath) {
    Write-Host "原配置备份: $backupPath" -ForegroundColor DarkGray
}
Write-Host "必要时在 OpenCode 中执行 /reload。" -ForegroundColor Cyan
