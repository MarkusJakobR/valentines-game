local Targets = {}

Targets.list = {}
Targets.maxTargets = 5
Targets.targetSize = 30

function Targets.spawn(state)
	local minX = state.screenWidth / 2
	local maxX = (state.worldWidth - state.screenWidth) + state.screenWidth / 2
	local minY = state.screenHeight / 2
	local maxY = (state.worldHeight - state.screenHeight) + state.screenHeight / 2

	local target = {
		x = math.random(minX, maxX),
		y = math.random(minY, maxY),
		vx = math.random(-100, 100),
		vy = math.random(-100, 100),
		size = Targets.targetSize,
	}
	table.insert(Targets.list, target)
end

function Targets.update(dt, state)
	local minX = state.screenWidth / 2
	local maxX = (state.worldWidth - state.screenWidth) + state.screenWidth / 2
	local minY = state.screenHeight / 2
	local maxY = (state.worldHeight - state.screenHeight) + state.screenHeight / 2

	for i, target in ipairs(Targets.list) do
		target.x = target.x + target.vx * dt
		target.y = target.y + target.vy * dt

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

function Targets.draw()
	for i, target in ipairs(Targets.list) do
		love.graphics.setColor(1, 0.2, 0.4)
		love.graphics.circle("fill", target.x, target.y, target.size)
		love.graphics.setColor(1, 0, 0.3)
		love.graphics.circle("fill", target.x - 10, target.y - 5, 15)
		love.graphics.circle("fill", target.x + 10, target.y - 5, 15)
	end
end

function Targets.clear()
	Targets.list = {}
end

return Targets
