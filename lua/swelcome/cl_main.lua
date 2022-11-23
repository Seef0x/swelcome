sWelcome.LastError = sWelcome.LastError or ""
sWelcome.IsOpen = sWelcome.IsOpen or false

local intCinimaticIndex = 1
local intCinimaticLastIndex = 0
local boolStartedAng = false
local vecPosCinimatic = sWelcome.Cinimatic[ intCinimaticIndex ]['StartPos']
local angPosCinimatic = sWelcome.Cinimatic[ intCinimaticIndex ]['StartAngle']

-- Sizes
local scrW = ScrW()
local scrH = ScrH()

local function scaleThis( int )
    if scrH > 720 then return int end
	return math.ceil( int / 1080 * scrH )
end

local size100 = scaleThis( 100 )
local size120 = scaleThis( 120 )
local size160 = scaleThis( 160 )
local size180 = scaleThis( 180 )
local size200 = scaleThis( 200 )
local size230 = scaleThis( 230 )
local size524 = scaleThis( 524 )

-- Colors
local colWhite = Color( 255, 255, 255 )
local colGrey = Color( 49, 49, 48 )
local colBlack = Color( 0, 0, 0 )
local colBlackH = Color( 0, 0, 0, 150 )
local colOrange = Color( 255, 184, 176 )
local colOrangeH = Color( 255, 184, 176, 200 )

-- Fonts
surface.CreateFont( "sWelcome:48:B_shadow", { font = "QUARTZO", extended = false, size = 105, weight = 800, blursize = 3 } )
surface.CreateFont( "sWelcome:48:B", { font = "QUARTZO", extended = false, size = 105, weight = 800, } )
surface.CreateFont( "sWelcome:32:B", { font = "QUARTZO", extended = false, size = 32, weight = 800, } )
surface.CreateFont( "sWelcome:30:B", { font = "QUARTZO", extended = false, size = 30, weight = 800, } )
surface.CreateFont( "sWelcome:24:B", { font = "QUARTZO", extended = false, size = 24, weight = 800, } )
surface.CreateFont( "sWelcome:24:A", { font = "QUARTZO", extended = false, size = 29, weight = 800, } )

-- Materials
local matBg = Material( "seefox/swelcome/background.png" )
local matStart = Material( "seefox/swelcome/start.png" )
local matNext = Material( "seefox/swelcome/continue.png" )
local matDiscord = Material( "seefox/swelcome/discord.png" )
local matBgDiscord = Material( "seefox/swelcome/bluereflect.png" )
local matCross = Material( "seefox/swelcome/cross.png" )

-- Blur
local matBlur = Material( "pp/blurscreen" )
local function drawBlur( panel, amount )
	local x, y = panel:LocalToScreen( 0, 0 )

	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor( colWhite )
	surface.SetMaterial( matBlur )

	for i = 1, 3 do
		matBlur:SetFloat( "$blur", ( i / 3 ) * ( amount or 6 ) )
		matBlur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( x * -1, y * -1, scrW, scrH )
	end
end

-- Menu
function sWelcome:Transition()
    local Base = vgui.Create( "DFrame" )
    Base:SetSize( scrW, scrH )
    Base:Center()
    Base:SetTitle('')
    Base:SetDraggable( false )
    Base:ShowCloseButton( false )
    Base:MakePopup()
    Base:SetAlpha( 0 )
    Base:AlphaTo( 255, 0.5, 0, function() 
        timer.Simple( 1, function()
            if !IsValid( Base ) then return end

            Base:AlphaTo( 0, 1, 0, function() 
                Base:Remove()
            end )            
        end )
    end )
    function Base:Paint( w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, colBlack )
    end

    timer.Simple( 8, function()
        if IsValid( Base ) then
            Base:Remove()
        end
    end )

    sWelcome.pTransition = Base
end

