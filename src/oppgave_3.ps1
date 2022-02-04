#Løsning med Komma

#$Url = "http://nav-deckofcards.herokuapp.com/shuffle"

#$response = Invoke-WebRequest -Uri $Url

#$cards = $response.Content | ConvertFrom-Json

#$kortstokk = @()
#foreach ($card in $cards) {
#    $kortstokk += ($card.suit[0] + $card.value)
#}

#$kortstokk2 = $kortstokk -join ','

#Write-Host "Kortstokk: $kortstokk2" 

#########################################

#Løsning uten Komma

#i. Leser kortstokk fra url: http://nav-deckofcards.herokuapp.com/shuffle
$Url = "http://nav-deckofcards.herokuapp.com/shuffle"

$response = Invoke-WebRequest -Uri $Url

#ii. konverterer fra json-streng til intern datatype
$cards = $response.Content | ConvertFrom-Json

#iii. Skriv ut kortstokken på formen S3,H5,D10,C4,... (med første bokstav av typen + verdien)=Se #tekst over for komma løsning
$kortstokk = @()
foreach ($card in $cards) {
    $kortstokk += ($card.suit[0] + $card.value)
}

Write-Host "Kortstokk: $kortstokk" 


