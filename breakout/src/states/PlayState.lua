PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
	self.paddle = params.paddle
	self.bricks = params.bricks
	self.health = params.health
	self.score = params.score
	self.level = params.level
	self.highScores = params.highScores
	self.recoverPoints = params.recoverPoints
	self.powerups = {}
	self.balls = {[1] = params.ball}
	
	self.balls[1].dx = math.random(-200, 200)
	self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
	self:checkForPause()
	
	self.paddle:update(dt)

	for k, ball in pairs(self.balls) do
		self:ballChecks(k, ball, dt)
	end

	for k, powerup in pairs(self.powerups) do
		powerup:update(dt)

		if powerup:collides(self.paddle) then
			self:spawnExtraBalls()

			table.remove(self.powerups, k)
		end
	end
	
	for k, brick in pairs(self.bricks) do
		brick:update(dt)
	end

	if love.keyboard.wasPressed("escape") then
		love.event.quit()
	end
end

function PlayState:render()
	for k, brick in pairs(self.bricks) do
		brick:render()
	end

	for k, brick in pairs(self.bricks) do
		brick:renderParticles()
	end
	
	self.paddle:render()
	
	for k, ball in pairs(self.balls) do
		ball:render()
	end

	for k, powerup in pairs(self.powerups) do
		powerup:render()
	end
	
	renderScore(self.score)
	renderHealth(self.health)

	if self.paused then
		love.graphics.setFont(gFonts["large"])
		love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
	end
end

function PlayState:checkVictory()
	for k, brick in pairs(self.bricks) do
		if brick.inPlay then
			return false
		end
	end
	return true
end

function PlayState:spawnExtraBalls()
	table.insert(self.balls, 2, Ball(math.random(7)))
	table.insert(self.balls, 3, Ball(math.random(7)))
end

function PlayState:checkForPause()
	if self.paused then
		if love.keyboard.wasPressed("space") then
			self.paused = false
			gSounds["pause"]:play()
		else
			return
		end
	elseif love.keyboard.wasPressed("space") then
		self.paused = true
		gSounds["pause"]:play()
		return
	end
end

function PlayState:ballChecks(k, ball, dt)
	ball:update(dt)

	if ball:collides(self.paddle) then
		ball.y = self.paddle.y - ball.height
		ball.dy = -ball.dy

		if ball.x < self.paddle.x + self.paddle.width / 2 and self.paddle.dx < 0 then
			ball.dx = -50 + -(6 * (self.paddle.x + self.paddle.width / 2 - ball.x))
		elseif ball.x > self.paddle.x + self.paddle.width / 2 and self.paddle.dx > 0 then
			ball.dx = 50 + (6 * (ball.x - self.paddle.x + self.paddle.width / 2))
		end

		gSounds["paddle-hit"]:play()
	elseif ball.y >= VIRTUAL_HEIGHT then
		table.remove(self.balls, k)
	end

	if #self.balls == 0 then
		self.health = self.health - 1
		gSounds["hurt"]:play()

		if self.health < 1 then
			gStateMachine:change("game-over", {
				score = self.score,
				highScores = self.highScores
			})
		else
			gStateMachine:change("serve", {
				paddle = self.paddle,
				bricks = self.bricks,
				health = self.health,
				score = self.score,
				level = self.level,
				highScores = self.highScores,
				recoverPoints = self.recoverPoints
			})
		end
	end

	for k, brick in pairs(self.bricks) do
		if brick.inPlay and ball:collides(brick) then
			self.score = self.score + (brick.tier * 200 + brick.color * 25)
			brick:hit()
			
			if math.random(19 + #self.balls + 10*#self.powerups) == 1 then
				table.insert(self.powerups, 1, Powerup(brick.x + brick.width / 2, brick.y, 1))
			end

			if self.score > self.recoverPoints then
				self.health = math.min(3, self.health + 1)
				
				self.recoverPoints = math.min(100000, self.recoverPoints * 2)
				
				gSounds["recover"]:play()
			end

			if self:checkVictory() then
				gSounds["victory"]:play()

				gStateMachine:change("victory", {
					level = self.level,
					paddle = self.paddle,
					health = self.health,
					score = self.score,
					highScores = self.highScores,
					recoverPoints = self.recoverPoints
					})
			end

			if ball.dx > 0 and ball.x + 2 < brick.x then
				ball.dx = -ball.dx
				ball.x = brick.x - ball.width
			elseif ball.dx < 0 and ball.x + ball.width / 2 + 2 > brick.x + brick.width then
				ball.dx = -ball.dx
				ball.x = brick.x + brick.width
			elseif ball.y < brick.y then
				ball.dy = -ball.dy
				ball.y = brick.y - ball.height
			else
				ball.dy = -ball.dy
				ball.y = brick.y + brick.height
			end

			ball.dy = ball.dy * 1.02

			break				
		end
	end
end