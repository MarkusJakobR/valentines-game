local State = require("game.state")
local Sounds = require("game.sounds")
local Images = require("game.images")
local Targets = require("game.targets")
local Buttons = require("game.buttons")
local UI = require("game.ui")
local Input = require("game.input")

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
	Input.handleMouseMove(State, dx, dy)
end

function love.draw()
	love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

	if State.gameOver then
		UI.drawGameOver(State, Images)
	else
		love.graphics.push()
		love.graphics.translate(-State.cameraX, -State.cameraY)

		UI.drawGrid(State)

		if State.showingChoice then
			Buttons.draw()
		else
			Targets.draw()
		end

		love.graphics.pop()

		UI.drawMessage(State)
		UI.drawScore(State)
		UI.drawCrosshair(State)
	end
end

function love.mousepressed(x, y, button)
	Input.handleMousePress(State, x, y, button, Targets, Buttons, Sounds)
end

function love.keypressed(key)
	Input.handleKeyPress(key)
end
