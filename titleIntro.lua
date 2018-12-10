--[[
Versions 
10/12/2018 v1.0
Minor updates to comments

7/11/2018 v0.9
First version
Created from titleScreen.lua (v0.1.5)

]]--

-- --------------------------------------------------------
-- Title Screen Intro text state
-- e.g. "In 201x, war was beginning!"

titleIntro = {};

function titleIntro:start()
	-- Use to initialise values then change the state to 'title Intro'
	titleIntro.timer = 0;
	
	-- Update state
	state = self or titleIntro;

	-- note: music is started by logoScreen:start()
end

function titleIntro:update(dt)
	-- Switch to main title screen after 5 seconds
	titleIntro.timer = titleIntro.timer + dt;
	
	if titleIntro.timer > 5 then
		titleScreen:start();
	end
end

function titleIntro:draw()

	-- Draw the background for everything other than the Logo screen
	g.setColor(1,1,1,1);
	g.draw(assets.titleBG,0,0);
	
	-- Scrolling introduction
	-- Going from bottom of screen to top in 5 seconds
	g.setColor(1,1,1);
		
	local msgY = -20 + (lib.windowHeight + 40) * ( (5 - titleIntro.timer) / 5);
	g.print("In the year 21XX, extremely nasty aliens are invading!", 100, msgY);
	g.print("You've got to stop them!", 100, msgY + 20);

end

function titleIntro:keypressed(key, scancode, isrepeat)

	-- Press space to skip to main screen
	if key == "space" then
		titleScreen:start();
	end
end


function titleIntro:mousepressed(x, y, button, istouch, presses)

	-- Or press LMB to skip to main title screen
	if button == 1 then
		titleScreen:start();
	end
	
end


return titleIntro;

