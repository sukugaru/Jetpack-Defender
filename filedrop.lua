--[[
Versions 
5/11/2018 v0.1.1 Issue 11 Reducing coupling
It required LoadedImage to be a global variable
Also, moved global variables from love.load to here
   
1/11/2018 v0.1 (prototyping / alpha)
Grabbed my filedrop code and dropped it in here in the form of a library.
]]--


-- love.fileDropped(file) is a lua callback, that gets executed whenever a file is drag-and-dropped onto
-- the game window.
function love.filedropped(file)

	imageLoadAttempted = true;

	-- Note to self: file.getFilename() needs to pass in the file again
	-- OR you can use the : operator to pass the variable in as self.
	local fname = file:getFilename();
	

	-- Load the image, with exception handling.  Lua exception handling is different to try catch blocks.
	-- The function has to be called with pcall.  The syntax is like this:
	-- ok, returnvalues = pcall(function name, parameter)
	-- Inside the function, it has to do "if unexpected_condition then error" at the beginning.
	local ok;
	local img = nil;
	ok, img = pcall(loadImageFromPath, fname);

	-- Display an error to the console if it didn't work.
	-- love.draw will display an error to the game window by referring to imageLoadError.
	if not ok then
		imageLoadError = true;
		print("An error happened when loading the image. " .. tostring(loadedImage));
		
	-- If it did work, put the image into loadedImage and calculate its display variables.
	else
		imageLoadError = false;
		loadedImage.image = img;
		calculateImageValues();
		timer = 1;
		
	end
end



-- Following are variables used for image filedrop system
imageValid = true;
imageLoadAttempted = false;

loadedImage = {
	image = nil,
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	hs = 1, -- horizontal scaling
	vs = 1, -- vertical scaling
};


-- This next function is from https://love2d.org/forums/viewtopic.php?t=85350,
-- but with added exception handling.
--
-- The basic problem is:
--    - when a user drops an image onto the game window, the dropped file has an absolute pathname
--    - However, love's newImage constructor expects a relative pathname.
--
-- This function takes that absolute pathname and loads it as an image.
-- OR if there's a problem it errors.
--
-- For proper error handling, make sure to call the function like this:
--    ok, image = pcall(loadImageFromPath, filename)
--
--    ok:       a boolean - if false then there was an error
--    image:    an image object to put the loaded image into
--    filename: the filename of the image to load

function loadImageFromPath(filePath)

	-- Thix next line is for Lua exception handling, in case the file is corrupted or is not
	--	in a supported image format.
	if unexpected_condition then error() end
	
	-- "r" means "read" and "b" means binary
	-- io.open is happy enough with the absolute filepath.
	local f = io.open( filePath, "rb" )

	-- if the file is openable, then read it, and attempt to parse it as an image.
    if f then
        local data = f:read( "*all" )
        f:close()
        if data then
            data = love.filesystem.newFileData( data, "tempname" )
            data = love.image.newImageData( data )
            local image = g.newImage( data )
            return image
        end
    end

end


-- Calculate some things for the display of loadedImage.
-- We need to get X position, Y position, and if the image needs to be shrunk to be displayed.
function calculateImageValues()
	loadedImage.w = loadedImage.image:getWidth();
	loadedImage.h = loadedImage.image:getHeight();
	
	-- Figure out horizontal scaling and vertical scaling separately
	loadedImage.hs = 1;
	if loadedImage.w > lib.windowWidth then
		loadedImage.hs = lib.windowWidth / loadedImage.w;
	end

	loadedImage.vs = 1;
	if loadedImage.h > lib.windowHeight then
		loadedImage.vs = lib.windowHeight / loadedImage.h;
	end
	
	-- Set overall scaling to the lower of the two scaling figures
	local loadedImageScaling = 1;
	
	if loadedImage.vs ~= loadedImage.hs then
		loadedImageScaling = math.min(loadedImage.vs, loadedImage.hs);
	end

	loadedImage.hs = loadedImageScaling;
	loadedImage.vs = loadedImageScaling;
	
	-- With image scaling sorted out, figure out the image's position
	loadedImage.x = 0;
	if loadedImage.hs < 1 or loadedImage.w < lib.windowWidth then
		loadedImage.x = (lib.windowWidth * 0.5) - (loadedImage.w * loadedImage.hs * 0.5)
	end

	loadedImage.y = 0;
	if loadedImage.vs < 1 or loadedImage.h < lib.windowHeight then
		loadedImage.y = (lib.windowHeight * 0.5) - (loadedImage.h * loadedImage.vs * 0.5)
	end
end


-- The following draws the dropped image with the specified transparency
function drawDroppedImage(transparency)
	if imageLoadAttempted and imageLoadError == false then
		g.setColor(1,1,1,transparency);
		g.draw(loadedImage.image, loadedImage.x, loadedImage.y, 0, loadedImage.hs, loadedImage.vs, 0, 0, 0, 0);		
	end
end
