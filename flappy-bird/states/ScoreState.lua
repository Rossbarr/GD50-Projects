ScoreState = Class{__includes = BaseState}

function ScoreState:enter(params)
	self.score = params.score
	self.medal = ScoreState:setMedal(self.score)
end

function ScoreState:update(dt)
	if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
		gStateMachine:change('countdown')
	end
end

function ScoreState:render()
	love.graphics.setFont(flappyFont)
	love.graphics.printf('Oof, you lose!', 0, 64, VIRTUAL_WIDTH, 'center')
	
	love.graphics.setFont(mediumFont)
	love.graphics.printf('Score..' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')
	love.graphics.printf('You were ' .. self.medal, 0, 130, VIRTUAL_WIDTH, 'center')
	
	love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end

function ScoreState:setMedal(score)
	if score >= 10 then
		medal = 'silver'
	elseif score >= 50 then
		medal = 'gold'
	elseif score >= 100 then
		medal = 'platinum'
	else
		medal = 'bronze'
	end
	return medal
end