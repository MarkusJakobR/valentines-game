local UI = {}

function UI.drawMessage(state)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(love.graphics.newFont(32))

	local revealed = string.sub(state.message, 1, state.revealedLetters)
	local remaining = string.sub(state.message, state.revealedLetters + 1)
	local fullWidth = love.graphics.getFont():getWidth(state.message)
	local startX = (state.screenWidth - fullWidth) / 2

	love.graphics.print(revealed, startX, 50)
	local revealedWidth = love.graphics.getFont():getWidth(revealed)
	love.graphics.setColor(1, 1, 1, 0)
	love.graphics.print(remaining, startX + revealedWidth, 50)
end

function UI.drawScore(state)
	love.graphics.setFont(love.graphics.newFont(12))
	if not state.showingChoice then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("Score: " .. state.score .. " / " .. string.len(state.message), 10, 10)
	else
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("Shoot your answer!", 10, 10)
	end
end

function UI.drawCrosshair(state)
	local centerX = state.screenWidth / 2
	local centerY = state.screenHeight / 2
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(2)
	love.graphics.line(centerX - 15, centerY, centerX + 15, centerY)
	love.graphics.line(centerX, centerY - 15, centerX, centerY + 15)
	love.graphics.circle("fill", centerX, centerY, 2)
end

function UI.drawGrid(state)
	love.graphics.setColor(0.2, 0.2, 0.25)
	for x = 0, state.worldWidth, 50 do
		love.graphics.line(x, 0, x, state.worldHeight)
	end
	for y = 0, state.worldHeight, 50 do
		love.graphics.line(0, y, state.worldWidth, y)
	end
end

function UI.drawGameOver(state, images)
	if state.showSecondImage then
		love.graphics.setColor(1, 1, 1)
		local x = (state.screenWidth - images.secondImage:getWidth()) / 2
		local y = (state.screenHeight - images.secondImage:getHeight()) / 2
		love.graphics.draw(images.secondImage, x, y)
	else
		if #images.celebrationFrames > 0 then
			local gif = images.celebrationFrames[state.currentFrame]
			local x = (state.screenWidth - gif:getWidth()) / 2
			local y = (state.screenHeight - gif:getHeight()) / 2
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(gif, x, y)
		end
	end
	love.graphics.setColor(1, 1, 1)
	love.graphics.printf("My pookie said yes!!!", 0, 500, state.screenWidth, "center")
end

return UI
