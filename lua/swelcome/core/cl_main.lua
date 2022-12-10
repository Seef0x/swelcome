sWelcome.LastError = sWelcome.LastError or ""
sWelcome.IsOpen = sWelcome.IsOpen or false

-- Sizes
local scrW = ScrW()
local scrH = ScrH()

function sWelcome.Scale( intSize, strAxis )
    if strAxis == "x" then
        intSize = scrW * ( intSize / 1920 )
    elseif strAxis == "y" or strAxis == nil then
        intSize = scrH * ( intSize / 1080 )
    end
    
    return math.Round( intSize )
end

-- Colors
local colWhite = Color( 255, 255, 255 )
local colGrey = Color( 49, 49, 48 )
local colBlack = Color( 0, 0, 0 )
local colBlackH = Color( 0, 0, 0, 150 )
local colOrange = Color( 255, 184, 176 )
local colOrangeH = Color( 255, 184, 176, 200 )

-- Fonts
surface.CreateFont( 'sWelcome:MOTD', { font = 'Roboto', size = sWelcome.Scale( 20, "y" ), weight = 550, antialias = true } )

local cachedFonts = {}

function sWelcome:Font( intSize, boolShadow )
    intSize = intSize or 13
    
    local strIdentifier = "sWelcome:" .. intSize .. ( boolShadow and "S" or "" )
    
    if cachedFonts[ strIdentifier ] then return strIdentifier end

    surface.CreateFont( strIdentifier, {
        font = "QUARTZO",
        size = self.Scale( intSize, "y" ),
        weight = 800,
        blursize = boolShadow and 3 or 0
    } )

    cachedFonts[ strIdentifier ] = true

    return strIdentifier
end

-- Materials
local matBg = Material( "seefox/swelcome/background.png" )
local matStart = Material( "seefox/swelcome/start.png" )
local matNext = Material( "seefox/swelcome/continue.png", "smooth 1" )
local matDiscord = Material( "seefox/swelcome/discord.png", "smooth 1" )
local matBgDiscord = Material( "seefox/swelcome/bluereflect.png", "smooth 1" )
local matCross = Material( "seefox/swelcome/cross.png" )

-- Blur
local matBlur = Material( "pp/blurscreen" )
function sWelcome.DrawBlur( panel, amount )
	local x, y = panel:LocalToScreen( 0, 0 )

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
    local Base = vgui.Create( "EditablePanel" )
    Base:SetSize( scrW, scrH )
    Base:CenterVertical()
	Base:CenterHorizontal()
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
        if !IsValid( Base ) then return end
        
        Base:Remove()
    end )

    self.pTransition = Base
end

function sWelcome:DrawMOTD( w, h )
    surface.SetFont( "sWelcome:MOTD" )
    local intTextHeight = select( 2, surface.GetTextSize( "EXAMPLE" ) )
    local intMaxWidth = 0
    local strSplittedText = string.Split( self.MOTD, "\n" )

    for _, v in ipairs( strSplittedText ) do
        local intTextSize = surface.GetTextSize( v )

        if intMaxWidth < intTextSize then
            intMaxWidth = intTextSize
        end
    end

    local intW = intMaxWidth + self.Scale( 20, "x" )
    local intH = #strSplittedText * intTextHeight + self.Scale( 20, "x" )
    local intX = w - intW - self.Scale( 15, "x" )
    local intY = self.Scale( 15, "y" )

    surface.SetDrawColor( 0, 0, 0, 140 )
    surface.DrawRect( intX, intY, intW, intH )
    surface.DrawOutlinedRect( intX, intY, intW, intH )

    draw.DrawText( self.MOTD, "sWelcome:MOTD", intX, intY + self.Scale( 20, "y" ), colWhite)
end

