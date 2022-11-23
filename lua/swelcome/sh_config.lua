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

-- camera paths in menu background
sWelcome.Cinimatic = {
    [1] = {
        ['Time'] = 0.1,
        ['StartPos'] = Vector( 5, -4400, 339 ),
        ['EndPos'] = Vector( 5, -780, 339 ),

        ['StartAngle'] = Angle( 0, 90, 0 ),
        ['EndAngle'] = Angle( 0, 90, 0 )
    },
    [2] = {
        ['Time'] = 0.1,
        ['StartPos'] = Vector( 2690, 5630, 1065 ),
        ['EndPos'] = Vector( -3388, 3780, 36 ),

        ['StartAngle'] = Angle( 9, -163, 0 ),
        ['EndAngle'] = Angle( 9, -163, 0 )
    }
}