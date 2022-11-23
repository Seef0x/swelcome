include( "shared.lua" )

local colWhite = Color( 255, 255, 255 )
local colBackground = Color(0, 0, 0, 240)
local matStar = Material( "seefox/swelcome/star.png" )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawTranslucent()
    self:DrawModel()

    local pPlayer = LocalPlayer()
    local vecPosNpc = self:GetPos()

    if pPlayer:GetPos():DistToSqr( vecPosNpc ) > 160000 then return end

    surface.SetFont( "Trebuchet24" )
    local strText = sWelcome:Translate( "ChangeName" )
    local intSize = select( 1, surface.GetTextSize( strText ) ) + 27 + 18

    local angle = self:GetAngles()

    angle:RotateAroundAxis( angle:Forward(), 0 )
    angle:RotateAroundAxis( angle:Right(), 0 )
    angle:RotateAroundAxis( angle:Up(), 90 )
    
    cam.Start3D2D( vecPosNpc + Vector( 0, 0, select( 2, self:GetModelBounds() ).z + 2 ) + angle:Up() * ( math.sin( CurTime() * 3 ) * 2 + 5 ), Angle( 0, pPlayer:EyeAngles().y - 90, 90 ), 0.15 )
        draw.RoundedBox( 0, -intSize / 2 - 8, 0, intSize, 28, colBackground )
        surface.SetDrawColor( colWhite )
        surface.SetMaterial( matStar )
        surface.DrawTexturedRect( -intSize / 2 - 6, 0, 27, 27, 0 )
        draw.SimpleText( strText, "Trebuchet24", 6, 1, colWhite, 1 )
    cam.End3D2D()
end