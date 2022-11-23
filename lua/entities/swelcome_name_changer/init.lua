util.AddNetworkString( "sWelcome:Player:OpenNPC" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/Barney.mdl" )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetNPCState( NPC_STATE_SCRIPT )
    self:SetSolid( SOLID_BBOX )
    self:SetUseType( SIMPLE_USE )
    self:CapabilitiesAdd( CAP_ANIMATEDFACE, CAP_TURN_HEAD )
    self:SetMaxYawSpeed( 90 )
    self:DropToFloor()
end

function ENT:AcceptInput( name, activator, ply )
    if name != "Use" or !IsValid( ply ) or !ply:IsPlayer() then return end

    local curTime = CurTime()

    if ply.NameCooldown and ply.NameCooldown > curTime then
        DarkRP.notify( ply, 1, 5, sWelcome:Translate( "NameCooldown" ):format( math.ceil( ply.NameCooldown - curTime ) ) )
        return
    end

    net.Start( "sWelcome:Player:OpenNPC" )
    net.WriteEntity( self )
    net.Send( ply )
end

function ENT:SpawnFunction( ply, tr, class )
    if !tr.Hit then return end

    local spawnAng = ply:EyeAngles()
    spawnAng.p = 0
    spawnAng.y = spawnAng.y + 180

    local ent = ents.Create( class )
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
    ent:SetAngles( spawnAng )
    ent:Spawn()
    ent:Activate()

    return ent
end