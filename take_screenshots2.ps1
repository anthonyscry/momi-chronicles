# Screenshot script for Momi's Adventure - Run 2

# Start Godot game
$game = Start-Process -FilePath 'godot' -ArgumentList '--path', 'C:/Users/major/momi-chronicles', '--scene', 'res://world/zones/neighborhood.tscn' -PassThru

# Wait for game to load
Start-Sleep -Seconds 4

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

# Take more frequent screenshots for action shots
for ($i = 1; $i -le 10; $i++) {
    Take-Screenshot -Path "C:/Users/major/momi-chronicles/screenshots/action_$('{0:D2}' -f $i).png"
    Start-Sleep -Seconds 5
}

# Close the game
Stop-Process -Id $game.Id -Force -ErrorAction SilentlyContinue
Write-Host "Done! Screenshots saved."