function sWelcome.Create( entNpc )
    local Base = vgui.Create( "EditablePanel" )
    Base:SetSize( scrW, scrH )
    Base:CenterVertical()
	Base:CenterHorizontal()
    Base:MakePopup()
    function Base:Paint( w, h )
        if !entNpc then
            sWelcome.DrawBlur( self, 12 )
            
            sWelcome:DrawMOTD( w, h )
        end
    end
    function Base:OnRemove()
        sWelcome.LastError = ""
        sWelcome.IsOpen = false
    end

    local intMsgW = sWelcome.Scale( 681, "x" )
    local intMsgH = sWelcome.Scale( 488, "y" )
    local intMsgX = Base:GetWide() / 2 - intMsgW / 2 + sWelcome.Scale( 20, "x" )
    local intMsgY = Base:GetTall() / 2 - intMsgH / 2 - sWelcome.Scale( 80, "y" )

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

        if entNpc == LocalPlayer() then
            local strText = string.Split( sWelcome:Translate( "FORCENAME" ), "\n" ) 
            draw.SimpleTextOutlined( strText[1], sWelcome:Font( 28 ), w / 2 + sWelcome.Scale( 60, "x" ), sWelcome.Scale( 340, "y" ), colOrange, 1, 4, 1, colBlack )
            draw.SimpleTextOutlined( strText[2], sWelcome:Font( 28 ), w / 2 + sWelcome.Scale( 60, "x" ), sWelcome.Scale( 365, "y" ), colOrange, 1, 4, 1, colBlack )
        else
            if sWelcome.ServerLogo then
                surface.SetMaterial( sWelcome.ServerLogo )
                surface.DrawTexturedRect( w*.5, h*.25, sWelcome.Scale( 120, "x" ), sWelcome.Scale( 120, "y" ) )
            end
        end

        if !entNpc and sWelcome.SCP then
            draw.SimpleTextOutlined(
                sWelcome:Translate( "NUMBER" ) .. ":",
                sWelcome:Font( 24 ),
                intMsgX + sWelcome.Scale( 230, "x" ),
                intMsgY + intMsgH / 2 + sWelcome.Scale( 28, "y" ),
                colWhite,
                2,
                0,
                1,
                colBlack
            )
        else
            draw.SimpleTextOutlined(
                sWelcome:Translate( "NAME" ) .. ":",
                sWelcome:Font( 24 ),
                intMsgX + sWelcome.Scale( 230, "x" ),
                intMsgY + intMsgH / 2 + sWelcome.Scale( 28, "y" ),
                colWhite,
                2,
                0,
                1,
                colBlack
            )

            draw.SimpleTextOutlined(
                sWelcome:Translate( "SURNAME" ) .. ":",
                sWelcome:Font( 24 ),
                intMsgX + sWelcome.Scale( 210, "x" ),
                intMsgY + intMsgH / 2 + sWelcome.Scale( 113, "y" ),
                colWhite,
                2,
                0,
                1,
                colBlack
            )
        end

        if entNpc and sWelcome.NameChangeCost > 0 then
            draw.SimpleTextOutlined( 
                sWelcome:Translate( "COST" ) .. ": " .. DarkRP.formatMoney( sWelcome.NameChangeCost ), 
                sWelcome:Font( 24 ), 
                intMsgX + sWelcome.Scale( 260, "x" ), 
                intMsgY + intMsgH / 2 + sWelcome.Scale( 173, "y" ), 
                colWhite,
                2,
                0,
                1, 
                colBlack
            )
        end
    end

    if entNpc != LocalPlayer() then
        local btnDisconnect = vgui.Create( "DButton", pContent )
        btnDisconnect:SetText('')
        if entNpc then
            btnDisconnect:SetSize( sWelcome.Scale( 16, "x" ), sWelcome.Scale( 16, "y" ) )
            btnDisconnect:SetPos( Base:GetWide() * .65, Base:GetTall() * .22 )
            function btnDisconnect:Paint( w, h )
                surface.SetDrawColor( colWhite )
                surface.SetMaterial( matCross )
                surface.DrawTexturedRect( 0, 0, w, h )
            end
            function btnDisconnect:DoClick()
                pContent:AlphaTo( 0, 0.5 )
                pContent:MoveTo( Base:GetX(), -pContent:GetTall() - sWelcome.Scale( 200, "y" ), 0.8, 0, -1, function() 
                    Base:Remove()
                end )
            end
        else
            btnDisconnect:SetSize( sWelcome.Scale( 160, "x" ), sWelcome.Scale( 20, "y" ) )
            btnDisconnect:SetPos( sWelcome.Scale( 15, "x" ), sWelcome.Scale( 15, "y" ) )
            function btnDisconnect:Paint( w, h )
                draw.SimpleTextOutlined( sWelcome:Translate( "DISCONNECT" ), sWelcome:Font( 24 ), 1, h / 2, self:IsHovered() and colOrangeH or colOrange, 0, 1, 1, colBlack )
            end
            function btnDisconnect:DoClick()
                LocalPlayer():ConCommand( 'disconnect' )
            end
        end
    end

    local pName = vgui.Create( "DTextEntry", pContent )
    pName:SetSize( sWelcome.Scale( 200, "x" ), sWelcome.Scale( 30, "y" ) )
    pName:SetPos( intMsgX + sWelcome.Scale( 250, "x" ), intMsgY + intMsgH / 2 + sWelcome.Scale( 30, "y" ) )
    pName:SetDrawLanguageID( false )

    local pSurname = vgui.Create( "DTextEntry", pContent )
    pSurname:SetSize( sWelcome.Scale( 220, "x" ), sWelcome.Scale( 30, "y" ) )
    pSurname:SetPos( intMsgX + sWelcome.Scale( 230, "x" ), intMsgY + intMsgH / 2 + sWelcome.Scale( 113, "y" ) )
    pSurname:SetDrawLanguageID( false )
    if !entNpc and sWelcome.SCP then
        pName:SetEditable(false)
        pName:SetValue("D-")
        pSurname:SetNumeric(true)
        function pSurname:AllowInput()
            if string.len(self:GetValue()) >= 4 then return true end
        end
    end
    
    local superAngle = Angle(0, -5, 0)
    local btnStart = vgui.Create( "DButton", pContent )
    btnStart:SetSize( sWelcome.Scale( 200, "x" ), sWelcome.Scale( 100, "y" ) )
    btnStart:SetText('')
    btnStart.intW = sWelcome.Scale( 524, "x" )
    btnStart.intH = sWelcome.Scale( 180, "y" )
    btnStart.OnCursorEntered = function()
        surface.PlaySound( "seefox/swelcome/hover_little.wav" )
    end
    function btnStart:Paint( w, h )
        local isHovered = self:IsHovered()
        local frameTime = FrameTime() * 10

        if isHovered then
            self.intW = Lerp( frameTime, self.intW, sWelcome.Scale( 534, "x" ) )
            self.intH = Lerp( frameTime, self.intH, sWelcome.Scale( 190, "y" ) )
        else
            self.intW = Lerp( frameTime, self.intW, sWelcome.Scale( 524, "x" ) )
            self.intH = Lerp( frameTime, self.intH, sWelcome.Scale( 180, "y" ) )
        end

        self:SetSize( self.intW, self.intH )
        self:SetPos( intMsgX - sWelcome.Scale( 68, "x" ), intMsgY + intMsgH - sWelcome.Scale( 57, "y" ) )

        surface.SetDrawColor( colWhite )
        surface.SetMaterial( matStart )
        surface.DrawTexturedRect( 0, 0, w, h - sWelcome.Scale( 15, "y" ) )

        render.PushFilterMag( TEXFILTER.ANISOTROPIC )
        render.PushFilterMin( TEXFILTER.ANISOTROPIC )

        local x, y = w * .4, ( h - sWelcome.Scale( 15, "y" ) ) * .86
        local mx = Matrix()

        mx:Translate( Vector( x, y ) )
        mx:Rotate( superAngle )
        mx:Translate( Vector( -x, -y ) )

        cam.PushModelMatrix( mx )
            draw.SimpleTextOutlined( entNpc and string.upper( sWelcome:Translate( "ChangeName" ) ) or sWelcome:Translate( "STARTADVENTURE" ), sWelcome:Font( 30 ), x, y, colWhite, 1, 4, 4, colGrey )
        cam.PopModelMatrix()

        render.PopFilterMag()
        render.PopFilterMin()

        if isHovered then
            surface.SetDrawColor( colBlackH )
            surface.SetMaterial( matStart )
            surface.DrawTexturedRect( 0, 0, w, h - sWelcome.Scale( 15, "y" ) )
        end        

        if string.len( sWelcome.LastError ) > 0 then
            draw.SimpleTextOutlined( sWelcome:Translate( sWelcome.LastError ), sWelcome:Font( 24 ), w / 2, h, colOrange, 1, 4, 1, colBlack )
        end
    end
    function btnStart:DoClick()
        surface.PlaySound( "seefox/swelcome/btn_heavy.ogg" )

        net.Start( "sWelcome:Player:Register" )
        net.WriteString( pName:GetValue() )
        net.WriteString( pSurname:GetValue() )
        if entNpc != LocalPlayer() then
            net.WriteEntity( entNpc )
        end
        net.SendToServer()
    end

    sWelcome.BaseC = Base
