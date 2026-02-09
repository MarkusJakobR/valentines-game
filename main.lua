-- Game state
local score = 0
local gameOver = false
local showingChoice = false
local targets = {}
local maxTargets = 5
local targetSize = 30

local cameraX = 0
local cameraY = 0

-- World bounds based on screen size only
local screenWidth = 800
local screenHeight = 600
local cameraRange = 400 -- How far camera can move from origin
local worldWidth = screenWidth + (cameraRange * 2)
local worldHeight = screenHeight + (cameraRange * 2)

-- Message to reveal
local message = "WILL YOU BE MY VALENTINE?"
local revealedLetters = 0

local yesButton = nil
local noButton = nil

local celebrationFrames = {}
local currentFrame = 1
local frameTimer = 0
local frameDelay = 0.1

local secondImage = nil
local showSecondImage = false
local gameOverTimer = 0
local secondImageDelay = 5

local shootSound = nil
local killSounds = {}
local currentKillSound = 1
local bgMusic = nil
local winMusic = nil

function love.load()
	-- Window setup
	love.window.setTitle("Aim Trainer")
	love.window.setMode(screenWidth, screenHeight)
	love.mouse.setVisible(false)
	love.mouse.setGrabbed(true)
	love.mouse.setRelativeMode(true)

	-- Load celebration GIF frames
	-- Change the number based on how many frames you have
	for i = 1, 14 do -- If you have 10 frames
		local frame = love.graphics.newImage("images/hachiware_gif/frame_" .. i .. " 2.png")
		table.insert(celebrationFrames, frame)
	end

	secondImage = love.graphics.newImage("images/em_tulips.png")

	shootSound = love.audio.newSource("sounds/gunshot.mp3", "static")
	shootSound:setVolume(0.3)

	for i = 1, 5 do
		killSounds[i] = love.audio.newSource("sounds/kill_" .. i .. ".mp3", "static")
	end

	-- Spawn initial targets
	for i = 1, maxTargets do
		spawnTarget()
	end
end

function spawnTarget()
	-- Spawn only in reachable area
	-- Reachable X: 0 to (worldWidth - screenWidth) + screenWidth = worldWidth
	-- But crosshair reaches: cameraMin + screenCenter to cameraMax + screenCenter
	local minX = screenWidth / 2 -- When camera is at 0
	local maxX = (worldWidth - screenWidth) + screenWidth / 2 -- When camera is at max
	local minY = screenHeight / 2
	local maxY = (worldHeight - screenHeight) + screenHeight / 2

	local target = {
		x = math.random(minX, maxX),
		y = math.random(minY, maxY),
		vx = math.random(-100, 100),
		vy = math.random(-100, 100),
		size = targetSize,
	}
	table.insert(targets, target)
end

function createChoiceButtons()
	-- Create YES and NO buttons in reachable area
	local minX = screenWidth / 2
	local maxX = (worldWidth - screenWidth) + screenWidth / 2
	local minY = screenHeight / 2
	local maxY = (worldHeight - screenHeight) + screenHeight / 2

	local centerX = (minX + maxX) / 2
	local centerY = (minY + maxY) / 2

	yesButton = {
		x = centerX - 150,
		y = centerY,
		size = 80,
		text = "YES",
		vx = math.random(-80, 80), -- Random velocity!
		vy = math.random(-80, 80),
	}

	noButton = {
		x = centerX + 150,
		y = centerY,
		size = 80,
		text = "NO",
		vx = math.random(-120, 120), -- Faster movement (harder to hit)
		vy = math.random(-120, 120),
	}
end

