-- INITIALIZE SCRIPT
sWelcome = sWelcome or {}
sWelcome.Languages = sWelcome.Languages or {}

if SERVER then
	for _, v in ipairs( file.Find( "swelcome/languages/sh_*.lua", "LUA" ) ) do
		include( "swelcome/languages/" .. v )
		AddCSLuaFile( "swelcome/languages/" .. v )
		-- print("language: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/sh_*.lua", "LUA" ) ) do
		include( "swelcome/" .. v )
		-- print("shared: ".. v)
		AddCSLuaFile( "swelcome/" .. v )
		-- print("cs shared: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/core/sv_*.lua", "LUA" ) ) do
		include( "swelcome/core/" .. v )
		-- print("server: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/core/cl_*.lua", "LUA" ) ) do
		AddCSLuaFile( "swelcome/core/" .. v )
		-- print("cs client: ".. v)
	end
end

if CLIENT then
	for _, v in ipairs( file.Find( "swelcome/languages/sh_*.lua", "LUA" ) ) do
		include( "swelcome/languages/" .. v )
		-- print("language: ".. v)
	end

	for _, v in ipairs( file.Find( "swelcome/sh_*.lua", "LUA" ) ) do
		include( "swelcome/" .. v )
		-- print("shared client: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/core/cl_*.lua", "LUA" ) ) do
		include( "swelcome/core/" .. v )
		-- print("client: ".. v)
	end
end

if SERVER then
	resource.AddWorkshop( "2891280364" )
end

function sWelcome:Translate( strKey )
	return self.Languages[ self.Language ][ strKey ] or strKey
end