end

net.Receive( "sWelcome:Player:OpenMenu", function()
    local boolFirstSpawn = net.ReadBool()

    intCinematicIndex = 1
    sWelcome.IsOpen = true

    local intMod = 0
    local intModMax = sWelcome.Scale( 60, "y" )
    local boolDown = true
    local intNextMod = 0

    local Base = vgui.Create( "EditablePanel" )
    Base:SetSize( scrW, scrH )
    Base:CenterVertical()
	Base:CenterHorizontal()
    Base:MakePopup()
    function Base:Paint( w, h )
        sWelcome.DrawBlur( self, 12 )

        sWelcome:DrawMOTD( w, h )
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
        local intMsgY = sWelcome.Scale( 50, "y" )

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
            local intLogoWidth = sWelcome.ServerLogo:Width()

            surface.SetDrawColor( colWhite )
            surface.SetMaterial( sWelcome.ServerName )
            surface.DrawTexturedRect( Base:GetWide() / 2 - intLogoWidth / 2, intMsgY, intLogoWidth, sWelcome.ServerLogo:Height() )
        else
            draw.SimpleText( sWelcome:Translate( "WELCOMETO" ), sWelcome:Font( 30 ), w / 2, intMsgY + sWelcome.Scale( 12, "y" ), colWhite, 1 )
            
            local y = intMsgY + sWelcome.Scale( 25, "y" )
            draw.SimpleText( sWelcome.ServerName, sWelcome:Font( 105, true ), w / 2, y + 4, ColorAlpha(color_black, 120), 1, TEXT_ALIGN_TOP )
            draw.SimpleText( sWelcome.ServerName, sWelcome:Font( 105 ), w / 2, y + 4, ColorAlpha(color_black, 150), 1, TEXT_ALIGN_TOP )
            draw.SimpleText( sWelcome.ServerName, sWelcome:Font( 105 ), w / 2, y, sWelcome.ServerNameColor, 1, TEXT_ALIGN_TOP )
        end
    end

    local btnDisconnect = vgui.Create( "DButton", Base )
    btnDisconnect:SetSize( sWelcome.Scale( 160, "x" ), sWelcome.Scale( 20, "y" ) )
    btnDisconnect:SetPos( sWelcome.Scale( 15, "x" ), sWelcome.Scale( 15, "y" ) )
    btnDisconnect:SetText('')
    function btnDisconnect:Paint( w, h )
        draw.SimpleTextOutlined( sWelcome:Translate( "DISCONNECT" ), sWelcome:Font( 24 ), 1, h / 2, self:IsHovered() and colOrangeH or colOrange, 0, 1, 1, colBlack )
    end
    function btnDisconnect:DoClick()
        LocalPlayer():ConCommand( 'disconnect' )
    end

    if sWelcome.DiscordLink != "" then
        local btnDiscord = vgui.Create( "DButton", pContent )
        btnDiscord:SetSize( sWelcome.Scale( 500, "x" ), sWelcome.Scale( 80, "y" ) )
        btnDiscord:SetPos( scrW / 2 - btnDiscord:GetWide() / 2, scrH / 2 - btnDiscord:GetTall() / 2 )
        btnDiscord:SetText('')
        btnDiscord.intLerpLogo = 0
        btnDiscord.OnCursorEntered = function()
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

            surface.DrawTexturedRectRotated( sWelcome.Scale( 72, "x" ), h / 2 - 5, sWelcome.Scale( 64, "x" ), sWelcome.Scale( 64, "y" ), self.intLerpLogo )

            draw.SimpleTextOutlined( sWelcome:Translate( "JOINUS" ), sWelcome:Font( 29 ), w / 2 + sWelcome.Scale( 30, "x" ), h / 2 - 5, colWhite, 1, 1, 1, colBlack )    
        end
        function btnDiscord:DoClick()
            surface.PlaySound( "seefox/swelcome/flash.ogg" )
            notification.AddLegacy( sWelcome:Translate( "CopiedLink" ), NOTIFY_GENERIC, 4 )
            SetClipboardText( sWelcome.DiscordLink )
            gui.OpenURL( sWelcome.DiscordLink )
        end
    end

    local btnNext = vgui.Create( "DButton", pContent )
    btnNext.intW = sWelcome.Scale( 200, "x" )
    btnNext.intH = sWelcome.Scale( 100, "y" )
    btnNext:SetSize( btnNext.intW, btnNext.intH )
    btnNext:SetPos( scrW / 2 - btnNext:GetWide() / 2, scrH - btnNext:GetTall() - sWelcome.Scale( 50, "y" ) )
    btnNext:SetText('')
    btnNext.OnCursorEntered = function()
        surface.PlaySound( "seefox/swelcome/hover_little.wav" )
    end
    function btnNext:Paint( w, h )
        local isHovered = self:IsHovered()
        local frameTime = FrameTime() * 10

        if isHovered then
            self.intW = Lerp( frameTime, self.intW, sWelcome.Scale( 210, "x" ) )
            self.intH = Lerp( frameTime, self.intH, sWelcome.Scale( 110, "y" ) )
        else
            self.intW = Lerp( frameTime, self.intW, sWelcome.Scale( 200, "x" ) )
            self.intH = Lerp( frameTime, self.intH, sWelcome.Scale( 100, "y" ) )
        end

        self:SetSize( self.intW, self.intH )
        self:SetPos( pContent:GetWide() / 2 - self:GetWide() / 2, pContent:GetTall() - self:GetTall() - sWelcome.Scale( 50, "y" ) )

        surface.SetDrawColor( colWhite )
        surface.SetMaterial( matNext )
        surface.DrawTexturedRect( 0, 0, w, h )

        draw.SimpleTextOutlined( sWelcome:Translate( "CONTINUE" ), sWelcome:Font( 32 ), w / 2, h / 2.2, colWhite, 1, 1, 1, colBlack )
        
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
        pContent:MoveTo( Base:GetX(), -pContent:GetTall() - sWelcome.Scale( 200, "y" ), 0.8, 0, -1, function() 
            if boolFirstSpawn then
                Base:Remove()
                sWelcome.Create()
            else
                sWelcome:Transition()

                timer.Simple( 1, function()
                    sWelcome.IsOpen = false
                    if IsValid( Base ) then Base:Remove() end
                    sWelcome.Actions()
                end )
            end
        end )
    end
end )

