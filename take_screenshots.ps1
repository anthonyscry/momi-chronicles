# Screenshot script for Momi's Adventure

# Start Godot game
$game = Start-Process -FilePath 'godot' -ArgumentList '--path', 'C:/Users/major/momi-chronicles', '--scene', 'res://world/zones/neighborhood.tscn' -PassThru

# Wait for game to load
Start-Sleep -Seconds 5

# Load assemblies for screenshots
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Take-Screenshot {
    param([string]$Path)
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $bitmap.Save($Path)
    $graphics.Dispose()
    $bitmap.Dispose()
    Write-Host "Saved: $Path"
}

# Take screenshots at intervals
Take-Screenshot -Path 'C:/Users/major/momi-chronicles/screenshots/gameplay_01.png'

Start-Sleep -Seconds 8
Take-Screenshot -Path 'C:/Users/major/momi-chronicles/screenshots/gameplay_02.png'

Start-Sleep -Seconds 8
Take-Screenshot -Path 'C:/Users/major/momi-chronicles/screenshots/gameplay_03.png'

Start-Sleep -Seconds 8
Take-Screenshot -Path 'C:/Users/major/momi-chronicles/screenshots/gameplay_04.png'

Start-Sleep -Seconds 8
Take-Screenshot -Path 'C:/Users/major/momi-chronicles/screenshots/gameplay_05.png'

# Close the game
Stop-Process -Id $game.Id -Force -ErrorAction SilentlyContinue
Write-Host "Done! Screenshots saved to C:/Users/major/momi-chronicles/screenshots/"
