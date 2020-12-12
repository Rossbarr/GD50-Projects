Bird = Class{}

local GRAVITY = 6

function Bird:init()
	self.image = love.graphics.newImage('bird.png')
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	
	self.x = VIRTUAL_WIDTH / 3 - (self.width / 2)
	self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)
	
	self.dy = 0
end

function Bird:collides(pipe)
	if self.x + self.width - 2 >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
		if self.y + self.height - 2 >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
			return true
		end
	end
	
	return false
end

function Bird:update(dt)
	self.dy = self.dy + GRAVITY * dt
	
	if love.keyboard.keysPressed['space'] or love.mouse.wasPressed(1) then
		self.dy = -1
		sounds['jump']:play()
	end
	
	self.y = self.y + self.dy
end

function Bird:render()
	love.graphics.draw(self.image, self.x, self.y)
end