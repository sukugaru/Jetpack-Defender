--[[
levelIntro.lua

Is used at the beginning of a level to display an introductory message or animated sequence or whatever
At the moment (5/11/2018) there is only one level and the intro is "GET READY!" but this could be extended
to be a lot fancier.

Versions 
10/12/2018 v1.0.0
Some minor comment fixes

5/11/2018 v0.1 First version
To help address Issue 4, an intro mode is being introduced
It just says "Get ready!" for now.

]]--

-- --------------------------------------------------------
-- Level intro state

levelIntro = {};
levelIntro.timer = 0;

function levelIntro:start()
	-- Start a timer
	levelIntro.timer = 3;
	
	-- Make sure to stop title music
	assets.titleMusic:stop();
	
	-- Update state to "level Intro"
	state = self or levelIntro;
end

function levelIntro:update(dt)
	if levelIntro.timer > 0 then
		levelIntro.timer = levelIntro.timer - dt;
	else
		game:start();
	end
end

function levelIntro:draw()
	g.setColor(1,1,1,1);
	lib.centerMessage("GET READY!", "You've got to defend against the aliens!");
end

return levelIntro;