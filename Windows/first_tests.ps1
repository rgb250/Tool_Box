# Create My first function


function Get-HungerFactorLinear {
    param(
        $HungerFactor
    )
    Write-Output 2 * (0.5 - $HungerFactor)
}


function Get-DeltaLinear {
    param (
        $BasePricePerc
        $BasePriceInd
        $HungerFactor
    )
    Write-Output $BasePricePerc * $BasePricePerc * $BasePriceInd * Get-HungerFactorLinear -ParameterName $HungerFactor
}


function Get-DeltaLinear {
    param (
        $BasePricePerc
        $BasePriceInd
        $HungerFactor
    )
    Write-Output $BasePricePerc * $BasePricePerc * $BasePriceInd *  2 * (0.5 - $HungerFactor)
}


function Get-DeltaLinear ([float]$BasePricePerc, [float]$BasePriceInd, [float]$HungerFactor) {
    $result =  $BasePricePerc * $BasePricePerc * $BasePriceInd *  2 * (0.5 - $HungerFactor)
    Write-Output $result
}