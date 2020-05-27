function love.load()
  playingAreaWidth = 480
  playingAreaHeight = 272
  
  bikeHeight = 20
  bikeWidth = 20
  bikeY=20
  bikeX = 54
  bikeLane=2
  bikeXSpeed=0
  bikeYSpeed=0
  bikeYSpeedMax=1028
  bikeMaxSpeed=10
  
  perspectiveOffset=15
  
  pipeSpaceHeight = 100
  pipeWidth = 54
  
	pause = true

  love.window.setMode(playingAreaWidth, playingAreaHeight)

  foregroundWidth=40
  midgroundWidth=40
  bikeLaneCount=3
  bikeLaneWidth=20
  bikeLaneCenteringOffset=10
  bikeLaneFloor=playingAreaHeight - foregroundWidth  - bikeLane * bikeLaneWidth - bikeLaneCenteringOffset
  lanePerturbation=0


  -- Rain Start
	texture = love.graphics.newImage('raintex.png')
	texture:setWrap('repeat','repeat')
  
  local vertices = {
		{
			-- top-left corner
			0, 0, -- position of the vertex
			0, 0, -- texture coordinate at the vertex position
			255, 255, 255, 255 -- color & alpha of the vertex
		},
		{
			-- top-right corner
			texture:getWidth(), 0,
			1, 0, -- texture coordinates are in the range of [0, 1]
			255, 255, 255, 255
		},
		{
			-- bottom-right corner
			texture:getWidth(), texture:getHeight(),
			1, 1,
			255, 255, 255, 255
		},
		{
			-- bottom-left corner
			0, texture:getHeight(),
			0, 1,
			255, 255, 255, 255
		},
	}

	mesh = love.graphics.newMesh(vertices, 'fan')
	mesh:setTexture(texture)
  -- Rain Stop


  function newPipeSpaceY()
    local pipeSpaceYMin = 54
    local pipeSpaceY = love.math.random(
        pipeSpaceYMin,
        playingAreaHeight - pipeSpaceHeight - pipeSpaceYMin
    )
    return pipeSpaceY
  end
  
  function reset()
    bikeYSpeed = 0
    bikeXSpeed = 0
    
    pipe1X = playingAreaWidth
    pipe1SpaceY = newPipeSpaceY()

    pipe2X = playingAreaWidth + ((playingAreaWidth + pipeWidth) / 2)
    pipe2SpaceY = newPipeSpaceY()
    
    pipeFar1X = playingAreaWidth
    pipeFar1SpaceY = newPipeSpaceY()

    pipeFar2X = playingAreaWidth + ((playingAreaWidth + pipeWidth) / 2)
    pipeFar2SpaceY = newPipeSpaceY()
    
    score = 0
    upcomingPipe = 1
  end
  
  reset()
end

--Rain start
local function clamp(x,m,s) return math.max(math.min(x,s),m) end
local time = 0.0
local wave = 5.0
--Rain stop

function love.update(dt)
  if pause then return end
  bikeLaneFloor=playingAreaHeight - foregroundWidth  - bikeLane * bikeLaneWidth - bikeLaneCenteringOffset
  lanePerturbation=(love.math.random(-(bikeXSpeed),(bikeXSpeed))+1)/(bikeMaxSpeed/2)
 
  
  bikeY = bikeY + (bikeYSpeed*dt)
  if bikeYSpeed < bikeYSpeedMax then 
    bikeYSpeed = bikeYSpeed + (516 * dt)
  end
  
  if bikeY > bikeLaneFloor - 2 then
    bikeY = bikeLaneFloor
  end

  if bikeY == bikeLaneFloor then
    bikeY = lanePerturbation+bikeY
  end
  
  if love.keyboard.isDown('d') and bikeXSpeed < bikeMaxSpeed then
    bikeXSpeed = bikeXSpeed + 0.1
  end
  
  if not love.keyboard.isDown('d') and bikeXSpeed > -1 then
    bikeXSpeed = bikeXSpeed - 0.1
  end
  
  
  local function movePipe(pipeX, pipeSpaceY)
    pipeX = pipeX - (60 * dt) - bikeXSpeed
    
    if (pipeX + pipeWidth) < 0 then
        pipeX = playingAreaWidth
        pipeSpaceY = newPipeSpaceY()
    end

    return pipeX, pipeSpaceY
  end

  local function moveFarPipe(pipeX, pipeSpaceY)
    
    pipeX = pipeX - (60 * dt) - bikeXSpeed/3
    
    if (pipeX + pipeWidth) < 0 then
        pipeX = playingAreaWidth
        pipeSpaceY = newPipeSpaceY()
    end

    return pipeX, pipeSpaceY
  end

  pipe1X, pipe1SpaceY = movePipe(pipe1X, pipe1SpaceY)
  pipe2X, pipe2SpaceY = movePipe(pipe2X, pipe2SpaceY)
  
  pipeFar1X, pipeFar1SpaceY = moveFarPipe(pipeFar1X, pipeFar1SpaceY)
  pipeFar2X, pipeFar2SpaceY = moveFarPipe(pipeFar2X, pipeFar2SpaceY)
  
  --[[
  function isBikeCollidingWithPipe(pipeX, pipeSpaceY)
  return
    -- Left edge of bike is to the left of the right edge of pipe
    bikeX < (pipeX + pipeWidth)
    and
     -- Right edge of bike is to the right of the left edge of pipe
    (bikeX + bikeWidth) > pipeX
    and (
      -- Top edge of bike is above the bottom edge of first pipe segment
      bikeY < pipeSpaceY
      or
      (bikeY + bikeHeight) > (pipeSpaceY + pipeSpaceHeight)
    )
  end
  
  if isBikeCollidingWithPipe(pipe1X, pipe1SpaceY)
  or isBikeCollidingWithPipe(pipe2X, pipe2SpaceY) 
  or bikeY > playingAreaHeight then
    reset()
  end
  ]]--
  
  local function updateScoreAndClosestPipe(thisPipe, pipeX, otherPipe)
      if upcomingPipe == thisPipe
      and (bikeX > (pipeX + pipeWidth)) then
          score = score + 1
          upcomingPipe = otherPipe
      end
  end

  updateScoreAndClosestPipe(1, pipe1X, 2)
  updateScoreAndClosestPipe(2, pipe2X, 1)
  
  --Rain start
  local u, v

	for i=1,4 do
		u, v = mesh:getVertexAttribute(i, 2)
		u, v = u-dt/5, v-dt
		mesh:setVertexAttribute(i, 2, u, v)
	end
  --Rain stop
  
