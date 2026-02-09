-- Game state
local score = 0
local gameOver = false
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

function love.load()
	-- Window setup
	love.window.setTitle("Valentine Shooter 💘")
	love.window.setMode(screenWidth, screenHeight)
	love.mouse.setVisible(false)
	love.mouse.setGrabbed(true)
	love.mouse.setRelativeMode(true)

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

function love.update(dt)
	if gameOver then
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
		-- Victory screen
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("🎉 YOU WIN! 🎉", 0, 200, screenWidth, "center")
		love.graphics.printf("Will you be my Valentine? 💝", 0, 250, screenWidth, "center")
		love.graphics.printf("Score: " .. score, 0, 300, screenWidth, "center")
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

		-- Draw targets (hearts)
		for i, target in ipairs(targets) do
			love.graphics.setColor(1, 0.2, 0.4)
			love.graphics.circle("fill", target.x, target.y, target.size)
			love.graphics.setColor(1, 0, 0.3)
			love.graphics.circle("fill", target.x - 10, target.y - 5, 15)
			love.graphics.circle("fill", target.x + 10, target.y - 5, 15)
		end

		love.graphics.pop()

		-- Draw score
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("Score: " .. score .. " / 20", 10, 10)
		love.graphics.print("Move mouse to aim", 10, 30)

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

	-- Crosshair is always at screen center
	local centerX = screenWidth / 2
	local centerY = screenHeight / 2

	-- Convert to world coordinates
	local worldX = centerX + cameraX
	local worldY = centerY + cameraY

	-- Check if we hit any target
	for i = #targets, 1, -1 do
		local target = targets[i]
		local distance = math.sqrt((worldX - target.x) ^ 2 + (worldY - target.y) ^ 2)

		if distance < target.size then
			table.remove(targets, i)
			score = score + 1

			if score >= 20 then
				gameOver = true
				return
			end

			spawnTarget()
			break
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
