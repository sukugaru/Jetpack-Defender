--[[
This is a hodgepodge of library functions that I built up over the semester.


Versions 
10/11/2018 v0.9 
Updates to some comments.

4/11/2018 v0.1.1 (Adding assets pass)
In rewind and multi sound play, added parameter for "randomise pitch" and range of randomised pitch.
Have also added a lib.randomDecimal function.
   
1/11/2018 v0.1 (prototyping / alpha)
Brought in the lib I've been building up during the term.

]]--

 
 
local lib = {};

lib.windowWidth, lib.windowHeight = love.graphics.getDimensions();

 
-- This puts the helloWorld into the lib straightaway
-- Parameters change a bit - we'll get to that soon
function lib.helloWorld()
	print("Hello world");
end

-- This is a copy and paste from an earlier game project
function lib.checkKeyPairs(k1, k2)
	-- returns true if either button is held down
	if love.keyboard.isDown(k1) or love.keyboard.isDown(k2) then
		return true;
	else
		return false;
	end
	
	
end


-- Check collisions between two collision boxes
--[[ function lib.CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return (x1 < x2 + w2) and
	   (x2 < x1 + w1) and
	   (y1 < y2 + h2) and
	   (y2 < y1 + h1)
end
]]--

-- Something that is a bit nicer to use
-- ent1 and ent2 are the entities to check
-- Most game dev systems call things entities instead of objects
function lib.CheckCollision(ent1, ent2)
	return (ent1.x <  ent2.x + ent2.w) and
    	   (ent2.x < ent1.x + ent1.w) and
		   (ent1.y < ent2.y + ent2.h) and
		   (ent2.y < ent1.y + ent1.h);
end


-- Some sort of RGB shader
-- Returns values that can be used with love2D
-- Also demonstrates returning multiple values
-- If we did r1, g1, b1 = rgbToShader(values) then that assigns all three values to r1, g1, and b1
-- r1 = rgbToShader(values) throws away the second two values and just assigns to r1
function lib.rgbToShader(red, green, blue)
	return red / 255, green / 255, blue / 255

end

-- Basic game entity with a rectangular hitbox
function lib.entity()

	-- colour is only useful for primitive shapes
	-- speed is only useful for objectives that move
	
	--return {x = 0, y = 0, w = 0, h = 0};
	
	local tbl = {};
	tbl.x = 0; tbl.y = 0;
	tbl.w = 0; tbl.h = 0;
	tbl.draw = function() end;
	tbl.update = function() end;
	
	-- extra space for future features
	
	return tbl;
end

-- Create a copy of a table and return it 
function lib.clone(dolly)
	local tbl = {};
	
	for key, value in pairs(dolly) do
		tbl[key] = value;
	end

	return tbl;
end

-- Can use this either to set the colour, *or* set it to a default
-- Another RGB shader function, takes parameters that range from 0 to 255.
function lib.rgbSetColour(red, green, blue)
	-- Note to self: The following syntax sets red, green, and blue to what they were passed in, or to 255 if
	-- the parameters are null.
	red = red or 255;
	green = green or 255;
	blue = blue or 255;
	
	love.graphics.setColor(red / 255, green / 255, blue / 255);

end

-- Draws a red hitbox around an entity
function lib.hitbox(tbl)
	love.graphics.setColor(1,0,0); -- red
	love.graphics.rectangle("line", tbl.x, tbl.y, tbl.w, tbl.h);
	love.graphics.setColor(1,1,1);
end

-- Another new function from session 4
-- Sets up collision boxes just outside the screen.  Instead of checking for out of bounds, can just
-- check for collisions against these new collision boxes.
function lib.cameraWalls()
	-- top/bottom/left/right
	-- walls should have similar dimensions to edge of cameraWalls
	-- non trivial width to prevent a character skipping past the wall in a lag spike.

	-- the 'width' or 'depth' or 'height' of these bounding walls
	local margin = 100;

	-- Set up the walls
	local walls = {};
	
	walls.top = lib.entity();
	walls.top.x = 0 - margin;
	walls.top.y = 0 - margin;
	walls.top.w = lib.windowWidth + (margin * 2);
	walls.top.h = margin;
	
	walls.bottom = lib.entity();
	walls.bottom.x = 0 - margin;
	walls.bottom.y = lib.windowHeight;
	walls.bottom.w = lib.windowWidth + (margin * 2);
	walls.bottom.h = margin;
	
	walls.left = lib.entity();
	walls.left.x = 0 - margin;
	walls.left.y = 0 - margin;
	walls.left.w = margin;
	walls.left.h = lib.windowHeight + (margin * 2);
	
	walls.right = lib.entity();
	walls.right.x = lib.windowWidth;
	walls.right.y = 0 - margin;
	walls.right.w = margin;
	walls.right.h = lib.windowHeight + (margin * 2);
	
	return walls;
	
end

