--[[
Assets file

Versions 

21/11/2018 v1.0.1 Issue 18
Adding sound config option
This requires two images

7/11/2018 v0.9.2 Issue 6
Moved all asset files to an assets subfolder, for slightly better organisation.

7/11/2018 v0.9.1 Issue 16
Changed the title track to "stream" and it worked fine!  Will need to check this change at home because I thought it
didn't work earlier?

4/11/2018 v0.1.1 
Brought in an old music track I did (from 1994!)

4/11/2018 v0.1 Assets pass
Have added images for the player, the player bullet, enemies, a title background screen, and start and quit buttons
Have added some sound effects too
]]--

assets = {};

assets.player = love.graphics.newImage("assets/jetpack.png");
assets.bullet = love.graphics.newImage("assets/bullet.png");
assets.enemy = love.graphics.newImage("assets/enemy.png");

assets.titleBG = love.graphics.newImage("assets/titleBG.jpg");
assets.startButton = love.graphics.newImage("assets/startSelect.png");
assets.quitButton = love.graphics.newImage("assets/quitSelect.png");
assets.soundOn = love.graphics.newImage("assets/sound on.png");
assets.soundOff = love.graphics.newImage("assets/sound off.png");


assets.shoot = love.audio.newSource("assets/shoot.wav", "static");
assets.explosion = love.audio.newSource("assets/explosion.wav", "static");
assets.lowclick = love.audio.newSource("assets/click.wav", "static");

assets.explosionEffect = love.sound.newSoundData("assets/explosion.wav");

assets.titleMusic = love.audio.newSource("assets/testTitleMusic.mp3", "stream");
assets.titleMusic:setLooping(true);

