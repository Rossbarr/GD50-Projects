PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
	self.paddle = params.paddle
	self.bricks = params.bricks
	self.health = params.health
	self.score = params.score
	self.ball = params.ball
	self.level = params.level
	self.highScores = params.highScores
	self.recoverPoints = params.recoverPoints
	
	self.ball.dx = math.random(-200, 200)
	self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
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
	
	self.paddle:update(dt)
	self.ball:update(dt)

	if self.ball:collides(self.paddle) then
		self.ball.y = self.paddle.y - self.ball.height
		self.ball.dy = -self.ball.dy

		if self.ball.x < self.paddle.x + self.paddle.width / 2 and self.paddle.dx < 0 then
			self.ball.dx = -50 + -(6 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
		elseif self.ball.x > self.paddle.x + self.paddle.width / 2 and self.paddle.dx > 0 then
			self.ball.dx = 50 + (6 * (self.ball.x - self.paddle.x + self.paddle.width / 2))
		end

		gSounds["paddle-hit"]:play()
	elseif self.ball.y >= VIRTUAL_HEIGHT then
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
		if brick.inPlay and self.ball:collides(brick) then
			self.score = self.score + (brick.tier * 200 + brick.color * 25)
			brick:hit()

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
					ball = self.ball,
					highScores = self.highScores,
					recoverPoints = self.recoverPoints
					})
			end

			if self.ball.dx > 0 and self.ball.x + 2 < brick.x then
				self.ball.dx = -self.ball.dx
				self.ball.x = brick.x - self.ball.width
			elseif self.ball.dx < 0 and self.ball.x + self.ball.width / 2 + 2 > brick.x + brick.width then
				self.ball.dx = -self.ball.dx
				self.ball.x = brick.x + brick.width
			elseif self.ball.y < brick.y then
				self.ball.dy = -self.ball.dy
				self.ball.y = brick.y - self.ball.height
			else
				self.ball.dy = -self.ball.dy
				self.ball.y = brick.y + brick.height
			end

			self.ball.dy = self.ball.dy * 1.02

			break				
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
	self.ball:render()
	
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