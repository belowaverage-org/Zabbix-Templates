$Global:bixHost = "ba-zbx1"
$Global:bixApi = "api_jsonrpc.php"
$Global:bixToken = "TOKENGOESHERE"

function Invoke-BixRequest($Method, $Params = @{}) {
    $body = ConvertTo-Json -Depth 100 -InputObject @{
        jsonrpc = "2.0"
        method = $Method
        id = 0
        auth = $Global:bixToken
        params = $Params
    }
    $response = Invoke-WebRequest -UseBasicParsing -Uri "https://$($Global:bixHost)/$($Global:bixApi)" -ContentType "application/json-rpc" -Method Post -Body $body
    return (ConvertFrom-Json -InputObject $response.Content).result
}
$LLDItems = Invoke-BixRequest -Method discoveryrule.get -Params @{
    output = "itemid"
    monitored = "true"
}
$count = 0
$Params = [System.Collections.Generic.List[System.Object]]::new()
foreach($item in $LLDItems) {
    $Params.Add(@{
        type = 6
        request = $item
    })
    if ($count++ -eq 1000) {
        Invoke-BixRequest -Method task.create -Params @(
            $Params
        )
        $count = 0
        $Params.Clear()
    }
}
Invoke-BixRequest -Method task.create -Params @(
    $Params
)
