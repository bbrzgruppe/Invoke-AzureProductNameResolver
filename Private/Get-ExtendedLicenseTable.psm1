function Get-ExtendedLicenseTable {
    [OutputType([hashtable])]
    [CmdletBinding()]
    param (
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $ExtendedLookup = @{}

    # fetch Phillips extended table
    $WebRequestParams = @{
        Uri             = 'https://scripting.up-in-the.cloud/licensing/list-of-o365-license-skuids-and-names.html'
        UseBasicParsing = $true
    }
    try {
        $Response = Invoke-WebRequest @WebRequestParams 
    } catch {
        throw $_
    } 

    $html = [HtmlAgilityPack.HtmlDocument]::new()
    $html.LoadHtml($Response.content)
    $SKUTable = $html.DocumentNode.SelectNodes("//pre[contains(., 'skuids = @{')]").InnerText

    $StringContent = $SKUTable.Trim().TrimStart('$skuids = @{').TrimEnd('}').Split(';').Trim() | .{process{
        # can't filter with better since Microsoft doesn't always adhere to their standard SKU format 
        # WIN10_VDA_E3_VIRTUALIZATION RIGHTS FOR WINDOWS 10 (E3/E5+VDA)'
        if ($_ -match "^'.*'='.*'$" ) { $_ }
        else { Write-Warning -Message 'Strange results were returned for extended table'}
    }}

    foreach ($line in $StringContent) {
        $SKU, $Name = $line.Split('=')[0,1].Trim().Trim("'")
        $ExtendedLookup[$SKU] = $Name
    }

    return $ExtendedLookup
}
