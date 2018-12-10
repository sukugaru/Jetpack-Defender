--[[
Jetpack Defender

Basic game idea:
Enemies fly in from the right.
The player has to shoot them down!
If too many get past, then Full Invasion mode starts, with a LOT MORE enemies on screen.

Interesting features in this version:
 - Using a 16:9 aspect ratio
 - Control scheme is Jetpack Joyride/Flappy Bird/Thrust/Tunnel/etc.
 - Press a button to apply thrust upwards, and release it to let gravity pull you back down
 - Press another button to shoot
 - Is super-simplified like this so that it can be touchscreened easily - touch left side of screen for a boost, 
   and right side to shoot.
 - Improved use of game states, and a title screen that is more of a title sequence
 - Will scale and offset the screen if the actual screen is not 640 x 360, or the aspect ratio is not 16:9.  To get the actual screen size, the game looks at conf.lua.
   
 

Versions 
10/12/2018 v1.0.1 Issue 19
mouse getX and getY were based on the actual window, not the game screen.
Have put in some overrides to account for this.
Also, a few minor updates to comments, and also moved the require(filedrop) into love.load

7/11/2018 v0.9.7 Following on from issue 7 (scaling)
Making sure scaling variables are set properly if the aspect ratio of the actual screen is 16:9.

7/11/2018 v0.9.6 Following on from issue 7 (scaling)
Uses the scalingBorder variables from conf.lua when drawing borders.
Done a few comment fixes here and there.

7/11/2018 v0.9.5 Issue 10
Have modified love.mousepressed to transform the x and y into Game Window coordinates, before calling the state's mousepressed handler.

7/11/2018 v0.9.4 Issue 7
Minor fixes - if actual screen was 640 x 360 then screenOffsetX and screenOffsetY were nil, causing problems elsewhere.

7/11/2018 v0.9.3 Issue 7
Scaling and translating/offsetting.
If conf.lua has a resolution other than 640 x 360, the game window is now scaled to fit, and if the actual resolution is not 16:9, the game window is translated/offset to the right or downwards as required.

7/11/2018 v0.9.2 Issues 13 and 5
Have split the title screen into additional states.

7/11/2018 v0.9.1 Issue 14
Using filesystem.getInfo instead of fileExists.  fileExists has been deprecated.

5/11/2018 v0.1.5 Issue 4
Added a new levelIntro.lua state.

5/11/2018 v0.1.4 Issue 11
Have moved the filedrop related variables to filedrop.lua.

5/11/2018 v0.1.3 Issue 12 - Highscores
Load high scores in love.load()

4/11/2018 v0.1.2 Assets pass
Few changes needed here, just making sure to include the new assets.lua file.

3/11/2018 v0.1.1 (adding speedlines)

   
1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.
]]--


g = love.graphics;
random = love.math.random;

-- Issue 19: Get backups of existing getX and getY
_mouseGetX = love.mouse.getX;
_mouseGetY = love.mouse.getY;


function love.load()
	-- Include standard library and assets
	lib = require('lib');
	require('assets');
	require('filedrop');
	
	-- game states
	logoScreen = require('logoScreen');
	titleIntro = require('titleIntro');
	titleScreen = require('titleScreen');
	highscoreScreen = require('highscores');

	game = require('game');
	gameOver = require('gameOver');
	pause = require('pause');
	levelIntro = require('levelIntro');

	minEnemySpeed = lib.windowWidth / 10; -- screen in 10 seconds
	maxEnemySpeed =  lib.windowWidth / 4;  -- screen in four seconds?
	bulletSpeed = lib.windowWidth / 2; -- screen in 2 seconds
	
	
	-- Set up spawners/factories for player and enemy objects
	spawners = {};
	spawners.player = require('player');
	spawners.enemy = require('enemy');
	spawners.bullet = require('bullet');
	spawners.speedline = require('speedLine');
	
	-- Load high scores
	highscores = {};
	
	info = love.filesystem.getInfo("highscores.dat");
	if info ~= nil then
		-- parse the file
		-- This is super basic but it works
		for line in love.filesystem.lines("highscores.dat") do
			table.insert(highscores, tonumber(line));
		end
	end

	-- Set up scaling values
	setupScaling();
	
	-- Start on the logo screen
	logoScreen:start();
end

