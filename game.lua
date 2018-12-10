--[[
Versions 
10/11/2018 v1.0.2
Fixing up some comments.

21/11/2018 v1.0.1 Issue 17
Not enough enemies on screen during full invasion mode.    Have reduced the respawn time between enemies.

7/11/2018 v0.9.2 Issue 10
Fixing the wrapper around mousepressed.  It's now been moved to main.lua's love.mousepressed callback.
Mousepressed on the top part of the screen (the UI) pauses.
Minor fix: Removing controlBoost and controlShoot.  No longer needed, they're over in player.lua.
Minor fix: Editing a few comments for clarity.

7/11/2018 Issue 15
No real code change.
Have been doing further testing and investigating of issue 15, and been switching between the sound playback routines in killEnemy().  Memory usage is not an issue.  Have gone back to multiSoundPlay because it gives you slightly better control over the playback.

7/11/2018 v0.9.1 Issue 15
Minor 'fix'
Putting in a 'commented out' line from an earlier version.
In kill enemy, I have lines for multiSoundPlay and playSoundData.
Further testing and profiling is required on these two playback functions.
On the TAFE computer neither used up much extra space.
On my home computer, playSoundData did.  Will need to double check.

5/11/2018 v0.1.6 Issue 8 - Full Invasion Mode
Added full invasion mode

5/11/2018 v0.1.5 Issue 11 Small fixups to filedrop system
Needed to change the call to drawBGImage to drawDroppedImage

4/11/2018 v0.1.4
Minor update, making sure game:start() stops title music from playing.

4/11/2018 v0.1.3 Assets pass
Added assets
Removed a diagnosis message
Updated collision check to only check enemies against the player if the player is alive
Removing some commented-out code

3/11/2018 v0.1.2 Issue 3
Checking for escape key and going into pause mode in game.keypressed.  Previously it was in player.update and was
down with a keyboard.isDown.

3/11/2018 v0.1.1 (adding speedlines)

   
1/11/2018 v0.1 (prototyping / alpha)
For an example of just how fast love2d can make things, I started this at 5:28pm and got it a pretty good state by 10:00pm!
I still need to add assets though.

]]--

-- --------------------------------------------------------
-- Normal play state

game = {};

function game:start()
	-- Use to initialise values then change the state to 'game'
	
	-- Make sure to stop title music
	assets.titleMusic:stop();
	
	-- Set up the player
	player = spawners.player:new();

	-- enemies will be spawned by game:update, not here in start()
	game.maxEnemiesOnScreen = 5;
	game.numEnemiesOnScreen = 0;

	-- time between enemy respawns
	game.RegEnemyRespawnWait = 0.25;
	game.FIEnemyRespawnWait = 0.02;
	game.enemyRespawnWait = game.RegEnemyRespawnWait;
	game.enemyRespawnTimer = 0;
	enemies = {};
	
	-- speedline variables
	game.maxSpeedlinesOnScreen = 40;
	game.numSpeedlinesOnScreen = 0;	
	game.slRespawnWait = 0.02;
	game.slRespawnTimer = 0;
	speedlines = {};
	
	-- bullets are spawned by player:update
	game.maxBulletsOnScreen = 3;
	game.numBulletsOnScreen = 0;
	game.bulletsDelay = 0.25;
	game.bulletsDelayTimer = 0;
	bullets = {};

	-- score
	game.score = 0;
	game.scorePerEnemy = 100;
	game.FIscorePerEnemy = 1;
	
	-- Enemies that have gotten past you
	game.enemiesPastYou = 0;
	game.fullInvasionLimit = 3;
	game.fullInvasionMax = 50;
	game.fullInvasionMode = false;
	
	-- Invasion progress bar
	game.progressBar = {};
	game.progressBar.X = 5;
	game.progressBar.Y = 5;
	game.progressBar.W = lib.windowWidth - 10;
	game.progressBar.H = 20;
	game.actualWidth = 0;
	
	-- Update state to "game"
	state = self or game;
end

function game:update(dt)
	-- If player's alive, move things and check for collisions
	if player.alive then
	
		player:update(dt);
		game:updateEnemies(dt);
		game:updateBullets(dt);
		game:updateSpeedlines(dt);

		game.collisionCheck(dt);
	else
	
		-- Otherwise, change to the gameOver state.
		gameOver.start();
	end

end

-- --------------------------------------------------------
-- Enemies

