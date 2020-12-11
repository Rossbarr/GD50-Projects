--[[
	Pong made under direction of GD50.
	Made by Barrett Ross
	Barretross23@gmail.com
]]

push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[
	Runs at startup
]]
function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	
	love.window.setTitle('Pong')
	
	smallFont = love.graphics.newFont('font.ttf', 8)
	
	scoreFont = love.graphics.newFont('font.ttf', 32)
	
	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
	}
	
	love.graphics.setFont(smallFont)
	
	math.randomseed(os.time())
	
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true
	})
	
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	
	player1score = 0
	player2score = 0
	
	servingPlayer = 1
	
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
		
	gameState = 'start'
end

function love.update(dt)
	-- player 1 movement
	if love.keyboard.isDown("w") then	
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown("s") then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end
	
	-- player 2 movement
	if ball.y < player2.y + player2.heights / 2 then
		player2.dy = -PADDLE_SPEED
	elseif ball.y > player2.y + player2.height / 2 then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end
	
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif gameState == 'play' then
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + player1.width
			
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
			
			sounds.paddle_hit:play()
		elseif ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - ball.width
			
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
			
			sounds.paddle_hit:play()
		end
		
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds.wall_hit:play()
		elseif ball.y >= VIRTUAL_HEIGHT - ball.height then
			ball.y = VIRTUAL_HEIGHT - ball.height
			ball.dy = -ball.dy
			sounds.wall_hit:play()
		end

		ball:update(dt)
	
		if ball.x < 0 then
			servingPlayer = 1
			player2score = player2score + 1
			if player2score > 9 then
				winningPlayer = 2
				gameState = 'done'
			else
				ball:reset()
				gameState = 'serve'
			end
			
			sounds.score:play()
		elseif ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1score = player1score + 1
			if player1score > 9 then
				winningPlayer = 2
				gameState = 'done'
			else
				ball:reset()
				gameState = 'serve'
			end

			sounds.score:play()
		end
	end
	
	player1:update(dt)
	player2:update(dt)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'
			
			ball:reset()
			
			player1score = 0
			player2score = 0
			
			if winningPlayer == 1 then
				servingPlayer = 2
			elseif winningPlayer == 2 then
				servingPlayer = 1
			end
		end
	end
end

--[[
	Called every frame after love.update().
	Draws things to the screen
]]
function love.draw()
	push:apply('start')
	
	love.graphics.clear(40/255, 45/255, 52/255, 255/255)
	
	love.graphics.setFont(smallFont)
	if gameState == 'start' then
		love.graphics.printf('Welcome to Pong', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press enter to start', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press enter to start', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'done' then
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
	end
	
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

	player1:render()
	player2:render()
	
	ball:render()
	
	displayFPS()
	
	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255/255, 0, 255/255)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function love.resize(w, h)
	push:resize(w, h)
end