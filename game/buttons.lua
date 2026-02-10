local Buttons = {}

Buttons.yesButton = nil
Buttons.noButton = nil

function Buttons.create(state)
	local minX = state.screenWidth / 2
	local maxX = (state.worldWidth - state.screenWidth) + state.screenWidth / 2
	local minY = state.screenHeight / 2
	local maxY = (state.worldHeight - state.screenHeight) + state.screenHeight / 2

	local centerX = (minX + maxX) / 2
	local centerY = (minY + maxY) / 2

	Buttons.yesButton = {
		x = centerX - 150,
		y = centerY,
		size = 80,
		text = "YES",
		vx = math.random(-80, 80),
		vy = math.random(-80, 80),
	}

	Buttons.noButton = {
		x = centerX + 150,
		y = centerY,
		size = 80,
		text = "NO",
		vx = math.random(-120, 120),
		vy = math.random(-120, 120),
	}
end

function Buttons.update(dt, state)
	local minX = state.screenWidth / 2
	local maxX = (state.worldWidth - state.screenWidth) + state.screenWidth / 2
	local minY = state.screenHeight / 2
	local maxY = (state.worldHeight - state.screenHeight) + state.screenHeight / 2

	-- YES button
	Buttons.yesButton.x = Buttons.yesButton.x + Buttons.yesButton.vx * dt
	Buttons.yesButton.y = Buttons.yesButton.y + Buttons.yesButton.vy * dt

	if Buttons.yesButton.x <= minX or Buttons.yesButton.x >= maxX then
		Buttons.yesButton.vx = -Buttons.yesButton.vx
		Buttons.yesButton.x = math.max(minX, math.min(Buttons.yesButton.x, maxX))
	end
	if Buttons.yesButton.y <= minY or Buttons.yesButton.y >= maxY then
		Buttons.yesButton.vy = -Buttons.yesButton.vy
		Buttons.yesButton.y = math.max(minY, math.min(Buttons.yesButton.y, maxY))
	end

	-- NO button
	Buttons.noButton.x = Buttons.noButton.x + Buttons.noButton.vx * dt
	Buttons.noButton.y = Buttons.noButton.y + Buttons.noButton.vy * dt

	if Buttons.noButton.x <= minX or Buttons.noButton.x >= maxX then
		Buttons.noButton.vx = -Buttons.noButton.vx
		Buttons.noButton.x = math.max(minX, math.min(Buttons.noButton.x, maxX))
	end
	if Buttons.noButton.y <= minY or Buttons.noButton.y >= maxY then
		Buttons.noButton.vy = -Buttons.noButton.vy
		Buttons.noButton.y = math.max(minY, math.min(Buttons.noButton.y, maxY))
	end
end

function Buttons.draw()
	local font = love.graphics.newFont(32)
	love.graphics.setFont(font)

	-- YES button
	love.graphics.setColor(0.2, 0.8, 0.3)
	love.graphics.circle("fill", Buttons.yesButton.x, Buttons.yesButton.y, Buttons.yesButton.size)
	love.graphics.setColor(1, 1, 1)
	local yesWidth = font:getWidth(Buttons.yesButton.text)
	love.graphics.print(Buttons.yesButton.text, Buttons.yesButton.x - yesWidth / 2, Buttons.yesButton.y - 16)

	-- NO button
	love.graphics.setColor(0.8, 0.2, 0.2)
	love.graphics.circle("fill", Buttons.noButton.x, Buttons.noButton.y, Buttons.noButton.size)
	love.graphics.setColor(1, 1, 1)
	local noWidth = font:getWidth(Buttons.noButton.text)
	love.graphics.print(Buttons.noButton.text, Buttons.noButton.x - noWidth / 2, Buttons.noButton.y - 16)
end

return Buttons