end

function love.keypressed(key)
  if key == 'p' then 
    pause = true
  else
    pause = false
    if bikeLane < 3 and key == 'w' then
      bikeLane = bikeLane + 1
    end
    if bikeLane > 1 and key == 's' then
      bikeLane = bikeLane - 1
    end
    if bikeXSpeed > -2 and key == 'a' then
      bikeXSpeed = bikeXSpeed - 1
    end
    if key == 'j' then
      bikeYSpeed = -200
    end
  end
end
  

function love.draw()
  
  local function drawPipe(pipeX, pipeSpaceY)
    love.graphics.setColor(.37, .82, .28)
    love.graphics.rectangle(
        'fill',
        pipeX,
        0,
        pipeWidth,
        pipeSpaceY
    )
    love.graphics.rectangle(
        'fill',
        pipeX,
        pipeSpaceY + pipeSpaceHeight,
        pipeWidth,
        playingAreaHeight - pipeSpaceY - pipeSpaceHeight
    )
  end

local function drawFarPipe(pipeX, pipeSpaceY)
    love.graphics.setColor(0, .20, 0)
    love.graphics.rectangle(
        'fill',
        pipeX,
        0,
        pipeWidth,
        pipeSpaceY
    )
    love.graphics.rectangle(
        'fill',
        pipeX,
        pipeSpaceY + pipeSpaceHeight,
        pipeWidth,
        playingAreaHeight - pipeSpaceY - pipeSpaceHeight
    )
  end

--background
  love.graphics.setColor(.09, .45, .80)
  love.graphics.rectangle('fill', 0, 0, playingAreaWidth, playingAreaHeight)
  
  drawFarPipe(pipeFar1X, pipeFar1SpaceY)
  drawFarPipe(pipeFar2X, pipeFar2SpaceY)
  
  --midground
  drawPipe(pipe1X, pipe1SpaceY)
  drawPipe(pipe2X, pipe2SpaceY)

  --foreground
  love.graphics.setColor(0, .50, 0)
  love.graphics.rectangle('fill', 0, (playingAreaHeight-foregroundWidth-bikeLaneWidth*bikeLaneCount-midgroundWidth), playingAreaWidth, foregroundWidth + bikeLaneWidth * bikeLaneCount + midgroundWidth)
  
  --lane 1
  love.graphics.setColor(.87, .84, .27)
  love.graphics.rectangle('fill', 0, (playingAreaHeight-foregroundWidth-bikeLaneWidth*1), playingAreaWidth, bikeLaneWidth)
  --lane 2
  love.graphics.rectangle('fill', 0, (playingAreaHeight-foregroundWidth-bikeLaneWidth*2), playingAreaWidth, bikeLaneWidth)
  --lane 3
  love.graphics.rectangle('fill', 0, (playingAreaHeight-foregroundWidth-bikeLaneWidth*3), playingAreaWidth, bikeLaneWidth)

  
  --bike
  love.graphics.setColor(.36, .14, .43)
  love.graphics.rectangle('fill', bikeX+perspectiveOffset*bikeLane, bikeY , bikeWidth, bikeHeight)
  

  
  --Rain start
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(mesh, 0, 0, 0, playingAreaWidth/texture:getWidth(), playingAreaHeight/texture:getHeight())
  --Rain stop
  
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(bikeLane, 15, 15, 0, 2, 2)
  love.graphics.print(bikeYSpeed, 100, 15, 0, 2, 2)
  love.graphics.print(bikeY, 200, 15, 0, 2, 2)
  love.graphics.print(bikeLaneFloor, 300, 15, 0, 2, 2)

  if pause then 
    love.graphics.print("Game Paused", playingAreaWidth/2-80, (playingAreaHeight/2)-24, 0, 2, 2) 
    return 
  end
end