function sWelcome:Create( entNpc )
    local Base = vgui.Create( "DFrame" )
    Base:SetSize( scrW, scrH )
    Base:Center()
    Base:SetTitle('')
    Base:SetDraggable( false )
    Base:ShowCloseButton( false )
    Base:MakePopup()
    function Base:Paint( w, h )
        if !entNpc then
            drawBlur( self, 12 )
        end
    end
    function Base:OnRemove()
        sWelcome.LastError = ""
        sWelcome.IsOpen = false
    end

    local intMsgW = scaleThis( 681 )
    local intMsgH = scaleThis( 488 )
    local intMsgX = Base:GetWide() / 2 - intMsgW / 2 + 20
    local intMsgY = Base:GetTall() / 2 - intMsgH / 2 - 80

    local pContent = vgui.Create( "DPanel", Base )
    pContent:SetSize( Base:GetSize() )
    pContent:SetAlpha( 0 )
    pContent:SetPos( 0, scrH )
    pContent:AlphaTo( 255, 1 )
    pContent:MoveTo( 0, 0, 0.8 )
    function pContent:Paint( w, h )
        surface.SetDrawColor( colWhite )
        surface.SetMaterial( matBg )
        surface.DrawTexturedRect( intMsgX, intMsgY, intMsgW, intMsgH )

        if sWelcome.ServerLogo then
            surface.SetDrawColor( colWhite )
            surface.SetMaterial( sWelcome.ServerLogo )
            surface.DrawTexturedRect( w*.5, h*.25, size120, size120 )
        end

        draw.SimpleTextOutlined( 
            sWelcome:Translate( "NAME" ) .. ":", 
            "sWelcome:24:B", 
            intMsgX + size230, 
            intMsgY + intMsgH / 2 + 28, 
            colWhite,
            2,
            0,
            1, 
            colBlack
        )

        draw.SimpleTextOutlined( 
            sWelcome:Translate( "SURNAME" ) .. ":", 
            "sWelcome:24:B", 
            intMsgX + size200 + 10, 
            intMsgY + intMsgH / 2 + size100 + 13, 
            colWhite,
            2,
            0,
            1, 
            colBlack
        )

        if entNpc and sWelcome.NameChangeCost > 0 then
            draw.SimpleTextOutlined( 
                sWelcome:Translate( "COST" ) .. ": " .. DarkRP.formatMoney( sWelcome.NameChangeCost ), 
                "sWelcome:24:B", 
                intMsgX + size200 + scaleThis( 60 ), 
                intMsgY + intMsgH / 2 + size160 + 13, 
                colWhite,
                2,
                0,
                1, 
                colBlack
            )
        end
    end

    local btnDisconnect = vgui.Create( "DButton", pContent )
    btnDisconnect:SetText('')
    if entNpc then
        btnDisconnect:SetSize( 16, 16 )
        btnDisconnect:SetPos( Base:GetWide() * .65, Base:GetTall() * .22 )
        function btnDisconnect:Paint( w, h )
            surface.SetDrawColor( colWhite )
            surface.SetMaterial( matCross )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
        function btnDisconnect:DoClick()
            pContent:AlphaTo( 0, 0.5 )
            pContent:MoveTo( Base:GetX(), -pContent:GetTall() - size200, 0.8, 0, -1, function() 
                Base:Remove()
            end )
        end
    else
        btnDisconnect:SetSize( size160, 20 )
        btnDisconnect:SetPos( 15, 15 )
        function btnDisconnect:Paint( w, h )
            draw.SimpleTextOutlined( sWelcome:Translate( "DISCONNECT" ), "sWelcome:24:B", 1, h / 2, self:IsHovered() and colOrangeH or colOrange, 0, 1, 1, colBlack )
        end
        function btnDisconnect:DoClick()
            LocalPlayer():ConCommand( 'disconnect' )
        end
    end

    local pName = vgui.Create( "DTextEntry", pContent )
    pName:SetSize( size200, 30 )
    pName:SetPos( intMsgX + scaleThis( 250 ), intMsgY + intMsgH / 2 + 30 )
    pName:SetDrawLanguageID( false )

    local pSurname = vgui.Create( "DTextEntry", pContent )
    pSurname:SetSize( scaleThis( 220 ), 30 )
    pSurname:SetPos( intMsgX + size230, intMsgY + intMsgH / 2 + size100 + 13 )
    pSurname:SetDrawLanguageID( false )

    local superAngle = Angle(0, -5, 0)
    local btnStart = vgui.Create( "DButton", pContent )
    btnStart:SetSize( size200, size100 )
    btnStart:SetText('')
    btnStart.intW = size524
    btnStart.intH = size180
    btnStart.OnCursorEntered = function(self)
        surface.PlaySound( "seefox/swelcome/hover_little.wav" )
    end
    function btnStart:Paint( w, h )
        local isHovered = self:IsHovered()
        local frameTime = FrameTime() * 10

        if isHovered then
            self.intW = Lerp( frameTime, self.intW, size524 + 10 )
            self.intH = Lerp( frameTime, self.intH, size180 + 10 )
        else
            self.intW = Lerp( frameTime, self.intW, size524 )
            self.intH = Lerp( frameTime, self.intH, size180 )
        end

        self:SetSize( self.intW, self.intH )
        self:SetPos( intMsgX - 68, intMsgY + intMsgH - 57 )

        surface.SetDrawColor( colWhite )
        surface.SetMaterial( matStart )
        surface.DrawTexturedRect( 0, 0, w, h - 15 )

        render.PushFilterMag( TEXFILTER.ANISOTROPIC )
        render.PushFilterMin( TEXFILTER.ANISOTROPIC )

        local x, y = w * .4, ( h - 15 ) * .86
        local mx = Matrix()

        mx:Translate(Vector(x, y))
        mx:Rotate(superAngle)
        mx:Translate(Vector(-x, -y))

        cam.PushModelMatrix(mx)
            draw.SimpleTextOutlined( entNpc and string.upper( sWelcome:Translate( "ChangeName" ) ) or sWelcome:Translate( "STARTADVENTURE" ), "sWelcome:30:B", x, y, colWhite, 1, 4, 4, colGrey )
        cam.PopModelMatrix()

        render.PopFilterMag()
        render.PopFilterMin()

        if isHovered then
            surface.SetDrawColor( colBlackH )
            surface.SetMaterial( matStart )
            surface.DrawTexturedRect( 0, 0, w, h - 15 )
        end        

        if string.len( sWelcome.LastError ) > 0 then
            draw.SimpleTextOutlined( sWelcome.LastError, "sWelcome:24:B", w / 2, h, colOrange, 1, 4, 1, colBlack )
        end
    end
    function btnStart:DoClick()
        surface.PlaySound( "seefox/swelcome/btn_heavy.ogg" )

        net.Start( "sWelcome:Player:Register" )
        net.WriteString( pName:GetValue() )
        net.WriteString( pSurname:GetValue() )
        if entNpc then
            net.WriteEntity( entNpc )
        end
        net.SendToServer()
    end

    sWelcome.BaseC = Base
