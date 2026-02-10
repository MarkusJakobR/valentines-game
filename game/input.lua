local Input = {}

function Input.handleMouseMove(state, dx, dy)
	if state.gameOver then
		return
	end

	state.cameraX = state.cameraX + dx * 1.5
	state.cameraY = state.cameraY + dy * 1.5

	state.cameraX = math.max(0, math.min(state.cameraX, state.worldWidth - state.screenWidth))
	state.cameraY = math.max(0, math.min(state.cameraY, state.worldHeight - state.screenHeight))
end

function Input.handleMousePress(state, x, y, button, targets, buttons, sounds)
	if state.gameOver then
		return
	end
	if button ~= 1 then
		return
	end

	sounds.playShoot()

	local centerX = state.screenWidth / 2
	local centerY = state.screenHeight / 2
	local worldX = centerX + state.cameraX
	local worldY = centerY + state.cameraY

	if state.showingChoice then
		Input.handleChoiceClick(state, worldX, worldY, buttons, sounds)
	else
		Input.handleTargetClick(state, worldX, worldY, targets, buttons, sounds)
	end
end

function Input.handleChoiceClick(state, worldX, worldY, buttons, sounds)
	local yesDistance = math.sqrt((worldX - buttons.yesButton.x) ^ 2 + (worldY - buttons.yesButton.y) ^ 2)
	local noDistance = math.sqrt((worldX - buttons.noButton.x) ^ 2 + (worldY - buttons.noButton.y) ^ 2)

	if yesDistance < buttons.yesButton.size then
		sounds.playKill(5)
		state.gameOver = true
		return
	elseif noDistance < buttons.noButton.size then
		love.window.showMessageBox("Oops!", "Wrong button! Try again 😊", "info")
		return
	end
end

function Input.handleTargetClick(state, worldX, worldY, targets, buttons, sounds)
	for i = #targets.list, 1, -1 do
		local target = targets.list[i]
		local distance = math.sqrt((worldX - target.x) ^ 2 + (worldY - target.y) ^ 2)

		if distance < target.size then
			sounds.playKill(state.currentKillSound)

			state.currentKillSound = state.currentKillSound + 1
			if state.currentKillSound > 5 then
				state.currentKillSound = 1
			end

			table.remove(targets.list, i)
			state.score = state.score + 1
			state.revealedLetters = state.revealedLetters + 1

			if state.revealedLetters >= string.len(state.message) then
				state.showingChoice = true
				targets.clear()
				buttons.create(state)
				return
			end

			targets.spawn(state)
			break
		end
	end
end

function Input.handleKeyPress(key)
	if key == "escape" then
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		love.event.quit()
	end
end

return Input
