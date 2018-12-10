--[[
Versions 
10/12/2018 v1.0
Updates to some comments.
Fixed a silly bug in start().

7/11/2018 v0.9
First version
Created from titleSCreen.lua (v0.1.5)

]]--

-- --------------------------------------------------------
-- Title Screen logo state

logoScreen = {};

logoScreen.entities = {};
logoScreen.entities.start = { x = 0, y = 0, w = assets.startButton:getWidth(), h = assets.startButton:getHeight()  };
logoScreen.entities.quit = { x = 0, y = 0, w = assets.quitButton:getWidth(), h = assets.quitButton:getHeight() };

logoScreen.highscoreTable = "";

function logoScreen:start()
	-- Use to initialise values then change the state to 'logo screen'
	logoScreen.timer = 0;

	-- Update state
	state = self or logoScreen;

	-- Title screen music starts here
	assets.titleMusic:play();
end

function logoScreen:update(dt)
	logoScreen.timer = logoScreen.timer + dt;
	
	if logoScreen.timer > 5 then
		-- advance to intro screen
		titleIntro:start();
	end
end

function logoScreen:draw()

	-- Local variables used in various transparency and special effects
	local tr = 0;

	-- Logo screen
	if  logoScreen.timer < 1 then
		tr =  logoScreen.timer;
	elseif  logoScreen.timer > 4 then
		tr = (5 -  logoScreen.timer);
	else
		tr = 1;
	end
		
	g.setColor(1,1,1,tr);
	g.printf("Logo Screen", 0, lib.windowHeight/3, lib.windowWidth, "center");
		
	g.printf("Made with Lua and Love2d at TAFE", 0, lib.windowHeight/2, lib.windowWidth, "center");
	g.printf("Let's Make Great (Games)!", 0, lib.windowHeight/2 + 20, lib.windowWidth, "center");
	
end

function logoScreen:keypressed(key, scancode, isrepeat)
	-- Skip to titleIntro state if space is pressed
	if key == "space" then
		titleIntro:start();
	end
end


function logoScreen:mousepressed(x, y, button, istouch, presses)
	-- Skip to titleIntro state if player presses button
	if button == 1 then
		titleIntro:start();
	end
end


return logoScreen;
