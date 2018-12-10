--[[
Versions 
7/11/2018 v0.9.2 Following on from issue 7 (scaling)
Added scalingBorder variables.  When borders have to be drawn around the screen - because the actual screen resolution is not a 16:9 ratio - these variables control the color and transparency.

7/11/2018 v0.9.1 Issue 7 scaling
Setting things up so that debug mode can have varying resolutions, but the original resolution in normal mode.

5/11/2018 v0.1 (prototyping)
Initial version


]]--


function love.conf(t)
	-- Set to true for debug values
	local debugging = true;
	
	-- Height and width
	if debugging then
		t.window.width = 1080;
		t.window.height = 540;
	else
		t.window.width = 640;
		t.window.height = 360;
	end
	
	-- Other window configuration
	t.window.fullScreen = false;
	t.window.title = "Jetpack Defender";
	
	-- Some custom config for the borders used when scaling/offsetting the screen
	-- Red, Green, Blue, and Transparency.
	scalingBorderR = 0;
	scalingBorderG = 0;
	scalingBorderB = 1;
	scalingBorderT = 0.5;

end
