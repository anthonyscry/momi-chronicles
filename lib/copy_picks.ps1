$base = "C:\Users\major\momi-chronicles\art\generated"
New-Item "$base\characters" -ItemType Directory -Force | Out-Null
New-Item "$base\enemies" -ItemType Directory -Force | Out-Null

Copy-Item "$base\batch_1\characters\momi_idle.png" "$base\characters\momi_idle.png" -Force
Copy-Item "$base\batch_1\characters\momi_walk.png" "$base\characters\momi_walk.png" -Force
Copy-Item "$base\batch_4\characters\momi_run.png" "$base\characters\momi_run.png" -Force
Copy-Item "$base\batch_2\characters\momi_chomp.png" "$base\characters\momi_chomp.png" -Force
Copy-Item "$base\batch_2\characters\momi_bark.png" "$base\characters\momi_bark.png" -Force
Copy-Item "$base\batch_1\characters\momi_dig.png" "$base\characters\momi_dig.png" -Force
Copy-Item "$base\batch_3\characters\momi_hurt.png" "$base\characters\momi_hurt.png" -Force
Copy-Item "$base\batch_4\characters\momi_death.png" "$base\characters\momi_death.png" -Force
Copy-Item "$base\batch_2\characters\momi_happy.png" "$base\characters\momi_happy.png" -Force
Copy-Item "$base\batch_3\characters\cinnamon_idle.png" "$base\characters\cinnamon_idle.png" -Force
Copy-Item "$base\batch_3\characters\cinnamon_walk.png" "$base\characters\cinnamon_walk.png" -Force
Copy-Item "$base\batch_3\characters\cinnamon_overheat.png" "$base\characters\cinnamon_overheat.png" -Force
Copy-Item "$base\batch_1\characters\cinnamon_slam.png" "$base\characters\cinnamon_slam.png" -Force
Copy-Item "$base\batch_4\characters\cinnamon_hurt.png" "$base\characters\cinnamon_hurt.png" -Force
Copy-Item "$base\batch_3\characters\cinnamon_death.png" "$base\characters\cinnamon_death.png" -Force
Copy-Item "$base\batch_2\characters\cinnamon_happy.png" "$base\characters\cinnamon_happy.png" -Force
Copy-Item "$base\batch_2\characters\philo_idle.png" "$base\characters\philo_idle.png" -Force
Copy-Item "$base\batch_4\characters\philo_walk.png" "$base\characters\philo_walk.png" -Force
Copy-Item "$base\batch_1\characters\philo_motivated_run.png" "$base\characters\philo_motivated_run.png" -Force
Copy-Item "$base\batch_3\characters\philo_bark.png" "$base\characters\philo_bark.png" -Force
Copy-Item "$base\batch_4\characters\philo_jealous.png" "$base\characters\philo_jealous.png" -Force
Copy-Item "$base\batch_1\characters\philo_hurt.png" "$base\characters\philo_hurt.png" -Force
Copy-Item "$base\batch_2\characters\philo_death.png" "$base\characters\philo_death.png" -Force
Copy-Item "$base\batch_1\characters\philo_happy.png" "$base\characters\philo_happy.png" -Force
Copy-Item "$base\batch_1\enemies\roomba_idle.png" "$base\enemies\roomba_idle.png" -Force
Copy-Item "$base\batch_3\enemies\roomba_attack.png" "$base\enemies\roomba_attack.png" -Force
Copy-Item "$base\batch_2\enemies\gnome_idle.png" "$base\enemies\gnome_idle.png" -Force
Copy-Item "$base\batch_1\enemies\gnome_attack.png" "$base\enemies\gnome_attack.png" -Force
Copy-Item "$base\batch_4\enemies\goose_idle.png" "$base\enemies\goose_idle.png" -Force
Copy-Item "$base\batch_2\enemies\goose_attack.png" "$base\enemies\goose_attack.png" -Force
Copy-Item "$base\batch_3\enemies\squirrel_idle.png" "$base\enemies\squirrel_idle.png" -Force
Copy-Item "$base\batch_2\enemies\squirrel_attack.png" "$base\enemies\squirrel_attack.png" -Force

Write-Host "Done! Copied 32 sprites to final folders"
