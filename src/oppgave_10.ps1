[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $UrlKortstokk = "http://nav-deckofcards.herokuapp.com/shuffle"
)

#Stopp scriptet hvis noe feil skjer, ikke fortsett videre.
$ErrorActionPreference = 'Stop'

#Send forespørsel til webside $UrlKortstokk
$response = Invoke-WebRequest -Uri $UrlKortstokk

#Plukk ut linjen Content fra webside forespørsel, og konverterer til enkel Tabell lese format fra JSON
$kortstokk = $response.Content | ConvertFrom-Json

<#
Funksjon kortTilStreng:
Denne funkjonen plukker ut første bokstav i feletet suit + tar vedien i feltet value, og legger til en komma for hver linje den går gjennom.
TrimEnd fjerner komma i siste resulatet.
Gir resultatet til slutt i en rett linje(Streng).
#>
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

    
<#
Funksjon sumPoenKortstokk:
Legger inn verdien til kortstokk(Hvis J,Q eller K er verdien 10, A har verdi 11)
Default kort har vedi 0.
#>
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

<# 
Kortstokk:
Skriv ut resultatet Kortstokk etter at den har hvert filtrert gjennom funksjonen kortStokkTilStreng, resultat kommer i rett linje, med komma i mellom. Komma på sluttet på siste 
resultat blir fjernet.
#>
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"
# Skriv ut resultatet Poengsum etter at den har hvert filtrert gjennom funksjonen sumPoengKortstokk
Write-Output "Poengsum: $(sumPoengKortstokk -kortstokk $kortstokk)"

#Plukk 2 første kortene i kortstokk resultat, tell kortstokk på nytt.
$meg = $kortstokk[0..1]
$kortstokk = $kortstokk[2..$kortstokk.Count]
# Plukk 2 første kortene i kortstokk resultat som ble igjen, tell kortstokk på nytt.
$magnus = $kortstokk[0..1]
$kortstokk = $kortstokk[2..$kortstokk.Count]

#Skriv ut resultat på kort som er igjen i kortstokk
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"

#Funksjon skrivUtResultat: Skriver ut resultat meg og Magnus + vinner.
function skrivUtResultat {
    param (
        [string]
        $vinner,        
        [object[]]
        $kortStokkMagnus,
        [object[]]
        $kortStokkMeg        
    )
    Write-Output "Vinner: $vinner"
    Write-Output "magnus | $(sumPoengKortstokk -kortstokk $kortStokkMagnus) | $(kortstokkTilStreng -kortstokk $kortStokkMagnus)"    
    Write-Output "meg    | $(sumPoengKortstokk -kortstokk $kortStokkMeg) | $(kortstokkTilStreng -kortstokk $kortStokkMeg)"
}

# Blackjack er resultat score = 21
$blackjack = 21

#Sammenligner poeng resultat og velger vinner
if (((sumPoengKortstokk -kortstokk $meg) -eq $blackjack) -and ((sumPoengKortstokk -kortstokk $magnus) -eq $blackjack)) {
    skrivUtResultat -vinner "draw" -kortStokkMagnus $magnus -kortStokkMeg $meg
}
elseif ((sumPoengKortstokk -kortstokk $meg) -eq $blackjack) {
    skrivUtResultat -vinner "meg" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}
elseif ((sumPoengKortstokk -kortstokk $magnus) -eq $blackjack) {
    skrivUtResultat -vinner "magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}

while ((sumPoengKortstokk -kortstokk $meg) -lt 17) {
   $meg += $kortstokk[0]
   $kortstokk = $kortstokk[1..$kortstokk.Count]
}

if ((sumPoengKortstokk -kortstokk $meg) -gt $blackjack) {
   skrivUtResultat -vinner "magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
   exit
}

while ((sumPoengKortstokk -kortstokk $magnus) -le (sumPoengKortstokk -kortstokk $meg)) {
   $magnus += $kortstokk[0]
   $kortstokk = $kortstokk[1..$kortstokk.Count]
}

#Magnus taper hvis poengsum er høyere enn 21
if ((sumPoengKortstokk -kortstokk $magnus) -gt $blackjack) {
   skrivUtResultat -vinner "meg" -kortStokkMagnus $magnus -kortStokkMeg $meg
   exit
}

#Slutt resultat Vinner
skrivUtResultat -vinner "magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg

