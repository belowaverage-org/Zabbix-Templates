if (
    ($null -in $env:ZBX_APIKEY, $env:ZBX_INSTANCE) -or 
    ([string]::Empty -in $env:ZBX_APIKEY, $env:ZBX_INSTANCE)
) {
    $env:ZBX_APIKEY = Read-Host -Prompt "Enter the API key"
    $env:ZBX_INSTANCE = Read-Host -Prompt "Enter the instance URL"
}
$api = "$env:ZBX_INSTANCE/api_jsonrpc.php"

$templates = Invoke-WebRequest -UseBasicParsing -Uri $api -Method Post -Headers @{
    "Content-Type" = "application/json-rpc"
    "Authorization" = "Bearer $env:ZBX_APIKEY"
} -Body (ConvertTo-Json @{
    "jsonrpc" = "2.0"
    "method" = "template.get"
    "params" = @{
        "output" = "templateid", "name"
    }
    "id" = 1
}) | ConvertFrom-Json

$template = Invoke-WebRequest -UseBasicParsing -Uri $api -Method Post -Headers @{
    "Content-Type" = "application/json-rpc"
    "Authorization" = "Bearer $env:ZBX_APIKEY"
} -Body (ConvertTo-Json -Depth 4 @{
    "jsonrpc" = "2.0"
    "method" = "configuration.export"
    "params" = @{
        "format" = "yaml"
        "prettyprint" = $true
        "options" = @{
            "templates" = $templates.result | Select-Object -ExpandProperty templateid
        }
    }
    "id" = 1
}) | ConvertFrom-Json
$template.result | Out-File -FilePath "combined.yaml" -Encoding utf8

$templates.result | ForEach-Object {
    $id = $_.templateid
    $name = $_.name
    $template = Invoke-WebRequest -UseBasicParsing -Uri $api -Method Post -Headers @{
        "Content-Type" = "application/json-rpc"
        "Authorization" = "Bearer $env:ZBX_APIKEY"
    } -Body (ConvertTo-Json -Depth 3 @{
        "jsonrpc" = "2.0"
        "method" = "configuration.export"
        "params" = @{
            "format" = "yaml"
            "prettyprint" = $true
            "options" = @{
                "templates" = @($id)
            }
        }
        "id" = 1
    }) | ConvertFrom-Json
    $template.result | Out-File -FilePath "$name.yaml" -Encoding utf8
}