function love.update(dt)
	if gameOver then
		gameOverTimer = gameOverTimer + dt

		-- Check if we should show second image
		if gameOverTimer >= secondImageDelay then
			showSecondImage = true
		end

		-- Animate the celebration GIF
		frameTimer = frameTimer + dt
		if frameTimer >= frameDelay then
			frameTimer = 0
			currentFrame = currentFrame + 1
			if currentFrame > #celebrationFrames then
				currentFrame = 1 -- Loop the animation
			end
		end
		return
	end

	if showingChoice then
		-- Move YES and NO buttons
		yesButton.x = yesButton.x + yesButton.vx * dt
		yesButton.y = yesButton.y + yesButton.vy * dt

		noButton.x = noButton.x + noButton.vx * dt
		noButton.y = noButton.y + noButton.vy * dt

		-- Bounce off reachable bounds
		local minX = screenWidth / 2
		local maxX = (worldWidth - screenWidth) + screenWidth / 2
		local minY = screenHeight / 2
		local maxY = (worldHeight - screenHeight) + screenHeight / 2

		-- YES button bounce
		if yesButton.x <= minX or yesButton.x >= maxX then
			yesButton.vx = -yesButton.vx
			yesButton.x = math.max(minX, math.min(yesButton.x, maxX))
		end
		if yesButton.y <= minY or yesButton.y >= maxY then
			yesButton.vy = -yesButton.vy
			yesButton.y = math.max(minY, math.min(yesButton.y, maxY))
		end

		-- NO button bounce
		if noButton.x <= minX or noButton.x >= maxX then
			noButton.vx = -noButton.vx
			noButton.x = math.max(minX, math.min(noButton.x, maxX))
		end
		if noButton.y <= minY or noButton.y >= maxY then
			noButton.vy = -noButton.vy
			noButton.y = math.max(minY, math.min(noButton.y, maxY))
		end

		return
	end

	-- Move targets
	for i, target in ipairs(targets) do
		target.x = target.x + target.vx * dt
		target.y = target.y + target.vy * dt

		-- Bounce off reachable bounds (not world bounds)
		local minX = screenWidth / 2
		local maxX = (worldWidth - screenWidth) + screenWidth / 2
		local minY = screenHeight / 2
		local maxY = (worldHeight - screenHeight) + screenHeight / 2

		if target.x <= minX or target.x >= maxX then
			target.vx = -target.vx
			target.x = math.max(minX, math.min(target.x, maxX))
		end
		if target.y <= minY or target.y >= maxY then
			target.vy = -target.vy
			target.y = math.max(minY, math.min(target.y, maxY))
		end
	end
end

function love.mousemoved(x, y, dx, dy)
	if gameOver then
		return
	end

	-- Use dx/dy (delta mouse movement) to move camera
	cameraX = cameraX + dx * 1.5 -- Multiply for sensitivity
	cameraY = cameraY + dy * 1.5

	-- Clamp camera to world bounds
	cameraX = math.max(0, math.min(cameraX, worldWidth - screenWidth))
	cameraY = math.max(0, math.min(cameraY, worldHeight - screenHeight))
end

