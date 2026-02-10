local State = require("game.state")
local Sounds = require("game.sounds")
local Images = require("game.images")
local Targets = require("game.targets")
local Buttons = require("game.buttons")

function love.load()
	love.window.setTitle("Aim Trainer")
	love.window.setMode(State.screenWidth, State.screenHeight)
	love.mouse.setVisible(false)
	love.mouse.setGrabbed(true)
	love.mouse.setRelativeMode(true)

	-- Load resources
	Sounds.load()
	Images.load()

	-- Spawn initial targets
	for i = 1, Targets.maxTargets do
		Targets.spawn(State)
	end
end

function love.update(dt)
	if State.gameOver then
		Sounds.playWin()
		State.gameOverTimer = State.gameOverTimer + dt

		if State.gameOverTimer >= State.secondImageDelay then
			State.showSecondImage = true
			Sounds.playSecond()
		end

		State.frameTimer = State.frameTimer + dt
		if State.frameTimer >= State.frameDelay then
			State.frameTimer = 0
			State.currentFrame = State.currentFrame + 1
			if State.currentFrame > #Images.celebrationFrames then
				State.currentFrame = 1
			end
		end
		return
	end

	if State.showingChoice then
		Buttons.update(dt, State)
		return
	end

	Targets.update(dt, State)
end

function love.mousemoved(x, y, dx, dy)
	if State.gameOver then
		return
	end

	State.cameraX = State.cameraX + dx * 1.5
	State.cameraY = State.cameraY + dy * 1.5

	State.cameraX = math.max(0, math.min(State.cameraX, State.worldWidth - State.screenWidth))
	State.cameraY = math.max(0, math.min(State.cameraY, State.worldHeight - State.screenHeight))
end

function love.draw()
	love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

	if State.gameOver then
		if State.showSecondImage then
			love.graphics.setColor(1, 1, 1)
			local x = (State.screenWidth - Images.secondImage:getWidth()) / 2
			local y = (State.screenHeight - Images.secondImage:getHeight()) / 2
			love.graphics.draw(Images.secondImage, x, y)
		else
			if #Images.celebrationFrames > 0 then
				local gif = Images.celebrationFrames[State.currentFrame]
				local x = (State.screenWidth - gif:getWidth()) / 2
				local y = (State.screenHeight - gif:getHeight()) / 2
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(gif, x, y)
			end
		end
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("My pookie said yes!!!", 0, 500, State.screenWidth, "center")
	else
		love.graphics.push()
		love.graphics.translate(-State.cameraX, -State.cameraY)

		-- Grid
		love.graphics.setColor(0.2, 0.2, 0.25)
		for x = 0, State.worldWidth, 50 do
			love.graphics.line(x, 0, x, State.worldHeight)
		end
		for y = 0, State.worldHeight, 50 do
			love.graphics.line(0, y, State.worldWidth, y)
		end

		if State.showingChoice then
			Buttons.draw()
		else
			Targets.draw()
		end

		love.graphics.pop()

		-- Message
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(love.graphics.newFont(32))
		local revealed = string.sub(State.message, 1, State.revealedLetters)
		local remaining = string.sub(State.message, State.revealedLetters + 1)
		local fullWidth = love.graphics.getFont():getWidth(State.message)
		local startX = (State.screenWidth - fullWidth) / 2
		love.graphics.print(revealed, startX, 50)
		local revealedWidth = love.graphics.getFont():getWidth(revealed)
		love.graphics.setColor(1, 1, 1, 0)
		love.graphics.print(remaining, startX + revealedWidth, 50)

		-- UI
		love.graphics.setFont(love.graphics.newFont(12))
		if not State.showingChoice then
			love.graphics.setColor(1, 1, 1)
			love.graphics.print("Score: " .. State.score .. " / " .. string.len(State.message), 10, 10)
		else
			love.graphics.setColor(1, 1, 1)
			love.graphics.print("Shoot your answer!", 10, 10)
		end

		-- Crosshair
		local centerX = State.screenWidth / 2
		local centerY = State.screenHeight / 2
		love.graphics.setColor(1, 1, 1)
		love.graphics.setLineWidth(2)
		love.graphics.line(centerX - 15, centerY, centerX + 15, centerY)
		love.graphics.line(centerX, centerY - 15, centerX, centerY + 15)
		love.graphics.circle("fill", centerX, centerY, 2)
	end
end

function love.mousepressed(x, y, button)
	if State.gameOver then
		return
	end
	if button ~= 1 then
		return
	end

	Sounds.playShoot()

	local centerX = State.screenWidth / 2
	local centerY = State.screenHeight / 2
	local worldX = centerX + State.cameraX
	local worldY = centerY + State.cameraY

	if State.showingChoice then
		local yesDistance = math.sqrt((worldX - Buttons.yesButton.x) ^ 2 + (worldY - Buttons.yesButton.y) ^ 2)
		local noDistance = math.sqrt((worldX - Buttons.noButton.x) ^ 2 + (worldY - Buttons.noButton.y) ^ 2)

		if yesDistance < Buttons.yesButton.size then
			Sounds.playKill(5)
			State.gameOver = true
			return
		elseif noDistance < Buttons.noButton.size then
			love.window.showMessageBox("Oops!", "Wrong button! Try again 😊", "info")
			return
		end
	else
		for i = #Targets.list, 1, -1 do
			local target = Targets.list[i]
			local distance = math.sqrt((worldX - target.x) ^ 2 + (worldY - target.y) ^ 2)

			if distance < target.size then
				Sounds.playKill(State.currentKillSound)

				State.currentKillSound = State.currentKillSound + 1
				if State.currentKillSound > 5 then
					State.currentKillSound = 1
				end

				table.remove(Targets.list, i)
				State.score = State.score + 1
				State.revealedLetters = State.revealedLetters + 1

				if State.revealedLetters >= string.len(State.message) then
					State.showingChoice = true
					Targets.clear()
					Buttons.create(State)
					return
				end

				Targets.spawn(State)
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