-- Put a number of strings in the center of the screen.
-- Takes up to 3 strings.
function lib.centerMessage(string1, string2, string3)
	if string1 == nil then string1 = "" end
	if string2 == nil then string2 = "" end
	if string3 == nil then string3 = "" end
	
	love.graphics.setColor(1,1,1,1);
	love.graphics.printf(string1, 0, lib.windowHeight/2 - 20, lib.windowWidth, "center");
	love.graphics.printf(string2, 0, lib.windowHeight/2, lib.windowWidth, "center");
	love.graphics.printf(string3, 0, lib.windowHeight/2 + 20, lib.windowWidth, "center");
end


-- Clamps n so that it's between minValue and maxValue.
function lib.clamp(minValue, n, maxValue)
	return math.min(math.max(n, minValue), maxValue);
end

--[[
This next plays a sound by cloning it and playing the clone.  This is so that the same sound effect can play
over the top of itself.  If I were to just do, for example, assets.glassping:play(), it needs to finish before
it can play again.

You can rewind a source and play it again, but this doesn't allow sounds to play over the top of each other.

Not sure what 'clone and play' means for memory usage.  The cloned sound is local so perhaps when it finishes
playing it gets garbage collected?

https://love2d.org/forums/viewtopic.php?t=80162
AND
https://love2d.org/wiki/Source:clone
AND
I saw a page that I can't find the URL for, but it suggested randomising the pitch a bit, to make the sound
effect more interesting.
]]--
function lib.multiSoundPlay(sound, randomPitch)
	local s = sound:clone();
	if randomPitch then
		local newPitch = math.random(1,20);
		newPitch = 1 - ((10 - newPitch) / 10);
		s:setPitch(newPitch);
	end
	s:play();
end


-- This function gives some control over how the sound effect's pitch should be randomised.
-- low and high are the range.
-- step is what value the random value should step in.
-- e.g. low = 0.7, high = 1.3, step = 0.1 generates 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, or 1.3.
function lib.multiSoundPlay(sound, randomPitch, low, high, step)
	local s = sound:clone();
	if randomPitch then
		local newPitch = lib.randomDecimal(low, high, step);
		s:setPitch(newPitch);
	end
	s:play();
end



--[[
This plays a sound by 'rewinding' it and playing it again.
The equivalent in the old days of playing sound effects on one sound channel - the second sound effect cuts
off the first one.
source:rewind() was deprecated in love 11 so you have to use either stop() or seek() instead.
]]--
function lib.rewindSoundPlay(sound, randomPitch)
	--local s = sound:clone();
	local newPitch = math.random(1,20);
	if randomPitch then
		newPitch = 1 - ((10 - newPitch) / 10);
		sound:stop();
		sound:setPitch(newPitch);
	end
	sound:play();
end

--[[
Michael has suggested to try something like this instead:

soundEffect = love.sound.newSoundData(file)
love.audio.play(love.audio.newSource(soundEffect)

You have the sound effect in memory once and each source points to it
love.sound is about sound data
love.audio is about playing sounds

]]--
function lib.playSoundData(sound)
	local s = love.audio.newSource(sound);

	local newPitch = math.random(1,20);
	newPitch = 1 - ((10 - newPitch) / 10);
	
	s:setPitch(newPitch);
	s:play();

end

-- I have tried both multiSoundPlay and playSoundData and monitored memory usage via task manager.
-- playSoundData rapidly causes high memory usage.
-- multiSoundPlay has a much lower rate of memory usage.

-- In theory playSoundData works like this:
--  - the SoundData is loaded into memory once
--  - every time newSource is called on that SoundData this is just creating a new reference to it
--
-- But as said above in practice its memory usage was much much higher.




-- Given a low decimal value and a high decimal value, come up with a random value in between them.
-- Step also lets you say if you want increments or steps in your values.
-- e.g. low 0.7, high 1, and step 0.1 will come up with either 0.7, 0.8, 0.9, or 1.
function lib.randomDecimal(low, high, step)
	range = high - low;

	if step ~= nil then
		actualRange = range / step;
		result = low + (love.math.random(0,actualRange) * step);
		print ("Low " .. low .. " High " .. high .. " step " .. step .. " range " .. range .. " actualRange " .. actualRange .. " result " .. result);
	else
		result = low + (love.math.random() * range);
		print ("Low " .. low .. " High " .. high .. " range " .. range .. " result " .. result);
	end
		
	
	return result
end



return lib;

--[[
 Change log
 (of old version we built in class)
 
 v1 (17/10/2018):
  - added width, height, variables
  - added checkKeyPairs (check if either supplied key is pressed)
  - CheckCollision
     -> modified method to accept two tables
	 -> tables must have x, y, w, and h
	 -> To do: standardised entities
  - added rgbToSahder and rgbSetColour
     - helper metohods for lazily setting colours.
     - allows for use of 8bit colours	 

 v2 (17/10/2018): ENTITES!
  - added standardised entities
  - lib.entity()
  
 v3 (24/10/2018):
  - Added lib.hitbox
  - Adding lib.cameraWalls
  
 v4 (31/10/2018):
  - multiSoundPlay (previously in main.lua)
  - rewindSoundPlay (previously in main.lua)
  - clamp (previously in main.lua)
  - centerMessage (previously in main.lua)
  - playSoundData (new)
 ]]--