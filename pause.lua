--[[
Versions 
10/12/2018 v1.0.0
Minor updates to comments

7/11/2018 v0.9.1 Issue 10
Fixing the wrapper around mousepressed.  It's now been moved to main.lua's love.mousepressed callback.
Mousepressed anywhere on screen will unpause.

3/11/2018 v0.1.1 Issue #3
Escape doesn't properly quit from pause mode.

1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.

]]--

-- --------------------------------------------------------
-- Pause state

pause = {};

function pause:start()
	-- Use to initialise values then change the state to 'game'

	-- Update state to "pause"
	state = self or pause;
end

function pause:update(dt)
	--pause.timer = pause.timer + dt;
	--print(pause.timer);

end

function pause:draw()
	-- Draw player, enemies, bullets, score, etc.
	game:draw();
	
	-- Draw half-transparent giant black box over everything to darken screen
	g.setColor(0,0,0,0.5);
	g.rectangle("fill",1,1,lib.windowWidth, lib.windowHeight);

	-- Pause message
	lib.centerMessage("PAUSED", "Press space or escape to resume");
	
end

function pause:keypressed(key, scancode, isrepeat)
	if key == "space" or (key == "escape" and isrepeat == false) then
		state = game;
	end
end


function pause:mousepressed(x, y, button, istouch, presses)
	
	if button == 1 then
		state = game;
	end
	
end


return pause;