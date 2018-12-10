--[[
Versions

10/12/2018 v1.0.2
Minor updates to comments and removed some commented-out code.

21/11/2018 v1.0.1 Issue 18
Adding sound config option

7/11/2018 v0.9.3 Issue 10
Fixing the wrapper around mousepressed.  It's now been moved to main.lua's love.mousepressed callback.
Minor fix: Put lowclick into keypressed.
Minor fix: Removed some debug messages.

7/11/2018 v0.9.2 Issue 7 scaling
Mouse input needs to be adjusted in case the screen is being scaled and/or offset.

7/11/2018 v0.9.1 Issues 13 and 5
Splitting the title screen into multiple states - logoScreen, titleIntro, this, and highscoreScreen.
This also makes skipping between the parts of the titlescreen on spacebar or mousepress a lot easier.

5/11/2018 v0.1.5 Issue 8
Discovered a bug where if you click on the start button the game goes to game:start instead of levelIntro:start.
Fixed this.

5/11/2018 v0.1.4 Issue 4
Introducing a level intro - "Get ready!"
So start the game with levelIntro:start() rather than game:start()

5/11/2018 v0.1.3 Issue 12
Putting highscores in.
During start() a string for the high score table is generated.  It is later displayed in draw().

4/11/2018 v0.1.2 Testing background music
Using an old bit of music to test out the playing of music.  It starts playing in titleScreen:start() and is stopped
in game:start().

4/11/2018 v0.1.1 Assets pass
Have added a background image for the title (the most generic space background ever), and images for buttons
Added clickable buttons
Removed a diagnosis message
   
1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.

]]--

-- --------------------------------------------------------
-- Title Screen state

titleScreen = {};

titleScreen.entities = {};
titleScreen.entities.start = { x = 0, y = 0, w = assets.startButton:getWidth(), h = assets.startButton:getHeight()  };
titleScreen.entities.quit = { x = 0, y = 0, w = assets.quitButton:getWidth(), h = assets.quitButton:getHeight() };
titleScreen.entities.sound = { x = 0, y = 0, w = assets.soundOn:getWidth(), h = assets.soundOn:getHeight() };

titleScreen.highscoreTable = "";
titleScreen.sound = true;

function titleScreen:start()
	-- Use to initialise values then change the state to 'game'
	titleScreen.timer = 0;
	
	-- Initialise positions of buttons
	titleScreen.entities.start.x = (lib.windowWidth - titleScreen.entities.start.w) / 2;
	titleScreen.entities.start.y = (lib.windowHeight/2);

	titleScreen.entities.sound.x = (lib.windowWidth - titleScreen.entities.sound.w) / 2;
	titleScreen.entities.sound.y = titleScreen.entities.start.y + titleScreen.entities.start.h + 5;

	titleScreen.entities.quit.x = (lib.windowWidth - titleScreen.entities.quit.w) / 2;
	titleScreen.entities.quit.y = titleScreen.entities.sound.y + titleScreen.entities.sound.h + 5;
	
	
	-- Update state
	state = self or titleScreen;
end

function titleScreen:update(dt)
	-- Change to high scores after 10 seconds
	titleScreen.timer = titleScreen.timer + dt;
	
	if titleScreen.timer > 10 then
		highscoreScreen:start();
	end
end

function titleScreen:draw()

	-- Local variables used in various transparency and special effects
	local t;
	local tr = 0;

	-- Draw the background for everything other than the Logo screen
	g.setColor(1,1,1,1);
	g.draw(assets.titleBG,0,0);

	-- Main title screen
	if  titleScreen.timer >= 0 and titleScreen.timer < 10 then
		g.setColor(1,1,1);
		g.printf("JETPACK DEFENDER", 0, lib.windowHeight/3, lib.windowWidth, "center");

		-- Make the start and quit buttons glow a little
		-- tr = 0.5 to 1 from t = 0 to 0.4
		-- tr = 1 to 0.5 from t = 0.6 to 1

		t = math.mod(titleScreen.timer,1);
		if t > 0.6 then
			tr = 1 - ((t - 0.6) / 0.4 * 0.5);
		elseif t < 0.4 then
			tr = 0.5 + (t / 0.4 * 0.5);		
		else
			tr = 1;
		end

		
		g.setColor(1,1,1,tr);
		g.draw(assets.startButton, titleScreen.entities.start.x, titleScreen.entities.start.y);
		if (titleScreen.sound) then
			g.draw(assets.soundOn, titleScreen.entities.sound.x, titleScreen.entities.sound.y);
		else
			g.draw(assets.soundOff, titleScreen.entities.sound.x, titleScreen.entities.sound.y);
		end
		g.draw(assets.quitButton, titleScreen.entities.quit.x, titleScreen.entities.quit.y);
		
	end
	
end

function titleScreen:keypressed(key, scancode, isrepeat)

	-- Start the game
	if key == "space" then
		assets.lowclick:play();
		levelIntro:start();
	end
end



function titleScreen:mousepressed(x, y, button, istouch, presses)
	
	if button == 1 then
		-- Setting up the click as an entity for easier collision checking later
		titleScreen.click = {};
		titleScreen.click.w = 1;
		titleScreen.click.h = 1;
		titleScreen.click.x = x - (titleScreen.click.w / 2);
		titleScreen.click.y = y - (titleScreen.click.h / 2);	

		-- Start button
		if lib.CheckCollision(titleScreen.click, titleScreen.entities.start) then
			assets.lowclick:play();
			levelIntro:start();
		end

		-- Sound button
		if lib.CheckCollision(titleScreen.click, titleScreen.entities.sound) then
			titleScreen.sound = not titleScreen.sound;

			-- Set sound to off or on
			if titleScreen.sound then
				love.audio.setVolume(1);
			else
				love.audio.setVolume(0);
			end
			
			-- Reset timer to zero
			titleScreen.timer = 0;
		end
		
		-- Quit button
		if lib.CheckCollision(titleScreen.click, titleScreen.entities.quit) then
			assets.lowclick:play();
			love.event.quit();
		end	
	end
	
end

return titleScreen;

