--[[
Versions 
10/12/2018 v0.9
Removed some more commented-out code

4/11/2018 v0.1.1 Adding graphic assets
Size has been changed slightly, to 60x60
Removing some commented-out sections

1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.

]]--



local enemy = lib.entity();

function enemy:new()
	local tbl = lib.clone(self);
	tbl.new = nil;
	
	-- set up size
	tbl.w, tbl.h = assets.enemy:getDimensions();
	tbl.x = lib.windowWidth;
	tbl.y = random(0,lib.windowHeight-tbl.h);
	
	-- Set up a enemy vector
	tbl.speed = {};
	tbl.speed.max = maxEnemySpeed;
	tbl.speed.min = minEnemySpeed;
	tbl.velocity = {};
	tbl.velocity.x = love.math.random(tbl.speed.min, tbl.speed.max) * -1;
	tbl.velocity.y = 0;
		
	return tbl;
end

function enemy:draw()
	
	-- is needed to make sure all the colors of the image are drawn as they were originally.
	-- Anything else will modify the colours of the player image or make it transparent.
	g.setColor(1,1,1,1);

	-- Actually draw the enemy
	g.draw(assets.enemy,self.x,self.y,0,1,1);
		
	-- Draw a hitbox around it, so we can see where the borders are
	--lib.hitbox(self);
end

-- Super simple, just move the enemy!
-- Collision checks are handled by the main game state
function enemy:update(dt)

	self.x = self.x + self.velocity.x * dt;
	
end

return enemy;