function love.draw()
	-- Background
	love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

	if gameOver then
		if showSecondImage then
			-- Draw second image (replace the GIF)
			love.graphics.setColor(1, 1, 1)
			local x = (screenWidth - secondImage:getWidth()) / 2
			local y = (screenHeight - secondImage:getHeight()) / 2
			love.graphics.draw(secondImage, x, y)
		else
			if #celebrationFrames > 0 then
				local gif = celebrationFrames[currentFrame]
				-- Center the image
				local x = (screenWidth - gif:getWidth()) / 2
				local y = (screenHeight - gif:getHeight()) / 2
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(gif, x, y)
			end
		end
		-- Draw the celebration GIF
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("My pookie said yes!!!", 0, 500, screenWidth, "center")
	else
		love.graphics.push()

		love.graphics.translate(-cameraX, -cameraY)

		love.graphics.setColor(0.2, 0.2, 0.25)
		for x = 0, worldWidth, 50 do
			love.graphics.line(x, 0, x, worldHeight)
		end
		for y = 0, worldHeight, 50 do
			love.graphics.line(0, y, worldWidth, y)
		end

		-- Draw reachable boundary (where crosshair can actually reach)
		local minX = screenWidth / 2
		local maxX = (worldWidth - screenWidth) + screenWidth / 2
		local minY = screenHeight / 2
		local maxY = (worldHeight - screenHeight) + screenHeight / 2

		love.graphics.setColor(0, 1, 0) -- Green = reachable zone
		love.graphics.rectangle("line", minX, minY, maxX - minX, maxY - minY)

		if showingChoice then
			-- Draw YES/NO buttons
			local font = love.graphics.newFont(32)
			love.graphics.setFont(font)

			-- YES button (green)
			love.graphics.setColor(0.2, 0.8, 0.3)
			love.graphics.circle("fill", yesButton.x, yesButton.y, yesButton.size)
			love.graphics.setColor(1, 1, 1)
			local yesWidth = font:getWidth(yesButton.text)
			love.graphics.print(yesButton.text, yesButton.x - yesWidth / 2, yesButton.y - 16)

			-- NO button (red)
			love.graphics.setColor(0.8, 0.2, 0.2)
			love.graphics.circle("fill", noButton.x, noButton.y, noButton.size)
			love.graphics.setColor(1, 1, 1)
			local noWidth = font:getWidth(noButton.text)
			love.graphics.print(noButton.text, noButton.x - noWidth / 2, noButton.y - 16)
		else
			-- Draw targets (hearts)
			for i, target in ipairs(targets) do
				love.graphics.setColor(1, 0.2, 0.4)
				love.graphics.circle("fill", target.x, target.y, target.size)
				love.graphics.setColor(1, 0, 0.3)
				love.graphics.circle("fill", target.x - 10, target.y - 5, 15)
				love.graphics.circle("fill", target.x + 10, target.y - 5, 15)
			end
		end

		love.graphics.pop()

		-- Draw revealed message at the top
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(love.graphics.newFont(32))

		-- Show revealed portion of message
		local revealed = string.sub(message, 1, revealedLetters)
		local remaining = string.sub(message, revealedLetters + 1)

		-- Center the text
		local fullWidth = love.graphics.getFont():getWidth(message)
		local startX = (screenWidth - fullWidth) / 2

		-- Draw revealed letters (white)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(revealed, startX, 50)

		-- Draw remaining letters (dark/hidden)
		local revealedWidth = love.graphics.getFont():getWidth(revealed)
		love.graphics.setColor(1, 1, 1, 0)
		love.graphics.print(remaining, startX + revealedWidth, 50)

		-- Reset font for other UI
		love.graphics.setFont(love.graphics.newFont(12))

		-- Draw score
		if not showingChoice then
			love.graphics.setColor(1, 1, 1)
			love.graphics.print("Score: " .. score .. " / " .. string.len(message), 10, 10)
			love.graphics.print("Move mouse to aim", 10, 30)
		else
			love.graphics.setColor(1, 1, 1)
			love.graphics.print("Shoot your answer!", 10, 10)
		end

		-- Draw crosshair
		local centerX = screenWidth / 2
		local centerY = screenHeight / 2
		love.graphics.setColor(1, 1, 1)
		love.graphics.setLineWidth(2)
		love.graphics.line(centerX - 15, centerY, centerX + 15, centerY)
		love.graphics.line(centerX, centerY - 15, centerX, centerY + 15)
		love.graphics.circle("fill", centerX, centerY, 2)
	end
end

function love.mousepressed(x, y, button)
	if gameOver then
		return
	end
	if button ~= 1 then
		return
	end

	shootSound:stop()
	shootSound:play()

	-- Crosshair is always at screen center
	local centerX = screenWidth / 2
	local centerY = screenHeight / 2

	-- Convert to world coordinates
	local worldX = centerX + cameraX
	local worldY = centerY + cameraY

	-- Check if we hit any target
	if showingChoice then
		-- Check if YES or NO was hit
		local yesDistance = math.sqrt((worldX - yesButton.x) ^ 2 + (worldY - yesButton.y) ^ 2)
		local noDistance = math.sqrt((worldX - noButton.x) ^ 2 + (worldY - noButton.y) ^ 2)

		if yesDistance < yesButton.size then
			killSounds[5]:play()

			gameOver = true
			return
		elseif noDistance < noButton.size then
			-- Make NO button run away or do something funny
			love.window.showMessageBox("Oops!", "Wrong button! Try again 😊", "info")
			return
		end
	else
		-- Check if we hit any target
		for i = #targets, 1, -1 do
			local target = targets[i]
			local distance = math.sqrt((worldX - target.x) ^ 2 + (worldY - target.y) ^ 2)

			if distance < target.size then
				killSounds[currentKillSound]:stop()
				killSounds[currentKillSound]:play()

				currentKillSound = currentKillSound + 1
				if currentKillSound > 5 then
					currentKillSound = 1 -- Reset to 1 after 5
				end

				table.remove(targets, i)
				score = score + 1
				revealedLetters = revealedLetters + 1 -- Reveal next letter!

				-- Check if message is complete
				if revealedLetters >= string.len(message) then
					showingChoice = true
					targets = {} -- Clear all targets
					createChoiceButtons()
					return
				end

				spawnTarget()
				break
			end
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		love.event.quit()
	end
end