end

net.Receive( "sWelcome:Player:OpenMenu", function()
    local boolFirstSpawn = net.ReadBool()

    intCinimaticIndex = 1
    sWelcome.IsOpen = true

    local intMod = 0
    local intModMax = 60
    local boolDown = true
    local intNextMod = 0

    local Base = vgui.Create( "DFrame" )
    Base:SetSize( scrW, scrH )
    Base:Center()
    Base:SetTitle('')
    Base:SetDraggable( false )
    Base:ShowCloseButton( false )
    Base:MakePopup()
    function Base:Paint( w, h )
        drawBlur( self, 12 ) 
    end

    local intMsgW = 719 / ( scrW / scrH )
    local intMsgH = 237 / ( scrW / scrH )
    local intMsgX = Base:GetWide() / 2 - intMsgW / 2

    local pContent = vgui.Create( "DPanel", Base )
    pContent:SetSize( Base:GetSize() )
    pContent:SetAlpha( 0 )
    pContent:SetPos( 0, scrH )
    pContent:AlphaTo( 255, 1 )
    pContent:MoveTo( 0, 0, 0.8 )
    function pContent:Paint( w, h )
        local intMsgY = 50

        if !intNextMod || intNextMod < CurTime() then
            if boolDown then
                intMod = intMod + 1
                if intMod >= intModMax then boolDown = false end
            else
                intMod = intMod - 1

                if intMod < 1 then boolDown = true end                    
            end

            intNextMod = CurTime() + 0.02
        end

        intMsgY = intMsgY + intMod

        if type( sWelcome.ServerName ) == "IMaterial" then
            surface.SetDrawColor( colWhite )
            surface.SetMaterial( sWelcome.ServerName )
            surface.DrawTexturedRect( intMsgX, intMsgY, intMsgW, intMsgH )
        else
            draw.SimpleText( sWelcome:Translate( "WELCOMETO" ), "sWelcome:30:B", w/2, intMsgY+12, colWhite, 1 )
            
            local y = intMsgY+25
            draw.SimpleText( sWelcome.ServerName, "sWelcome:48:B_shadow", w/2, y + 4, ColorAlpha(color_black, 120), 1, TEXT_ALIGN_TOP )
            draw.SimpleText( sWelcome.ServerName, "sWelcome:48:B", w/2, y + 4, ColorAlpha(color_black, 150), 1, TEXT_ALIGN_TOP )
            draw.SimpleText( sWelcome.ServerName, "sWelcome:48:B", w/2, y, sWelcome.ServerNameColor, 1, TEXT_ALIGN_TOP )
        end
    end

    local btnDisconnect = vgui.Create( "DButton", Base )
    btnDisconnect:SetSize( size160, 20 )
    btnDisconnect:SetPos( 15, 15 )
    btnDisconnect:SetText('')
    function btnDisconnect:Paint( w, h )
        draw.SimpleTextOutlined( sWelcome:Translate( "DISCONNECT" ), "sWelcome:24:B", 1, h / 2, self:IsHovered() and colOrangeH or colOrange, 0, 1, 1, colBlack )
    end
    function btnDisconnect:DoClick()
        LocalPlayer():ConCommand( 'disconnect' )
    end

    if sWelcome.DiscordLink != "" then
        local btnDiscord = vgui.Create( "DButton", pContent )
        btnDiscord:SetSize( scaleThis( 500 ), 80 )
        btnDiscord:SetPos( scrW / 2 - btnDiscord:GetWide() / 2, scrH / 2 - btnDiscord:GetTall() / 2 )
        btnDiscord:SetText('')
        btnDiscord.intLerpLogo = 0
        btnDiscord.OnCursorEntered = function(self)
            surface.PlaySound( "seefox/swelcome/click2_little.wav" )
        end
        function btnDiscord:Paint( w, h )
            surface.SetDrawColor( colWhite )
            surface.SetMaterial( matBgDiscord )
            surface.DrawTexturedRect( 0, 0, w, h )

            local frameTime = FrameTime() * 8

            if self:IsHovered() then
                surface.SetDrawColor( colBlackH )
                surface.SetMaterial( matBgDiscord )
                surface.DrawTexturedRect( 0, 0, w, h )

                self.intLerpLogo = Lerp( frameTime, self.intLerpLogo, 360 ) 
            else
                self.intLerpLogo = Lerp( frameTime, self.intLerpLogo, 0 ) 
            end

            surface.SetDrawColor( colWhite )
            surface.SetMaterial( matDiscord )

            surface.DrawTexturedRectRotated( 40 + 32, h / 2 - 5, 64, 64, self.intLerpLogo )

            draw.SimpleTextOutlined( sWelcome:Translate( "JOINUS" ), "sWelcome:24:A", w / 2 + 30, h / 2 - 5, colWhite, 1, 1, 1, colBlack )    
        end
        function btnDiscord:DoClick()
            surface.PlaySound( "seefox/swelcome/flash.ogg" )
            notification.AddLegacy( sWelcome:Translate( "CopiedLink" ), NOTIFY_GENERIC, 4 )
            SetClipboardText( sWelcome.DiscordLink )
            gui.OpenURL( sWelcome.DiscordLink )
        end
    end

    local btnNext = vgui.Create( "DButton", pContent )
    btnNext.intW = size200
    btnNext.intH = size100
    btnNext:SetSize( btnNext.intW, btnNext.intH )
    btnNext:SetPos( scrW / 2 - btnNext:GetWide() / 2, scrH - btnNext:GetTall() - 50 )
    btnNext:SetText('')
    btnNext.OnCursorEntered = function(self)
        surface.PlaySound( "seefox/swelcome/hover_little.wav" )
    end
    function btnNext:Paint( w, h )
        local isHovered = self:IsHovered()
        local frameTime = FrameTime() * 10

        if isHovered then
            self.intW = Lerp( frameTime, self.intW, size200 + 10 )
            self.intH = Lerp( frameTime, self.intH, size100 + 10 )
        else
            self.intW = Lerp( frameTime, self.intW, size200 )
            self.intH = Lerp( frameTime, self.intH, size100 )
        end

        self:SetSize( self.intW, self.intH )
        self:SetPos( pContent:GetWide() / 2 - self:GetWide() / 2, pContent:GetTall() - self:GetTall() - 50 )

        surface.SetDrawColor( colWhite )
        surface.SetMaterial( matNext )
        surface.DrawTexturedRect( 0, 0, w, h )

        draw.SimpleTextOutlined(sWelcome:Translate( "CONTINUE" ), "sWelcome:32:B", w/2, h/2.2, colWhite, 1, 1, 1, colBlack)
        
        if isHovered then
            surface.SetDrawColor( colBlackH )
            surface.SetMaterial( matNext )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
    end
    function btnNext:DoClick()
        surface.PlaySound( "seefox/swelcome/alert.mp3" )

        if sWelcome.Music != "" and !boolFirstSpawn then
            surface.PlaySound( sWelcome.Music )
        end

        pContent:AlphaTo( 0, 0.5 )
        pContent:MoveTo( Base:GetX(), -pContent:GetTall() - size200, 0.8, 0, -1, function() 
            if boolFirstSpawn then
                Base:Remove()
                sWelcome:Create()
            else
                sWelcome:Transition()

                timer.Simple( 1, function()
                    sWelcome.IsOpen = false
                    if IsValid( Base ) then Base:Remove() end
                end )
            end
        end )
    end
end )

