-- Initialize networks
util.AddNetworkString( "sWelcome:Player:OpenMenu" )
util.AddNetworkString( "sWelcome:Player:Register" )

function sWelcome.SendErr( pPlayer, strMessage, boolClose, boolNpc )
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
for i = 1, #sWelcome.BlacklistedNames do
    sWelcome.BlacklistedNames[ i ] = string.lower( sWelcome.BlacklistedNames[ i ] )
end

hook.Add( "CanChangeRPName", "sWelcome:Player:BlacklistedNames", function( ply, name )
    local strLowerName = string.lower( name )

    for i = 1, #sWelcome.BlacklistedNames do
        if string.find( strLowerName, sWelcome.BlacklistedNames[ i ] ) then
            return false, sWelcome:Translate( 'NotAllowed' )
        end
    end
end )

-- Player open menu
if !sql.TableExists( "swelcome" ) then
	sql.Query( "CREATE TABLE IF NOT EXISTS swelcome ( player TEXT NOT NULL PRIMARY KEY, registered INTEGER );" )
end

net.Receive( "sWelcome:Player:OpenMenu", function( _, pPlayer )
    if pPlayer.Welcomed then return end

    pPlayer.Welcomed = true

	local sqlQuery = sql.QueryValue( "SELECT registered FROM swelcome WHERE player = " .. SQLStr( pPlayer:SteamID() ) .. " LIMIT 1" )
    pPlayer.Registered = tobool( sqlQuery )

    net.Start( "sWelcome:Player:OpenMenu" )
    net.WriteBool( !pPlayer.Registered )
    net.Send( pPlayer )
end )

-- Player register
net.Receive( "sWelcome:Player:Register", function( _, pPlayer )
    if sWelcome.NetCooldown and sWelcome.NetCooldown > CurTime() then return end

    sWelcome.NetCooldown = CurTime() + 1

    local strName = net.ReadString()
    local strSurname = net.ReadString()
    local entNpc = net.ReadEntity()
    entNpc = IsValid( entNpc ) and entNpc or nil

    if entNpc then
        if entNpc:GetPos():DistToSqr(pPlayer:GetPos()) > 22500 or entNpc:GetClass() != "swelcome_name_changer" or ( pPlayer.NameCooldown and pPlayer.NameCooldown > CurTime() ) then return end
    else
        if pPlayer.Registered then return end
    end

    local strFullName = strName .. " " .. strSurname
    strFullName = string.match( strFullName, "^%s*(.*%S)" )

    if !strFullName || string.len( strFullName ) < 7 then return end

    local boolAlreayTaken = false 
    DarkRP.retrieveRPNames( strFullName, function( bool )
        boolAlreayTaken = bool
    end )

    if boolAlreayTaken then
        sWelcome.SendErr( pPlayer, 'AlreadyTaken', false )
        return
    end

    local canChangeName, reason = hook.Run( "CanChangeRPName", pPlayer, strFullName )
    if canChangeName == false then
        sWelcome.SendErr( pPlayer, reason != "" and reason or DarkRP.getPhrase( "unable", "RPname", "" ), false )
        return
    end
    
    if entNpc then
        if !pPlayer:canAfford( sWelcome.NameChangeCost ) then
            sWelcome.SendErr( pPlayer, 'NotEnoughMoney', false )
            return
        end

        pPlayer.NameCooldown = CurTime() + sWelcome.CooldownNPC
        
        pPlayer:addMoney( sWelcome.NameChangeCost * -1 )

        DarkRP.notify( pPlayer, 0, 4, sWelcome:Translate( 'NameChanged' ):format( DarkRP.formatMoney( sWelcome.NameChangeCost ) ) )
    else
	    sql.Query( "REPLACE INTO swelcome ( player, registered ) VALUES ( " .. SQLStr( pPlayer:SteamID() ) .. ", 1 )" )

        pPlayer.Registered = true
    end

    pPlayer:setRPName( strFullName )

    sWelcome.SendErr( pPlayer, "", true, IsValid( entNpc ) )
end )

hook.Add( "SetupPlayerVisibility", "sWelcome:Player:Cinematics", function( ply, viewEntity )
    for i = 1, #sWelcome.Cinematics do
        AddOriginToPVS( sWelcome.Cinematics[ i ]['StartPos'] )
    end
end )