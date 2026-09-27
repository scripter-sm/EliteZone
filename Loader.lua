--[[
               
  ____ ________
_/ __ \\___   /
\  ___/ /    / 
 \___  >_____ \
     \/      \/

]]

if (getgenv().EZ_LOADED) then
	warn("[ Elite Zone ] Elite Zone is already loaded.")
	return;
end;

loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/fc6c41033fff55a0515fd72167127e8be413724c62cdcc464a6a9e9b3a84bb5b/download"))()
