--[[
Versions 
10/12/2018 v1.0
Minor updates to comments, and removing some commented-out code.

7/11/2018 v0.9.1 Issue 10
Updates to controlBoost and controlShoot to account for touchscreens, and modified how mouse input works:
 - a mouse click on the left side is Boost
 - a mouse click on the right side is Shoot

5/11/2018 v0.1.4 Issue 10
Adding controlBoost and controlShoot.
These can later be edited to look for touchscreen controls.


4/11/2018 v0.1.3
Fixed up some of the comments and removed commented-out code
Adjusted the check against the top of the screen.  The old approach of bouncing off the top of the screen wasn't working;
and would have been too annoying anyway.

4/11/2018 v0.1.2 Adding graphic assets
jetpack.png has been added and is the most generic jetpack hero imaginable.
This has changed the dimensions very slightly - from 32x64 to 30x60.
I tried 20x40 but it was too small.
Have also removed some commented-out code.

3/11/2018 v0.1.1 Issue #3
Removing the isDown(escape) from player.lua.
Checking for pause mode is now done in game.update.

1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.

]]--

local player = lib.entity();
-- entity gives us x, y, w, h, abstract draw and abstract update

-- Instance a new player
-- (Note that the player: in this declaration is the 'factory' or class, and it returns a *new* object 
-- which is the instanced player.)
function player:new()

	-- Create a new instance
	local tbl = lib.clone(self);	
	tbl.new = nil; -- Once the new instance has been constucted it doesn't need new() anymore

	-- Set dimensions and start position in bottom-left of the screen
	tbl.w, tbl.h = assets.player:getDimensions();
	tbl.x = 0 + (tbl.w);
	tbl.y = (lib.windowHeight - tbl.h);

	-- Direction and speed
	-- ..that's the way I did it, but Michael does it like so, with a velocity 'object'
	tbl.velocity = {};
	tbl.velocity.x = 0;
	tbl.velocity.y = 0;
	tbl.velocity.speed = 300;

	-- gravity and max falling speed
	tbl.gravity = 100;
	tbl.maxFallSpeed = tbl.velocity.speed * 2.5;
	
	-- Player starts off as alive
	tbl.alive = true;
	
	
	return tbl;
end


function player:draw()


	-- This use of setcolor is a bit tricky.  setColor is needed to make sure all the colors of the image are drawn as they
	-- were originally.  Anything else will modify the colours of the player image or make it transparent.
	g.setColor(1,1,1,1);
	
	-- Actually draw the player!
	g.draw(assets.player,self.x,self.y,0,1,1);
	
	-- If the player is rising/boosting, then draw in some exhaust from jetpack and rocket boots
	g.setColor(1,1,0.5,0.9);
	
	if self.velocity.y < 0 then
		g.polygon("fill", self.x + 8, self.y+self.h+2,
					      self.x + 18, self.y+self.h+2, 
						  self.x+(self.w/2), self.y + (self.h*1.5), 
						  self.x + 8, self.y+self.h+2);
		g.polygon("fill", self.x, self.y+31,
					      self.x + 6, self.y+31, 
						  self.x+3, self.y + 31 + (self.h/2), 
						  self.x, self.y+31);

	end

	--Draw a hitbox around the player, so we can see where the borders are
	--lib.hitbox(self);
	
end

function player:update(dt)
	-- Check input and update vertical velocity
	if controlBoost() then
		self.velocity.y = 0 - self.velocity.speed;
	end

	-- update vertical position
	local newY = self.y + self.velocity.y * dt;	
		
	-- stop at top of screen
	if newY < 0 then
		newY = 0;
		self.velocity.y = 0;
	end
	
	-- check if on ground
	if newY >= lib.windowHeight - self.h then
		newY = lib.windowHeight - self.h
		self.velocity.y = 0;

	-- if not on ground, aply gravity
	else
		self.velocity.y = self.velocity.y + self.gravity;
		self.velocity.y = math.min(self.maxFallSpeed, self.velocity.y);
	end
	
	-- update to new position!
	self.y = newY;
	
	-- Check for shooting
	if controlShoot() and
		(game.numBulletsOnScreen < game.maxBulletsOnScreen) and
		(game.bulletsDelayTimer <= 0) then

		game:spawnBullet();
	end
	
	-- Collisions aren't done here,  because the player object knows nothing
	-- about the wall or enemy objects.
	-- game.update will call collision checking code instead
	
end

-- Returns true if the player is pressing the 'Boost' button
-- Whether that's W, cursor-up, touching the left hand side of the screen, etc.
function controlBoost()
	local z = lib.checkKeyPairs;
	
	local returnValue = false;

	-- W or cursor-up on keyboard
	if z("w", "up") then
		returnValue = true;
	
	end
	
	-- Mouse button on left side of screen
	if love.mouse.isDown(1) then
		local x = love.mouse.getX();
		if x < lib.windowWidth / 2 then
			returnValue = true;
		end
			
	end

	-- Theoretical touchscreen input on left side of screen
    local touches = love.touch.getTouches()
 
    for i, id in ipairs(touches) do
        local x, y = love.touch.getPosition(id)
		if x < lib.windowWidth / 2 then
			returnValue = true;
		end
    end	
	
	return returnValue;

end

-- Returns true if the player is pressing the 'Shoot' button
-- Whether that's Space,  touching the right hand side of the screen, etc.
function controlShoot()
	local z = lib.checkKeyPairs;
	local k = love.keyboard.isDown;
	
	local returnValue = false;
	
	-- Space bar
	if k("space") then
		returnValue = true;
	
	end

	-- Mouse button on right side of screen
	if love.mouse.isDown(1) then
		local x = love.mouse.getX();
		if x > lib.windowWidth / 2 then
			returnValue = true;
		end
	end
	
	-- Theoretical touchscreen input on right side of screen
    local touches = love.touch.getTouches()
 
    for i, id in ipairs(touches) do
        local x, y = love.touch.getPosition(id)
		if x < lib.windowWidth / 2 then
			returnValue = true;
		end
    end	
	

	return returnValue;

end



-- Kill the player
function player:kill()
	self.alive = false;
end

return player;