local Images = {}

function Images.load()
	-- Load celebration GIF frames
	Images.celebrationFrames = {}
	for i = 1, 14 do
		local frame = love.graphics.newImage("images/hachiware_gif/frame_" .. i .. " 2.png")
		table.insert(Images.celebrationFrames, frame)
	end

	Images.secondImage = love.graphics.newImage("images/em_tulips.png")
end

return Images
