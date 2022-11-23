-- Initialize networks
util.AddNetworkString( "sWelcome:Player:OpenMenu" )
util.AddNetworkString( "sWelcome:Player:Register" )

function sWelcome:SendErr( pPlayer, strMessage, boolClose, boolNpc )
    net.Start( "sWelcome:Player:Register" )
    net.WriteString( strMessage )
    net.WriteBool( boolClose )
    net.WriteBool( boolNpc )
    net.Send( pPlayer )
end

-- Restricted name
if sWelcome.RestrictedName then
	timer.Simple(0, function()
		DarkRP.removeChatCommand( "rpname" )
		DarkRP.removeChatCommand( "name" )
		DarkRP.removeChatCommand( "nick" )
	end )
end

-- Blacklisted names
hook.Add( "CanChangeRPName", "sWelcome:Player:BlacklistedNames", function( ply, name )
    local strLowerName = string.lower( name )

    for i = 1, #sWelcome.BlacklistedNames do
        if string.find( strLowerName, string.lower( sWelcome.BlacklistedNames[i] ) ) then
            return false, sWelcome:Translate( 'NotAllowed' )
        end
    end
end )

-- Player open menu
net.Receive( "sWelcome:Player:OpenMenu", function( _, pPlayer )
    if pPlayer.Welcomed then return end

    pPlayer.Welcomed = true

    -- idk why a ternary operation doesn't work
    local boolFirstSpawn = true  
    if pPlayer:GetPData( "swelcome_spawn" ) == "1" then
        boolFirstSpawn = false
    end

    net.Start( "sWelcome:Player:OpenMenu" )
    net.WriteBool( boolFirstSpawn )
    net.Send( pPlayer )
end )

-- Player register
net.Receive( "sWelcome:Player:Register", function( _, pPlayer )
    local strName = net.ReadString()
    local strSurname = net.ReadString()
    local entNpc = net.ReadEntity()
    entNpc = IsValid( entNpc ) and entNpc or nil

    if entNpc then
        if entNpc:GetPos():DistToSqr(pPlayer:GetPos()) > 22500 or entNpc:GetClass() != "swelcome_name_changer" or ( pPlayer.NameCooldown and pPlayer.NameCooldown > CurTime() ) then return end
    else
        if pPlayer:GetPData( "swelcome_spawn" ) == "1" then return end
    end

    local strFullName = strName .. " " .. strSurname
    strFullName = string.match( strFullName, "^%s*(.*%S)" )

    if !strFullName || string.len( strFullName ) < 7 then return end

    local boolAlreayTaken = false 
    DarkRP.retrieveRPNames( strFullName, function( bool )
        boolAlreayTaken = bool
    end )

    if boolAlreayTaken then
        sWelcome:SendErr( pPlayer, sWelcome:Translate( 'AlreadyTaken' ), false )
        return
    end

    local canChangeName, reason = hook.Call( "CanChangeRPName", GAMEMODE, pPlayer, strFullName )
    if canChangeName == false then
        sWelcome:SendErr( pPlayer, reason != "" and reason or DarkRP.getPhrase( "unable", "RPname", "" ), false )
        return
    end
    
    if entNpc then
        if !pPlayer:canAfford( sWelcome.NameChangeCost ) then
            sWelcome:SendErr( pPlayer, sWelcome:Translate( 'NotEnoughMoney' ), false )
            return
        end
        
        pPlayer:addMoney( sWelcome.NameChangeCost * -1 )

        DarkRP.notify( pPlayer, 0, 4, sWelcome:Translate( 'NameChanged' ):format( DarkRP.formatMoney( sWelcome.NameChangeCost ) ) )
    else
        pPlayer:SetPData( "swelcome_spawn", 1 )
    end

    pPlayer:setRPName( strFullName )

    sWelcome:SendErr( pPlayer, "", true, IsValid( entNpc ) )
end )