function game:updateEnemies(dt)
	-- Updates all enemies on screen

	-- Decrease the respawn timer
	if game.enemyRespawnTimer > 0 then
		game.enemyRespawnTimer = game.enemyRespawnTimer - dt;
	end

	-- Spawn an enemy if the respawn timer has finished and we haven't reached the max number of enemies on screen
	if (game.numEnemiesOnScreen < game.maxEnemiesOnScreen) and
	   (game.enemyRespawnTimer <= 0) then
		game:spawnEnemy();
	end

	-- Update all enemies
	for key, value in pairs(enemies) do
		value:update(dt);
		
		-- If the enemy has gone past the left edge of the screen, despawn the enemy and increase the count
		-- of enemies that have gotten past the player.
		if value.x < 0 - value.w then
			game:killEnemy(key, value, false);
			game.enemiesPastYou = game.enemiesPastYou + 1;
			
			-- If too many enemies have gotten past the player, start Full Invasion mode.
			if game.enemiesPastYou >= game.fullInvasionLimit and game.fullInvasionMode == false then
				game:startFullInvasion();
			end
		end
	end

end

function game:spawnEnemy()
	-- Spawns a new enemy, and keeps track of a few numbers
	
	local enemy = spawners.enemy:new()
	table.insert(enemies, enemy);
	game.enemyRespawnTimer = game.enemyRespawnWait;
	game.numEnemiesOnScreen = game.numEnemiesOnScreen + 1;
end

function game:killEnemy(key, enemy, shot)
	-- Kills an enemy.  Designed to be called from inside a for loop:
	-- "for key, value in pairs(enemies) do"
	-- Like spawnEnemy, also keeps track of a few numbers.
	
	-- Parameters:
	--	key, enemy : the key and value from the for loop
	--  shot : Killing the enemy because it's been shot by the player

	table.remove(enemies, key);
	game.numEnemiesOnScreen = game.numEnemiesOnScreen - 1;
	game.enemyRespawnTimer = game.enemyRespawnWait;

	-- if the enemy has been shot then increase the score
	if shot then
		-- Update score
		game.score = game.score + game.scorePerEnemy;
		
		-- Explosion sound effect.  Randomised pitch.
		lib.multiSoundPlay(assets.explosion, true,0.7,1,0.1);
		--lib.playSoundData(assets.explosionEffect);
	end

	-- Could also call a theoretical enemy.kill() method.
	--Such a method has not been coded yet.
end

-- --------------------------------------------------------
-- Bullets

function game:updateBullets(dt)
	-- Updates all player bullets

	-- Decrease the delay timer
	if game.bulletsDelayTimer > 0 then
		game.bulletsDelayTimer = game.bulletsDelayTimer - dt;
	end
	
	-- Loop through all on screen bullets and call their update functions.
	for key, value in pairs(bullets) do
		value:update(dt);
		if value.x > lib.windowWidth + value.w then
			game:killBullet(key);
		end
	end

end

function game:spawnBullet()
	-- spawns a new player bullet, and keeps track of some numbers
		
	lib.multiSoundPlay(assets.shoot, false);
	local bullet = spawners.bullet:new();
	table.insert(bullets, bullet);
	game.bulletsDelayTimer = game.bulletsDelay;
	game.numBulletsOnScreen = game.numBulletsOnScreen + 1;
	
end

function game:killBullet(key)
	-- 'kills' a bullet.  Designed to be called from inside a for loop:
	-- "for key, value in pairs(bullets) do"
	-- the key value is passed to this function.
	-- Like spawnBullet, also keeps track of a few numbers.
	
	table.remove(bullets, key);
	game.numBulletsOnScreen = game.numBulletsOnScreen - 1;

end

-- --------------------------------------------------------
-- Speedlines

function game:updateSpeedlines(dt)
	-- Updates all speedlines on screen

	-- Decrease the respawn timer
	if game.slRespawnTimer > 0 then
		game.slRespawnTimer = game.slRespawnTimer - dt;
	end

	-- Spawn a speedline if the respawn timer has finished and we haven't reached the max number of speedlines on screen
	if (game.numSpeedlinesOnScreen < game.maxSpeedlinesOnScreen) and
	   (game.slRespawnTimer <= 0) then
		game:spawnSpeedline();
	end

	-- Update all speedlines
	for key, value in pairs(speedlines) do
		value:update(dt);
		if value.x < 0 - value.w then
			game:killSpeedline(key, value);
		end
	end

