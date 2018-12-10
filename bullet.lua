--[[
Versions 
4/11/2018 v0.1.2 Adding graphic assets
Have also changed the offset from the player when spawned.
Because of the outline thing noted in issue #2, there's a black outline in bullet.png, but the hitbox doesn't include it.
Removing commented-out code

3/11/2018 v0.1.1 Issue #2
Drawing a background around the player bullets.
(Something to note when adding graphic assets - bullets will need a dark outline to help distinguish them from the
speedlines in the background.)

1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.

]]--

local bullet = lib.entity();

function bullet:new()
	local tbl = lib.clone(self);
	tbl.new = nil;
	
	-- set up size and position
	--tbl.w, tbl.h = assets.bullet:getDimensions();
	tbl.w = 60;
	tbl.h = 3;
	tbl.x = player.x + player.w;
	tbl.y = player.y + 17;
	
	
	-- Set up bullet vector
	tbl.velocity = {};
	tbl.velocity.x = bulletSpeed;
	tbl.velocity.y = 0;
	
	
	return tbl;
end

function bullet:draw()
	
	-- is needed to make sure all the colors of the image are drawn as they were originally.
	-- Anything else will modify the colours of the player image or make it transparent.
	g.setColor(1,1,1,1);
	
	-- Actually draw the bullet
	g.draw(assets.bullet,self.x,self.y-1);

		
	-- Draw a hitbox around it, so we can see where the borders are
	--lib.hitbox(self);
end

function bullet:update(dt)
	-- Super simple, just move the bullet!
	-- Collision checks are handled by the game state's update
	self.x = self.x + self.velocity.x * dt;
	
	-- We'll worry about multiple enemies and respawns in a minute
end

return bullet;