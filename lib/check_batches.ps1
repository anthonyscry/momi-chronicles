$base = "C:\Users\major\momi-chronicles\art\generated"
foreach ($i in 1..4) {
    $dir = "$base\batch_$i\characters"
    $count = (Get-ChildItem "$dir\*.png" -ErrorAction SilentlyContinue).Count
    Write-Host "batch_$i/characters/: $count files"
}