function setupScaling()
	-- Compares the design resolution (640 x 360) to the actual screen size, and determines if:
	-- the screen needs to be scaled
	-- and if the actual resolution is not 16:9

	-- Design resolution was 640 x 460
	baseResX = 640;
	baseResY = 360;
	
	-- scaling is the value to apply in both X and Y directions.
	-- Initialising it to 1 here, and it may be modified later on.
	scaling = 1;
	
	-- screen offset is what position in the ACTUAL WINDOW to draw the GAME WINDOW
	-- Initialising to 0 (for a perfect fit in a 640x360 window) and it may be modified
	-- later in the function.
	screenOffsetX = 0;
	screenOffsetY = 0;
	
	-- Work out how design resolution relates to actual screen resolution
	lib.actualWidth = lib.windowWidth;
	widthRatio = lib.windowWidth / baseResX;
	lib.windowWidth = baseResX;

	lib.actualHeight = lib.windowHeight;
	heightRatio = lib.windowHeight / baseResY;
	lib.windowHeight = baseResY;
	

	-- Unless the current ratio is exactly 16:9, then the ratio variables are unqeual

	-- if the aspect ratio is narrower than 16:9, we want border bars on top and bottom
	-- and to translate the screen downwards (set screenOffsetY to something, and screenOffsetX to 0)
	if widthRatio < heightRatio then
		scaling = widthRatio;
		scaledX = lib.actualWidth;
		scaledY = baseResY * scaling;

		screenOffsetX = 0;
		screenOffsetY = (lib.actualHeight - scaledY) / 2;
		
	-- if the aspect ratio is wider than 16:9,  we want border bars on left and right
	-- and to translate the screen to the right (set screenOffsetX to something, and screenOffsetY to 0)
	elseif widthRatio > heightRatio then
		scaling = heightRatio;
		scaledX = baseResX * scaling;
		scaledY = lib.actualHeight;

		screenOffsetY = 0;
		screenOffsetX = (lib.actualWidth - scaledX) / 2;

	-- If they're equal, make sure that scaling is still set appropriately
	else
		scaling = heightRatio;
		scaledX = lib.actualWidth;
		scaledY = lib.actualHeight;
	
	end

	-- Set these true for legacy
	screenScaled = true;
	screenOffset = true;
		
end

-- Love callbacks
function love.draw()
	love.graphics.push();
	love.graphics.translate(screenOffsetX, screenOffsetY);
	love.graphics.scale(scaling, scaling);
	state:draw();

	-- Draw borders around the screen if necessary.
	-- Keeping both ways here for completness.
	
	--[[  -- Old way	
	-- The borders are relative to the ACTUAL WINDOW
	-- screenOffsetX, screenOffsetY, actualWidth, and actualHeight relate to the actual window.
	-- This does a pop first so that it can draw relative to the actual window.
	
	g.pop();
	
	g.setColor(scalingBorderR,scalingBorderG,scalingBorderB,scalingBorderT);
	
	-- Left
	g.rectangle("fill", 0, 0, screenOffsetX, lib.actualHeight);
	
	-- Right
	g.rectangle("fill", lib.actualWidth - screenOffsetX, 0, screenOffsetX, lib.actualHeight);
	
	-- Top
	g.rectangle("fill", 0, 0, lib.actualWidth, screenOffsetY);
	
	-- Bottom
	g.rectangle("fill", 0, lib.actualHeight - screenOffsetY, lib.actualWidth, screenOffsetY);
	]]--
	
	-- New way
	-- The borders are relative to the GAME WINDOW
	-- Its 0,0 is screenOffsetX, screenOffsetY in the ACTUAL WINDOW
	-- This way does a pop AFTER drawing the borders.

	g.setColor(scalingBorderR,scalingBorderG,scalingBorderB,scalingBorderT);
	
	-- Left
	g.rectangle("fill", -screenOffsetX / scaling, 0, screenOffsetX / scaling, lib.windowHeight);
	
	-- Right
	g.rectangle("fill", lib.windowWidth, 0, (screenOffsetX / scaling), lib.windowHeight);
	
	-- Top
	g.rectangle("fill", 0, -screenOffsetY / scaling, lib.windowWidth, screenOffsetY / scaling);
	
	-- Bottom
	g.rectangle("fill", 0, lib.windowHeight, lib.windowWidth, screenOffsetY / scaling);

	-- And finally pop this all off the graphics stack.
	love.graphics.pop();
	
end

function love.update(dt)
	-- only call the state's update if it exists
	if state.update ~= nil then
		state:update(dt);
	end
	
	-- drawback is that when a state:update does exist, it takes slightly longer to get into it
end

function love.keypressed(key, scancode, isrepeat)
	-- only call the state's keypressed if it exists
	if state.keypressed ~= nil then
		state:keypressed(key, scancode, isrepeat)
	end

end

function love.mousepressed(x, y, button, istouch, presses )
	-- only call the state's mousepressed if it exists
	if state.mousepressed ~= nil then

		-- The x and y here are relative to the ACTUAL Screen
		-- So they need to be transformed to the game window before calling the state's mousepressed.
	
		x = (x - screenOffsetX) / scaling;
		y = (y - screenOffsetY) / scaling;
	
		-- Call the state's mousepressed with the new x and y values.
		state:mousepressed(x, y, button, istouch, presses)
	end


end


-- Issue 19: Override getX to account for a scaled screen
function love.mouse.getX()
	-- print("Overridden mouse getX");
	x = (_mouseGetX() - screenOffsetX) / scaling;
	return x;
	
--	return _mouseGetX();
end

-- Issue 19: Override getY to account for a scaled screen
function love.mouse.getY()
	--print("Overridden mouse getY");
	
	y = (_mouseGetY() - screenOffsetY) / scaling;
	
	return y;
	

	-- return _mouseGetY();
end


