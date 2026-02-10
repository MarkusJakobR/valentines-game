local Sounds = {}

function Sounds.load()
	Sounds.shootSound = love.audio.newSource("sounds/gunshot.mp3", "static")
	Sounds.shootSound:setVolume(0.3)

	Sounds.winMusic = love.audio.newSource("sounds/yippee.mp3", "static")
	Sounds.secondMusic = love.audio.newSource("sounds/daddys-home.mp3", "static")

	Sounds.killSounds = {}
	for i = 1, 5 do
		Sounds.killSounds[i] = love.audio.newSource("sounds/kill_" .. i .. ".mp3", "static")
	end
end

function Sounds.playShoot()
	Sounds.shootSound:stop()
	Sounds.shootSound:play()
end

function Sounds.playKill(soundIndex)
	Sounds.killSounds[soundIndex]:stop()
	Sounds.killSounds[soundIndex]:play()
end

function Sounds.playWin()
	Sounds.winMusic:play()
end

function Sounds.playSecond()
	Sounds.winMusic:stop()
	Sounds.secondMusic:play()
end

return Sounds
