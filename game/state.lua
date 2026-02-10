local State = {}

-- Game state
State.score = 0
State.gameOver = false
State.showingChoice = false
State.revealedLetters = 0
State.currentKillSound = 1

-- Camera
State.cameraX = 0
State.cameraY = 0

-- World bounds based on screen size only
State.screenWidth = 800
State.screenHeight = 600
State.cameraRange = 400 -- How far camera can move from origin
State.worldWidth = State.screenWidth + (State.cameraRange * 2)
State.worldHeight = State.screenHeight + (State.cameraRange * 2)

-- Message to reveal
State.message = "WILL YOU BE MY VALENTINE?"

-- Animation
State.currentFrame = 1
State.frameTimer = 0
State.frameDelay = 0.1
State.showSecondImage = false
State.gameOverTimer = 0
State.secondImageDelay = 5

return State
