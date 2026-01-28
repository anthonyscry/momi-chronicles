Add-Type -AssemblyName System.Windows.Forms,System.Drawing
$outputPath = "C:\Users\major\momi-chronicles\screenshot.png"
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
$bmp.Save($outputPath)
Write-Host "Screenshot saved to $outputPath"
