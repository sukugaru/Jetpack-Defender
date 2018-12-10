--[[

How high scores work:
 - In love.load, highscores is set to an empty table.
 - When the game is over, the player's score is saved to the highscores table, and the highscores table is then saved to a file.
 - In this state (highscoreScreen), the file is read and a string is determined, that holds the top ten scores

This is not very sophisticated but fulfils the assignment requirement to persist data in an external file. 
 
This state (highscoreScreen) 

Versions 
10/12/2018 v1.0.0
Fixing up comments and adding some extra comments so that this all makes sense.  The way highscores work is a little
weird, and it was done to demonstrate the use of external files.

7/11/2018 v0.9
First version
Created from titleScreen.lua (v0.1.5)

]]--

-- --------------------------------------------------------
-- Title Screen state

highscoreScreen = {};

highscoreScreen.highscoreTable = "";

function highscoreScreen:start()
	-- Use to initialise values then change the state to 'high scores'
	
	highscoreScreen.timer = 0;

	-- Figure out what to display!
	calculateHighScores();
	
	-- Update state
	state = self or highscoreScreen;
	
end

function highscoreScreen:update(dt)

	-- After 5 seconds, go back to the scrolling text (the 'titleIntro' state)
	
	highscoreScreen.timer = highscoreScreen.timer + dt;
	
	if highscoreScreen.timer > 5 then
		titleIntro:start();
	end
end

function highscoreScreen:draw()

	-- Local variables used in various transparency and special effects
	local t;
	local tr = 0;

	-- Draw the background for everything other than the Logo screen
	g.setColor(1,1,1,1);
	g.draw(assets.titleBG,0,0);

	-- High scores
	g.setColor(1,1,1);
	g.printf("High Scores", 0, lib.windowHeight/4, lib.windowWidth, "center");
	g.printf(highscoreScreen.highscoreTable, 0, lib.windowHeight/3, lib.windowWidth, "center");
		
	
end

function highscoreScreen:keypressed(key, scancode, isrepeat)
	-- Go to main screen when space pressed
	if key == "space" then
		titleScreen:start();
	end
end


function highscoreScreen:mousepressed(x, y, button, istouch, presses)

	-- Go to main screen when LMB pressed
	if button == 1 then
		titleScreen:start();
	end
end

-- This takes the highscore table and writes it to the highScoreTable string
-- This is so it can be displayed later
function calculateHighScores()
	-- Sort and create the highscore table
	table.sort(highscores, sortAscending);
	local msg = "";
	local template = "%s%s: %.4f\n";
	
	for key, value in pairs(highscores) do
		msg = template:format(msg, key, value);
		if key == 10 then break end
	end

	-- Set the string highscoreTable to what was just created
	highscoreScreen.highscoreTable = msg;
end

-- Used when sorting high scores
function sortAscending(one, two)
	return one > two;
end


return highscoreScreen;

