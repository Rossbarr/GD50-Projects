push = require "push"
Class = require "class"

require "bird"
require "pipe"
require "pipePair"

require "StateMachine"
require "states/BaseState"
require "states/PlayState"
require "states/TitleScreenState"
require "states/ScoreState"
require "states/CountdownState"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

gScrolling = true

local background = love.graphics.newImage('background.png')
local backgroundScroll = 0
local BACKGROUND_SCROLL_SPEED = 30
local BACKGROUND_LOOPING_POINT = 413

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0
local GROUND_SCROLL_SPEED = 60

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.window.setTitle('Fifty Bird')
	
	smallFont = love.graphics.newFont('font.ttf', 8)
	mediumFont = love.graphics.newFont('flappy.ttf', 14)
	flappyFont = love.graphics.newFont('flappy.ttf', 28)
	hugeFont = love.graphics.newFont('flappy.ttf', 56)
	love.graphics.setFont(flappyFont)
	
	math.randomseed(os.time())
	
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true
	})
	
	gStateMachine = StateMachine {
		['title'] = function() return TitleScreenState() end,
		['play'] = function() return PlayState() end,
		['score'] = function() return ScoreState() end,
		['countdown'] = function() return CountdownState() end
	}
	gStateMachine:change('title')
	
	sounds = {
		['jump'] = love.audio.newSource('jump.wav', 'static'),
		['explosion'] = love.audio.newSource('explosion.wav', 'static'),
		['hurt'] = love.audio.newSource('hurt.wav', 'static'),
		['score'] = love.audio.newSource('score.wav', 'static'),
		['music'] = love.audio.newSource('marios_way.mp3', 'static')
	}
	
	sounds['music']:setLooping(true)
	sounds['music']:play()

	love.keyboard.keysPressed = {}
	love.mouse.buttonsPressed = {}
end

function love.update(dt)
	if gScrolling then
		backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
		groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
	end
	
	gStateMachine:update(dt)
	
	love.keyboard.keysPressed = {}
	love.mouse.buttonsPressed = {}
end

function love.draw()
	push:start()
	
	love.graphics.draw(background, -backgroundScroll, 0)
	
	gStateMachine:render()
		
	love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
		
	push:finish()
end

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true
	
	if key == 'escape' then
		love.event.quit()
	end
end

function love.keyboard.wasPressed(key)
	if love.keyboard.keysPressed[key] then
		return true
	else
		return false
	end
end

function love.mousepressed(x, y, button)
	love.mouse.buttonsPressed[button] = true
end

function love.mouse.wasPressed(button)
	return love.mouse.buttonsPressed[button]
end

function love.resize(w, h)
	push:resize(w, h)
end