net.Receive( "sWelcome:Player:Register", function()
    sWelcome.LastError = net.ReadString()
    local boolClose = net.ReadBool()
    local boolNpc = net.ReadBool()

    if boolClose then
        if sWelcome.Music != "" and !boolNpc then
            surface.PlaySound( sWelcome.Music )
        end

        sWelcome:Transition()
        
        timer.Simple( 1, function()
            if IsValid( sWelcome.BaseC ) then sWelcome.BaseC:Remove() end
        end )
    end
end )

hook.Add( "InitPostEntity", "sWelcome:Player:Spawn", function()
    net.Start( "sWelcome:Player:OpenMenu" )
    net.SendToServer()
end )

hook.Add( "CalcView", "sWelcome:Player:CalcView", function( pPlayer, vecPos, vecAng, intFov )
    if !sWelcome.IsOpen then return end

    local frameTime = FrameTime()
    local pos = pPlayer:GetPos()
    local ang = pPlayer:GetAngles()

    if sWelcome.Cinimatic[ intCinimaticIndex ] then
        vecPosCinimatic = LerpVector( frameTime * sWelcome.Cinimatic[ intCinimaticIndex ]['Time'], vecPosCinimatic, sWelcome.Cinimatic[ intCinimaticIndex ]['EndPos'] )
        angPosCinimatic = LerpAngle( frameTime * sWelcome.Cinimatic[ intCinimaticIndex ]['Time'], angPosCinimatic, sWelcome.Cinimatic[ intCinimaticIndex ]['EndAngle'] )

        pos = vecPosCinimatic
        ang = angPosCinimatic

        if pos:DistToSqr( sWelcome.Cinimatic[ intCinimaticIndex ]['EndPos'] ) < 100000 then
            if !sWelcome.Cinimatic[ intCinimaticIndex + 1 ] then
                intCinimaticIndex = 1
            else
                intCinimaticIndex = intCinimaticIndex + 1
            end

            vecPosCinimatic = sWelcome.Cinimatic[ intCinimaticIndex ]['StartPos']
            angPosCinimatic = sWelcome.Cinimatic[ intCinimaticIndex ]['StartAngle']
        end
    end

	local view = {}

	view.origin = pos
	view.angles = ang
	view.fov = intFov
	view.drawviewer = true

	return view
end )

hook.Add( "HUDShouldDraw", "sWelcome:Player:HideHUD", function( name )
    if !sWelcome.IsOpen then return end

	if ( name == "CHudWeaponSelection" ) then return true end
	if ( name == "CHudChat" ) then return true end

	return false
end )

-- NPC
net.Receive( "sWelcome:Player:OpenNPC", function()
    sWelcome:Create( net.ReadEntity() )
end )