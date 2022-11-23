-- INITIALIZE SCRIPT
sWelcome = sWelcome or {}
sWelcome.Languages = sWelcome.Languages or {}

if SERVER then
	for _, v in ipairs( file.Find( "swelcome/sh_*.lua", "LUA" ) ) do
		include( "swelcome/" .. v )
		-- print("shared: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/sh_*.lua", "LUA" ) ) do
		AddCSLuaFile( "swelcome/" .. v )
		-- print("cs shared: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/sv_*.lua", "LUA" ) ) do
		include( "swelcome/" .. v )
		-- print("server: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/cl_*.lua", "LUA" ) ) do
		AddCSLuaFile( "swelcome/" .. v )
		-- print("cs client: ".. v)
	end
end

if CLIENT then
	for _, v in ipairs( file.Find( "swelcome/sh_*.lua", "LUA" ) ) do
		include( "swelcome/" .. v )
		-- print("shared client: ".. v)
	end
	
	for _, v in ipairs( file.Find( "swelcome/cl_*.lua", "LUA" ) ) do
		include( "swelcome/" .. v )
		-- print("client: ".. v)
	end
end

function sWelcome:Translate( strKey )
	return sWelcome.Languages[ sWelcome.Language ][ strKey ] or strKey
end