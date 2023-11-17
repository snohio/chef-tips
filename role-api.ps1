$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("api-token", "PUT AUTOMATE TOKEN HERE")
$headers.Add("Content-Type", "application/json")

$body = "{
`n    `"name`": `"Devops Owner`",
`n    `"id`": `"devops-owner`",
`n    `"actions`": [
`n        `"reportmanager:*`",
`n        `"infra:nodes:get`",
`n        `"infra:nodes:list`",
`n        `"compliance:*:get`",
`n        `"compliance:*:list`"
`n    ],
`n    `"projects`": []
`n}"

$response = Invoke-RestMethod 'https://snohio.azure.chef-demo.com/apis/iam/v2/roles' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json