PipePair = Class{}

local GAP_HEIGHT = 100

function PipePair:init(y)
	self.x = VIRTUAL_WIDTH + 32
	self.y = y
	
	self.pipes = {
		['upper'] = Pipe('top', self.y),
		['lower'] = Pipe('bot', self.y + GAP_HEIGHT + PIPE_HEIGHT + math.random(-10, 30))
	}
	
	self.remove = false
	self.scored = false
end

function PipePair:update(dt)
	if self.x > -PIPE_WIDTH then
		self.x = self.x - PIPE_SPEED * dt
		self.pipes['upper'].x = self.x
		self.pipes['lower'].x = self.x
	else
		self.remove = true
	end
end

function PipePair:render()
	for k, pipe in pairs(self.pipes) do
		pipe:render()
	end
end