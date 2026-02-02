$base = "C:\Users\major\momi-chronicles\art"
$chars = "$base\generated\characters"
$ref = "$base\reference"

# Create per-character reference directories
New-Item "$ref\momi" -ItemType Directory -Force | Out-Null
New-Item "$ref\cinnamon" -ItemType Directory -Force | Out-Null
New-Item "$ref\philo" -ItemType Directory -Force | Out-Null

# Copy picked sprites as references (idle + walk are best for style consistency)
# Momi references
Copy-Item "$chars\momi_idle.png" "$ref\momi\momi_idle.png" -Force
Copy-Item "$chars\momi_walk.png" "$ref\momi\momi_walk.png" -Force
Copy-Item "$chars\momi_happy.png" "$ref\momi\momi_happy.png" -Force

# Cinnamon references
Copy-Item "$chars\cinnamon_idle.png" "$ref\cinnamon\cinnamon_idle.png" -Force
Copy-Item "$chars\cinnamon_walk.png" "$ref\cinnamon\cinnamon_walk.png" -Force
Copy-Item "$chars\cinnamon_happy.png" "$ref\cinnamon\cinnamon_happy.png" -Force

# Philo references
Copy-Item "$chars\philo_idle.png" "$ref\philo\philo_idle.png" -Force
Copy-Item "$chars\philo_walk.png" "$ref\philo\philo_walk.png" -Force
Copy-Item "$chars\philo_happy.png" "$ref\philo\philo_happy.png" -Force

Write-Host "Done! Set up 9 reference images in art/reference/"
Get-ChildItem "$ref" -Recurse -File | Select-Object FullName
