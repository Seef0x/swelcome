local function ForceName( ply, arg )
    local target = DarkRP.findPlayer( arg )

    if !target then
        DarkRP.notify( ply, 1, 4, DarkRP.getPhrase( "could_not_find", tostring( arg ) ) )
        return
    end

    sql.Query( "DELETE FROM swelcome WHERE player = " .. SQLStr( target:SteamID() ) )
    target.Registered = false

    net.Start( "sWelcome:Player:OpenNPC" )
    net.WriteEntity( target )
    net.Send( target )
end
DarkRP.definePrivilegedChatCommand( "forcename", "SWelcome_ForceName", ForceName )

local function NameHistory( ply, arg )
    local target = DarkRP.findPlayer( arg )

    if !target then
        DarkRP.notify( ply, 1, 4, DarkRP.getPhrase( "could_not_find", tostring( arg ) ) )
        return
    end

    local sqlQuery = sql.QueryValue( "SELECT history FROM swelcome_history WHERE player = " .. SQLStr( target:SteamID() ) .. " LIMIT 1" )

    if !sqlQuery then
        ply:ChatPrint( "No history" )
        return
    end

    ply:ChatPrint( "Name history of " .. target:Nick() )

    for _, v in ipairs( util.JSONToTable( sqlQuery ) ) do
        ply:ChatPrint( v.name .. " - " .. v.timestamp )
    end
end
DarkRP.definePrivilegedChatCommand( "namehistory", "SWelcome_NameHistory", NameHistory )