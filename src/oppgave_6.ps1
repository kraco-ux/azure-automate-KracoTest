[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $UrlKortstokk = "http://nav-deckofcards.herokuapp.com/shuffle"
)

$ErrorActionPreference = 'Stop'

$response = Invoke-WebRequest -Uri $UrlKortstokk

$kortstokk = $response.Content | ConvertFrom-Json

function kortstokkTilStreng {
    [OutputType([string])]
    param (
    [object[]]
    $kortstokk
    )
    $streng = ''
    foreach ($kort in $kortstokk) {
    $streng = $streng + "$($kort.suit[0])" + "$($kort.value)" + ","
    }
    return $streng.TrimEnd(",")
    }

    

function sumPoengKortstokk {
    [OutputType([int])]
    param (
        [object[]]
        $kortstokk
    )

    $poengKortstokk = 0 

    foreach ($kort in $kortstokk) {
        $poengKortstokk += switch ($kort.value) {
            { $_ -cin @('J', 'Q', 'K') } { 10 }
            'A' { 11 }
            default { $kort.value }
        }
    }
    return $poengKortstokk
}

Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"
Write-Output "Poengsum: $(sumPoengKortstokk -kortstokk $kortstokk)"

$meg = $kortstokk[0..1]
$kortstokk = $kortstokk[2..$kortstokk.Count]

$magnus = $kortstokk[0..1]
$kortstokk = $kortstokk[2..$kortstokk.Count]

Write-Output "Meg: $(kortStokkTilStreng -kortstokk $meg)"
Write-Output "Magnus: $(kortStokkTilStreng -kortstokk $magnus)"
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"