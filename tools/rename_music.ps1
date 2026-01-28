$musicDir = "C:\Users\major\momi-chronicles\assets\audio\music"

$renames = @{
    "momichronicles2-Untitled-00427b83-102a-41b1-98a0-387e609b1f30.wav" = "neighborhood_morning_a.wav"
    "momichronicles2-Untitled-afbab2c9-59d2-4f45-961c-4147c6eb5fa2.wav" = "neighborhood_morning_b.wav"
    "momichronicles2-Untitled-73b31001-d04f-44b0-aedb-8f5882af5cca.wav" = "neighborhood_evening_a.wav"
    "momichronicles2-Untitled-7d253483-8fb5-4b04-bb0b-15eed1c89b45.wav" = "neighborhood_evening_b.wav"
    "momichronicles2-Untitled-58fd4781-48db-499b-959c-0fe033c40644.wav" = "neighborhood_night_a.wav"
    "momichronicles2-Untitled-f9c79ef7-bf9e-4617-95c4-7a54531d1cb9.wav" = "neighborhood_night_b.wav"
    "momichronicles2-Untitled-9a3a243d-d1b1-40d1-9abe-2932981c9087.wav" = "backyard_deep_a.wav"
    "momichronicles2-Untitled-f9260735-a56e-4dae-b08c-90720a3d2f0f.wav" = "backyard_deep_b.wav"
    "momichronicles2-Untitled-5968bd2a-68bb-450c-87fb-c650e374674c.wav" = "backyard_shed_a.wav"
    "momichronicles2-Untitled-ef4df400-c597-486c-9aba-668906148cb1.wav" = "backyard_shed_b.wav"
    "momichronicles2-Untitled-cba616cf-c7ad-43b1-a0ea-182799a2aaf7.wav" = "crow_theme_a.wav"
    "momichronicles2-Untitled-d0aaafca-b202-4d00-88de-80a19d26325f.wav" = "crow_theme_b.wav"
    "momichronicles2-Untitled-42a5defa-24f9-4635-8edc-2051e06302dd.wav" = "first_encounter_a.wav"
    "momichronicles2-Untitled-a991f891-4c08-4b41-9384-ea127ee93987.wav" = "first_encounter_b.wav"
    "momichronicles2-Untitled-64b92ad0-3474-4394-9260-da192b1dc849.wav" = "surrounded_a.wav"
    "momichronicles2-Untitled-8f734aec-82cd-4731-b306-dd440cc4c999.wav" = "surrounded_b.wav"
    "momichronicles2-Untitled-8cf647b7-ecd0-420c-9d7d-5759ac933fcb.wav" = "winning_a.wav"
    "momichronicles2-Untitled-dc701c0b-e7c9-4a2c-b71c-c7d2c7331832.wav" = "winning_b.wav"
    "momichronicles2-Untitled-224a1f62-fe3e-4bd7-a13b-444d78f38786.wav" = "low_health_a.wav"
    "momichronicles2-Untitled-e6f93177-202b-4f33-aee3-535b4d51607e.wav" = "low_health_b.wav"
    "momichronicles2-Untitled-bc8fb440-78ae-45ab-b261-4f2aa878937a.wav" = "boss_fight_a.wav"
    "momichronicles2-Untitled-d83a3556-082b-4b83-87f5-1ba53b0bddba.wav" = "boss_fight_b.wav"
}

foreach ($old in $renames.Keys) {
    $oldPath = Join-Path $musicDir $old
    $newPath = Join-Path $musicDir $renames[$old]
    if (Test-Path $oldPath) {
        Rename-Item -Path $oldPath -NewName $renames[$old] -Force
        Write-Host "Renamed: $old -> $($renames[$old])"
    } else {
        Write-Host "Not found: $old"
    }
}

Write-Host "Done renaming music files!"
