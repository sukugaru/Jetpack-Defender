--[[
v1.0 10/12/2018 Updates to comments
There were quite a few comments from player.lua and enemy.lua that were still in here, that didn't need to be.

v0.1 3/11/2018 Initial version
]]--

local speedline = lib.entity();

function speedline:new()
	local tbl = lib.clone(self);
	tbl.new = nil;

	-- i is random: 0, 0.5, or 1
	-- Used to control length, color, and speed
	-- j adds a little variation and ranges from 1 to 1.1
	local i = love.math.random(0,2) / 2;
	local j = 1 + (love.math.random(0,10) / 10);
	i = i * j;
	
	-- set up size
	tbl.w = 96 + (i*32);
	tbl.h = 1;
	tbl.x = lib.windowWidth;
	tbl.y = random(0,lib.windowHeight-tbl.h);
	

	-- Set up a speedline vector
	tbl.speed = {};
	tbl.speed.max = lib.windowWidth; --fullscreen in a second (ish)
	tbl.speed.min = lib.windowWidth / 4; -- fullscreen in 4 seconds (ish)
	
	tbl.velocity = {};
	tbl.velocity.x = (tbl.speed.min + ((tbl.speed.max - tbl.speed.min) * i)) * -1;
	tbl.velocity.y = 0;
	
	-- And finally a colour
	tbl.colour = {};
	tbl.colour.r = i;
	tbl.colour.g = i;
	tbl.colour.b = 0.6 + (i * 0.4);
	
	
	return tbl;
end

function speedline:draw()
	-- Super simple!
	
	g.setColor(self.colour.r,self.colour.g,self.colour.b);
	g.rectangle("fill",self.x, self.y, self.w, self.h);
end

function speedline:update(dt)
	-- Also super simple
	self.x = self.x + self.velocity.x * dt;
end


return speedline;