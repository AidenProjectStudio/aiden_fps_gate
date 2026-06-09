Config = {}

-- Limite FPS autorisee.
Config.MaxFPS = 120

-- Tolerance pour eviter les faux positifs.
Config.Tolerance = 3

-- Verification toutes les X ms.
Config.SampleMs = 1000

-- Nombre de frames lues a chaque verification.
-- 5 = tres leger, 10 = plus lisse.
Config.SampleFrames = 5

-- Temps au-dessus de la limite avant blocage.
Config.BlockAfterMs = 3000

-- Temps sous la limite avant deblocage.
Config.UnlockAfterMs = 3000

Config.MessageTitle = "FPS TROP ELEVES"
Config.MessageSubtitle = "Limite tes FPS pour continuer a jouer."