end

function game:spawnSpeedline()
	-- Spawns a new speedline, and keeps track of a few numbers
	local speedline = spawners.speedline:new()
	table.insert(speedlines, speedline);
	game.slRespawnTimer = game.slRespawnWait;
	game.numSpeedlinesOnScreen = game.numSpeedlinesOnScreen + 1;
end

function game:killSpeedline(key, speedline)
	
	-- Parameters:
	--	key, speedline : the key and value from the for loop

	table.remove(speedlines, key);
	game.numSpeedlinesOnScreen = game.numSpeedlinesOnScreen - 1;
	game.slRespawnTimer = game.slRespawnWait;

end






function game.collisionCheck(dt)
	-- Not sure if I'll use dt but including it here anyway

	-- Loop through all enemies
	for enemyKey, enemyValue in pairs(enemies) do

		-- check enemy against player
		if lib.CheckCollision(player,enemyValue) and player.alive then
			player:kill();
			game:killEnemy(enemyKey, enemyValue, false);
			lib.multiSoundPlay(assets.explosion, false);
		end
		
		-- check the enemy against all bullets
		for bulletKey,bulletValue in pairs(bullets) do
			if lib.CheckCollision(enemyValue, bulletValue) then
				game:killEnemy(enemyKey, enemyValue, true);
				game:killBullet(bulletKey);
				
			end
			
		end
	end

	
end

function game:draw()
	-- Background image
	drawDroppedImage(1);
	
	-- Speedlines
	for key, value in pairs(speedlines) do
		value:draw();
	end

	-- Player
	if player.alive then
		player:draw();
	end
	
	-- Bullets
	for key, value in pairs(bullets) do
		value:draw();
	end

	-- Enemies
	for key, value in pairs(enemies) do
		value:draw();
	end

	-- If full invasion mode, then a slight red tinge over everything
	if game.fullInvasionMode then
		g.setColor(1,0,0,0.2);
		g.rectangle("fill", 0, 0, lib.windowWidth, lib.windowHeight);
	end

	-- Draw the UI (progress bar and score)
	game:drawUI();
	
end


function game:drawUI()
	-- Draw the UI (progress bar and score)

	-- Score
	g.setColor(1,1,1,1);
	local message = "Score: %08s";
	g.print(message:format(game.score), 5, 30);
	
	-- Invasion progress bar
	game.progressBar.actualWidth = 1;
	if game.enemiesPastYou < game.fullInvasionLimit then
		game.progressBar.actualWidth = game.enemiesPastYou / game.fullInvasionLimit;
	end

	-- Outline
	g.setColor(1,1,1,1);
	g.rectangle("line", game.progressBar.X - 2, game.progressBar.Y - 2, game.progressBar.W+4, game.progressBar.H+4);

	-- Progress bar itself
	g.setColor(1,0,0,0.5);
	g.rectangle("fill", game.progressBar.X,
	                    game.progressBar.Y,
						game.progressBar.W * game.progressBar.actualWidth,
						game.progressBar.H);

	-- And text on top of the progress bar
	g.setColor(1,1,1,1);
	if game.enemiesPastYou < game.fullInvasionLimit then
		g.print("Invasion progress", game.progressBar.X + 5, game.progressBar.Y + 2);
	else
		g.printf("FULL INVASION FULL INVASION FULL INVASION", 0, game.progressBar.Y+2, lib.windowWidth, "center");
		
	end
end

-- Used to start full invasion mode
function game:startFullInvasion()
	game.fullInvasionMode = true;
	game.maxEnemiesOnScreen = game.fullInvasionMax;
	game.scorePerEnemy = game.FIscorePerEnemy;
	game.enemyRespawnWait = game.FIEnemyRespawnWait;
end

-- This keypressed callback really only looks for a press of the escape key, used to start pause mode.
-- Keypressed is used instead of keyboard.isDown because we want a keypress and release to pause the game.
function game:keypressed(key, scancode, isrepeat)

	if key == "escape" then
		pause.start();
	end


end

-- Similarly, mousepressed is used to look for a press of the mouse button on the top of the screen,
-- used to start pause mode.
function game:mousepressed(x, y, button, istouch, presses)
	
	if button == 1 and y < 40 then
		pause.start();
	end
	
end


return game;