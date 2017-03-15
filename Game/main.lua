

function checkCollision(x1,y1,w1,h1,		x2,y2,w2,h2)
	return x1 < x2+w2 and
	       x2 < x1+w1 and
	       y1 < y2+h2 and
	       y2 < y1+h1
end

function love.load()
	love.window.setMode(1280, 720, {})
	love.window.setTitle("Runner")
	Generate()
	assignBonus()

end

function Generate()

	rectX = 0
	rectY = 600
	rectW = 100
	rectH = 100

	sensivity = 10

	score = 1
	scoreMultiplier = 1
	lives = 3

	difficulty = 3

	enemyBasicSpeed = 10
	enemyDelay = 0

	enemyList = {}
	bonusList = {}
	isLoose = false

	bonusDelay = 0
	bonusDuration = 0

	timer = 0
end

function countTime(dt)
	enemyDelay = enemyDelay + love.timer.getDelta()
	bonusDelay = bonusDelay - love.timer.getDelta()
	if bonusDuration > 0 then
		bonusDuration = bonusDuration - love.timer.getDelta()
	end
	if enemyDelay >= 2 then
		enemyDelay = 0
	end
	if bonusDelay <= 0 then
		generateBonus()
	end
end


function love.update(dt)
	if not isLoose then
		countTime(dt)
	end

	movePlayer()

	enemySpeed = enemyBasicSpeed + (score / 100)

	checkBoundaries()
	enemyUpdate()
	bonusUpdate()
	generateEnemy()
	-- generateBonus()


	if not isLoose then
		score = score + (scoreMultiplier * (rectX / 1000))
		if math.floor(score%500) == 0 then
			difficulty = difficulty + 1
			-- enemyBasicSpeed = enemyBasicSpeed + 5
		end

	end
	if isLoose and love.keyboard.isDown("r") then
		Generate()
	end
end

function love.draw()

	love.graphics.print("Score: " .. math.floor(score))
	love.graphics.print("Lives: " .. lives, 0, 25)
	love.graphics.print("Difficulty: " .. difficulty, 0, 50)
	love.graphics.print("Bonus comes in: " .. math.floor(bonusDelay), 0, 75)



	if isLoose then
		love.graphics.print("You loose!", 690, 380)
	end

	love.graphics.setColor(0, 150, 0)	
	love.graphics.rectangle("fill", rectX, rectY, rectW, rectH)

	for k, v in pairs(enemyList) do
		love.graphics.setColor(v.r, v.g, v.b)
		love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
	end
	for a, b in pairs(bonusList) do
		for k,v in pairs(b) do
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(v, 0, 100)

		love.graphics.setColor(v.r, v.g, v.b)
		love.graphics.circle("fill", v.x, v.y, v.rad)
		love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
	end
	end

end

function checkBoundaries()

	if rectX < 0 then
		rectX = 0
	end
	if rectX + 100 > 1280 then
		rectX = 1180
	end
	if rectY < 0 then
		rectY = 0
	end
	if rectY > 620 then
		rectY = 620 
	end
end

function Loose()
	isLoose = true
	-- 
end

function enemyUpdate()
	for k, v in pairs(enemyList) do
		if checkCollision(v.x, v.y, v.w, v.h, rectX, rectY, rectW, rectH) then
			if lives == 0 then
				Loose()
			else
				lives = lives - 1
				table.remove(enemyList, k)
			end
		end

		if v.x + v.w > 0 and not isLoose then
			v.x = v.x - enemySpeed
		else
			table.remove(enemyList, k)
		end
	end
end
function generateEnemy()
	if #enemyList < difficulty and not isLoose and enemyDelay >= 0.3 then
		enemyDelay = 0
		enemy = {
			w = math.random(25, 100),
			h = math.random(25, 100),

			x = 1380,
			y = math.random(0, 620),

			r = math.random(150, 255),
			g = math.random(150, 255),
			b = math.random(150, 255)
		}
		enemyList[#enemyList + 1] = enemy
	end
end

function assignBonus()
	bonusCacheList = {

		shrink = {
			w = 25,
			h = 25,
			rad = 25,

			x = 1380,
			y = math.random(0, 620),

			r = math.random(150, 255),
			g = math.random(150, 255),
			b = math.random(150, 255),

			action = "shrink"
		},

		aegis = {
			w = 25,
			h = 25,
			rad = 25,

			x = 1380,
			y = math.random(0, 620),

			r = math.random(150, 255),
			g = math.random(150, 255),
			b = math.random(150, 255),

			action = "aegis"
		}

	}
end
function generateBonus()
	if not isLoose then
		bonusDelay = math.random(5, 10)
		bonusList[#bonusList + 1] = bonusCacheList[math.random(#bonusCacheList)]
		-- bonusList[#bonusList + 1] = 1
	end
end
function bonusUpdate()
	for a, b in pairs(bonusList) do
		for k,v in pairs(b) do
			if checkCollision(v.x, v.y, v.w - v.x/2, v.h - v.y/2, rectX, rectY, rectW, rectH) then

				table.remove(bonusList, k)
			end

			if v.x + v.w > 0 and not isLoose then
				v.x = v.x - enemySpeed
			else
				table.remove(bonusList, k)
			end
		end
	end
end


function movePlayer()
	if not isLoose then
		if love.keyboard.isDown("w") then
			rectY = rectY - sensivity
		end
		if love.keyboard.isDown("s") then
			rectY = rectY + sensivity
		end
		if love.keyboard.isDown("a") then
			rectX = rectX - sensivity
		end
		if love.keyboard.isDown("d") then
			rectX = rectX + sensivity
		end

		local touches = love.touch.getTouches()
		
		for i, id in ipairs(touches) do
		    local tx, ty = love.touch.getPosition(id)
		    -- love.graphics.circle("fill", x, y, 20)
		    rectX = tx - 50
		    rectY = ty - 50
		end
	end
end