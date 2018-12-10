--[[
Versions 
10/12/2018 v1.0.0
Minor fixes to comments

7/11/2018 v0.9.2 Minor fix
Minor fix to draw() so that the big red box starts from 0,0, not 1,1.

7/11/2018 v0.9.1 Issues 13 and 5
Making sure to go to logoscreen rather than titlescreen

5/11/2018 v0.1.3 Issue 12 - highscores
making sure to save the player's score on gameOver
Removing some unnecessary commented out bits

4/11/2018 v0.1.2 Small issue fix
Removed a diagnosis message that displayed the value of the transparency value

3/11/2018 v0.1.1 Issue #1
Speedlines stopped dead during gameOver sequence.  Adding them to gameOver.update.
   
1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.

]]--


-- --------------------------------------------------------
-- Game Over state

gameOver = {};

highscoreTable = "";

function gameOver:start()
	-- Start a timer; used to calculate transparency effects
	gameOver.timer = 0;
	
	-- Put the player's score into highscores
	table.insert(highscores, game.score)
	
	-- save the high scores
	gameOver.saveHighScores();

	-- Update state to "game over"
	state = self or gameOver;
end

-- Save highscores to a file
function gameOver.saveHighScores()
	local scores = "";
	for k, v in pairs(highscores) do
		scores = scores .. v .. "\r\n";
	end
	
	love.filesystem.write("highscores.dat", scores);
end


function gameOver:update(dt)
	-- update the state's timer
	gameOver.timer = gameOver.timer + dt;

	-- Let enemies and player bullets keep moving and collide	
	game:updateEnemies(dt);
	game:updateBullets(dt);
	game:collisionCheck(dt);
	
	-- Issue #1 Should speedlines keep moving?  They stop dead and it looks odd.
	-- Update: Have decided to let them keep moving.  Looks better that way.
	game:updateSpeedlines(dt);
end

function gameOver:draw()
	-- Use game:draw() to keep drawing all the game elements
	game:draw();
	
	
	-- Fade to red in the first 3 seconds of the state
	
	-- Determine transparency
	local tr = 1;
	if gameOver.timer < 3 then
		tr = gameOver.timer / 3;
	end

	-- Draw giant red box with the transparency value
	g.setColor(1,0,0,tr);
	g.rectangle("fill",0,0,lib.windowWidth, lib.windowHeight);
	
	-- Game over message
	if gameOver.timer < 3 then
		lib.centerMessage("OH NO!  You hit something and died!");
	else
		lib.centerMessage("GAME OVER", "Press space to continue.");
	end

	
end

function gameOver:keypressed(key, scancode, isrepeat)
	if key == "space" and gameOver.timer >= 3 then
		logoScreen:start();
	end
end

return gameOver;