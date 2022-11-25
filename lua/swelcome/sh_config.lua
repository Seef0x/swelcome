--[[  
    Addon: SWelcome
    By: Seefox
    Buyer: 
    Support: Gmodstore ticket
--]]

-- available languages: fr,en,es
sWelcome.Language = "en"

-- you can put a material to have a nicer text
-- an .ai file is included in the addon but requires a minimum of knowledge to be used
sWelcome.ServerName = "SERVERNAME"

sWelcome.ServerNameColor = Color(165, 115, 255)

sWelcome.ServerLogo = Material("seefox/swelcome/logo.png") -- false to disable

sWelcome.DiscordLink = "https://www.google.com/" -- blank to disable

sWelcome.Music = "seefox/swelcome/music.mp3" -- blank to disable

sWelcome.BlacklistedNames = {
    'nigga',
    'penis',
    'owner',
    'founder' -- no comma for last
}

sWelcome.NameChangeCost = 0

sWelcome.RestrictedName = false -- renaming should only be possible from the NPC?

sWelcome.CooldownNPC = 300 -- seconds of cooldown between 2 name changes

sWelcome.ModelNPC = "models/barney.mdl"

-- camera paths in menu background
sWelcome.Cinematics = {
    [1] = {
        ['Time'] = 0.1,
        ['StartPos'] = Vector( -6729, -6192, 307 ),
        ['EndPos'] = Vector( -6715, 654, 172 ),

        ['StartAngle'] = Angle( 0, 90, 0 ),
        ['EndAngle'] = Angle( 0, 90, 0 )
    },
    [2] = {
        ['Time'] = 0.1,
        ['StartPos'] = Vector( -290, 777, 977 ),
        ['EndPos'] = Vector( -2875, 8708, 924 ),

        ['StartAngle'] = Angle( 0, 90, 0 ),
        ['EndAngle'] = Angle( 0, 0, 0 )
    }
}