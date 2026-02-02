$base = "C:\Users\major\momi-chronicles\art\generated"

foreach ($i in 1..4) {
    $dir = "$base\batch_$i\characters"
    if (Test-Path $dir) {
        $count = (Get-ChildItem "$dir\*.png" -ErrorAction SilentlyContinue).Count
        Remove-Item "$dir\*.png" -Force -ErrorAction SilentlyContinue
        Write-Host "Cleared batch_$i/characters/ ($count files)"
    } else {
        Write-Host "batch_$i/characters/ does not exist, skipping"
    }
}

Write-Host "Done! Old character batches cleared for regeneration"