net.Receive( "sWelcome:Player:Register", function()
    sWelcome.LastError = net.ReadString()
    local boolClose = net.ReadBool()
    local boolNpc = net.ReadBool()

    if !boolClose then return end

    if sWelcome.Music != "" and !boolNpc then
        surface.PlaySound( sWelcome.Music )
    end

    sWelcome:Transition()
    
    timer.Simple( 1, function()
        if IsValid( sWelcome.BaseC ) then sWelcome.BaseC:Remove() end
    end )
end )

hook.Add( "InitPostEntity", "sWelcome:Player:Spawn", function()
    net.Start( "sWelcome:Player:OpenMenu" )
    net.SendToServer()
end )

local intCinematicIndex = 1
local vecPosCinematic = sWelcome.Cinematics[ intCinematicIndex ]['StartPos']
local angPosCinematic = sWelcome.Cinematics[ intCinematicIndex ]['StartAngle']

hook.Add( "CalcView", "sWelcome:Player:CalcView", function( pPlayer, vecPos, _, intFov )
    if !sWelcome.IsOpen then return end

    local frameTime = FrameTime()
    local pos = pPlayer:GetPos()
    local ang = pPlayer:GetAngles()

    if sWelcome.Cinematics[ intCinematicIndex ] then
        vecPosCinematic = LerpVector( frameTime * sWelcome.Cinematics[ intCinematicIndex ]['Time'], vecPosCinematic, sWelcome.Cinematics[ intCinematicIndex ]['EndPos'] )
        angPosCinematic = LerpAngle( frameTime * sWelcome.Cinematics[ intCinematicIndex ]['Time'], angPosCinematic, sWelcome.Cinematics[ intCinematicIndex ]['EndAngle'] )

        pos = vecPosCinematic
        ang = angPosCinematic

        if pos:DistToSqr( sWelcome.Cinematics[ intCinematicIndex ]['EndPos'] ) < 100000 then
            if !sWelcome.Cinematics[ intCinematicIndex + 1 ] then
                intCinematicIndex = 1
            else
                intCinematicIndex = intCinematicIndex + 1
            end

            vecPosCinematic = sWelcome.Cinematics[ intCinematicIndex ]['StartPos']
            angPosCinematic = sWelcome.Cinematics[ intCinematicIndex ]['StartAngle']
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

	if name == "CHudWeaponSelection" then return true end
	if name == "CHudChat" then return true end

	return false
end )

-- NPC
net.Receive( "sWelcome:Player:OpenNPC", function()
    sWelcome.Create( net.ReadEntity() )
end )