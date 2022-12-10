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

-- Global notification
if !sWelcome.GlobalNotification then
    local strPhrase = DarkRP.getPhrase( "rpname_changed", "", "" )
    
    hook.Add( "onNotify", "sWelcome:Player:GlobalNotification", function( _, _, _, msg )
        if string.find( msg, strPhrase ) then
            return false
        end
    end )
end

-- Player open menu
if !sql.TableExists( "swelcome_registration" ) then
	sql.Query( "CREATE TABLE IF NOT EXISTS swelcome_registration ( player TEXT NOT NULL PRIMARY KEY, registered INTEGER );" )
end

net.Receive( "sWelcome:Player:OpenMenu", function( _, pPlayer )
    if pPlayer.Welcomed then return end

    pPlayer.Welcomed = true

	local sqlQuery = sql.QueryValue( "SELECT registered FROM swelcome_registration WHERE player = " .. SQLStr( pPlayer:SteamID() ) .. " LIMIT 1" )
    pPlayer.Registered = tobool( sqlQuery )

    net.Start( "sWelcome:Player:OpenMenu" )
    net.WriteBool( !pPlayer.Registered )
    net.Send( pPlayer )
end )

-- Player register
local strIllegalChars = DarkRP.getPhrase( "illegal_characters" )
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

    local boolIsSCP = !entNpc and sWelcome.SCP

    if !boolIsSCP and sWelcome.Caligraphy then
        strName = strName:lower():gsub( "%a", string.upper, 1 )
        strSurname = strSurname:lower():gsub( "%a", string.upper, 1 )
    end

    local strFullName = strName .. ( boolIsSCP and "" or " " ) .. strSurname
    strFullName = string.match( strFullName, "^%s*(.*%S)" )

    if !strFullName || string.len( strFullName ) < 6 then return end
    if boolIsSCP and ( !string.find( strFullName, "D%-%d%d%d%d" ) or string.len( strFullName ) > 6 ) then return end

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
        if reason == strIllegalChars and boolIsSCP then -- good chance that we can do otherwise
        else
            sWelcome.SendErr( pPlayer, reason != "" and reason or DarkRP.getPhrase( "unable", "RPname", "" ), false )
            return
        end
    end
    
    if entNpc then
        if sWelcome.NameChangeCost > 0 then
            if !pPlayer:canAfford( sWelcome.NameChangeCost ) then
                sWelcome.SendErr( pPlayer, 'NotEnoughMoney', false )
                return
            end

            pPlayer:addMoney( sWelcome.NameChangeCost * -1 )
        end

        pPlayer.NameCooldown = CurTime() + sWelcome.CooldownNPC
        
        DarkRP.notify( pPlayer, 0, 4, sWelcome:Translate( 'NameChanged' ):format( DarkRP.formatMoney( sWelcome.NameChangeCost ) ) )
    else
	    sql.Query( "REPLACE INTO swelcome_registration ( player, registered ) VALUES ( " .. SQLStr( pPlayer:SteamID() ) .. ", 1 )" )

        pPlayer.Registered = true
    end

    pPlayer:setRPName( strFullName )

    sWelcome.SendErr( pPlayer, "", true, entNpc != pPlayer )
end )

-- PVS
hook.Add( "SetupPlayerVisibility", "sWelcome:Player:Cinematics", function( ply, viewEntity )
    for i = 1, #sWelcome.Cinematics do
        AddOriginToPVS( sWelcome.Cinematics[ i ]['StartPos'] )
    end
end )

-- NPCs
function sWelcome.SaveNPCs( ply )
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end

    local tblNpcs = {}

    for _, v in ipairs( ents.FindByClass( "swelcome_name_changer" ) ) do
        table.insert( tblNpcs, { pos = v:GetPos(), ang = v:GetAngles(), map = game.GetMap() } )
    end

    file.Write( "swelcome_npcs.json", util.TableToJSON( tblNpcs ) )

    sWelcome.LoadNPCs() -- respawn npcs as world entity
end
concommand.Add("swelcome_save_npcs", sWelcome.SaveNPCs)

function sWelcome.LoadNPCs( ply )
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end

    for _, v in ipairs( ents.FindByClass( "swelcome_name_changer" ) ) do
        v:Remove()
    end

    local tblNpcs = util.JSONToTable( file.Read( "swelcome_npcs.json" ) )

    for _, v in ipairs( tblNpcs ) do
        if v.map != game.GetMap() then continue end

        local ent = ents.Create( "swelcome_name_changer" )
        ent:SetPos( v.pos )
        ent:SetAngles( v.ang )
        ent:Spawn()
        ent:Activate()
    end
end
hook.Add("InitPostEntity", "sWelcome:LoadNPCs", sWelcome.LoadNPCs)
hook.Add("PostCleanupMap", "sWelcome:LoadNPCs", sWelcome.LoadNPCs)
concommand.Add("swelcome_spawn_npcs", sWelcome.LoadNPCs)

-- NAME HISTORY
if !sql.TableExists( "swelcome_history" ) then
	sql.Query( "CREATE TABLE IF NOT EXISTS swelcome_history ( player TEXT NOT NULL PRIMARY KEY, history TEXT );" )
end

hook.Add( "DarkRPVarChanged", "sWelcome:NameHistory", function( pPlayer, var, _, new )
    if var != "rpname" then return end

    local sqlQuery = sql.QueryValue( "SELECT history FROM swelcome_history WHERE player = " .. SQLStr( pPlayer:SteamID() ) .. " LIMIT 1" )
    local tblHistory = sqlQuery and util.JSONToTable( sqlQuery ) or {}

    table.insert( tblHistory, { name = new, timestamp = os.date() })

    sql.Query( "REPLACE INTO swelcome_history ( player, history ) VALUES ( " .. SQLStr( pPlayer:SteamID() ) .. ", " .. SQLStr( util.TableToJSON( tblHistory ) ) .. " )" )
end )