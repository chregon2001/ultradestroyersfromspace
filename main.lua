-- Christian Egon Sørensen ®©
function gameload()
	--Ultra high definition extra reloded special edition
	i=0
	stars = 10
	prevScorInc = 0
	deadliness = 1

	-- random earth coordinates
	ex = math.random(0,x)
	ey = math.random(0,y)

	--image import
	--bg = love.graphics.newImage("space.jpg")

	-- enemy 1 graphic
	en1 = love.graphics.newImage("enemy1.png")

	--initialise music
	bm = love.audio.newSource("Arcade Funk.mp3", "static")
	ach = love.audio.newSource("ach.mp3", "static")
	--bm = love.audio.newSource("broken.mp3", "static")
	bm:setLooping(true)
	bm:play()

	shot = love.audio.newSource("shot.wav", "static")

	--mob vars
	mobs = {}
	mobs.wavetime = 20
	mobs.enemies = {}
	mobs.hpup = {}
	mobs.genEn = function(level)
		if level == 3 then
			enemy = {}
			enemy.level = 3
			enemy.height = 250
			enemy.width = 250
			enemy.x = 800
			enemy.y = math.random(0,y - enemy.height / 2)
			enemy.hp = 1000
			enemy.score = 1000
		elseif level == 2 then
			enemy = {}
			enemy.level = 2
			enemy.height = math.random(1, 500)
			enemy.width = math.random(1, 500)
			enemy.x = 800
			enemy.y = math.random(0,y - enemy.height / 2)
			enemy.hp = 50
			enemy.score = 100
		else
			enemy = {}
			enemy.level = 1
			enemy.height = 20
			enemy.width = 20
			enemy.x = 800
			enemy.y = math.random(0,y - enemy.height / 2)
			enemy.hp = 10
			enemy.score = 10
		end
		table.insert(mobs.enemies, enemy)
	end
	mobs.genHpup = function(hp)
		if hp == 1 then
			hpup = {}
			hpup.height = 20
			hpup.width = 20
			hpup.x = 800
			hpup.y = math.random(0,y - hpup.height / 2)
			hpup.hp = math.random(50,100)
			hpup.type = 1
			table.insert(mobs.hpup, hpup)
		else
			hpup = {}
			hpup.height = 20
			hpup.width = 20
			hpup.x = 800
			hpup.y = math.random(0,y - hpup.height / 2)
			hpup.hp = math.random(50,100)
			hpup.type = 2
			table.insert(mobs.hpup, hpup)
		end
	end

	--gameover image related vars
	gameover = {}
	gameover.x = (x * 0.5) - game_over:getWidth()
	gameover.y = y
	gameover.t = 0
	gameover.isGameover = false

	--player related vars
	player = {}
	player.hp = 100
	player.maxhp = 200
	player.state = 0
	player.score = 0
	player.x = x * 0.5
	player.y = y * 0.5
	player.width = 80
	player.height = 20
	player.bHeight = 5
	player.speed = 50
	player.maxv = 300
	player.vx = 0
	player.vy = 0
	player.friction = 10.5
	player.bullets = {}
	player.cooldown = 0
	player.cooldownThreshold = 50
	player.fire = function()
		bullet = {}
		bullet.width = 60
		bullet.height = player.bHeight
		bullet.x = player.x + player.width / 2
		bullet.y = (player.y + player.height / 2) - bullet.height / 2
		table.insert(player.bullets, bullet)
	end
	player.control = function(dt)
		-- Check user input and map to movement
		player.x = player.x + player.vx
		player.y = player.y + player.vy

		player.vx = player.vx * (1 - math.min(dt*player.friction, 1))
		player.vy = player.vy * (1 - math.min(dt*player.friction, 1))

		if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
			if love.keyboard.isDown("lshift") then
				player.vx = player.vx + (player.speed * dt) * 2
			else
				player.vx = player.vx + (player.speed * dt)
			end
		end
		if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
			if love.keyboard.isDown("lshift") then
				player.vx = player.vx - (player.speed * dt) * 2
			else
				player.vx = player.vx - (player.speed * dt)
			end
		end
		if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
			if love.keyboard.isDown("lshift") then
				player.vy = player.vy + (player.speed * dt) * 2
			else
				player.vy = player.vy + (player.speed * dt)
			end
		end
		if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
			if love.keyboard.isDown("lshift") then
				player.vy = player.vy - (player.speed * dt) * 2
			else
				player.vy = player.vy - (player.speed * dt)
			end
			if player.vx > player.maxv then
				player.vx = player.maxv
			end
			if player.vy > player.maxv then
				player.vy = player.maxv
			end
		end

		-- Fire on space
		if love.keyboard.isDown("space") and gameover.isGameover == false then
			if player.cooldown >= player.cooldownThreshold then
				shot:rewind()
				shot:play()
				player.cooldown = 0
				player.fire()
			end
		end
	end
	player.particles = {}
	player.trail = function()
		particle = {}
		particle.x = player.x
		particle.y = player.y
		table.insert(player.particles, particle)
	end

	-- box collision detection
	-- takes arguments as tables containing width height and xy cords
	function overlap(f,s)
		if f == nil or s == nil then
			return false
		end
		x1 = f.x
		y1 = f.y
		x2 = f.x + f.width
		y2 = f.y
		x3 = f.x
		y3 = f.y + f.height
		x4 = f.x + f.width
		y4 = f.y + f.height

		x5 = s.x
		y5 = s.y
		x6 = s.x + s.width
		y6 = s.y
		x7 = s.x
		y7 = s.y + s.height
		x8 = s.x + s.width
		y8 = s.y + s.height

		if (x2 > x7) and (x1 < x6) and (y3 > y5) and (y1 <  y7) then
			return true
		else
			return false
		end
	end
end
function gameupdate(dt)
	player.control(dt)

	-- end game on 0 hp
	if player.hp <= 0 then

	end

	-- generate play-objects
	if math.random(1,100) < 5 * deadliness then
		mobs.genEn(1)
	end
	if math.random(1,1000) < 5 * deadliness then
		mobs.genEn(2)
	end
	if math.random(1,10000) < 5 * deadliness then
		mobs.genEn(3)
	end
	if math.random(1,1000) < 5 * deadliness then
		mobs.genHpup(1)
	end
	if player.cooldownThreshold ~= 0 then
		if math.random(1,1000) < 5 * deadliness then
			mobs.genHpup(2)
		end
	end

	deadliness = deadliness + 0.025 * dt

	-- make trail, super sheit
	for i=1,10 do
		player.trail()
	end

	-- removal and movement of mobs
	for i,b in ipairs(mobs.enemies) do
    if b.x + b.width < 0 then
      table.remove(mobs.enemies, i)
    end
    --b.x = b.x - math.sin(i)
		if b.x > 700 then
			b.x = b.x - 1
		else
			b.x = b.x - 10
		end
		b.y = b.y + math.sin(b.x)
  end

	-- removal and movement of powerups
	for i,b in ipairs(mobs.hpup) do
		if b.x + b.width < 0 then
			table.remove(mobs.hpup, i)
		end
		--b.x = b.x - math.sin(i)
		b.x = b.x - 3
		b.y = b.y + math.sin(b.x) * 100
	end

	-- control of flame and trail
	for i,b in ipairs(player.particles) do
    if b.x < player.x - 100 then
			if b.x < 0 then
      	table.remove(player.particles, i)
			end
			if math.random() < 0.25 then
      	table.remove(player.particles, i)
			end
    end
    b.x = b.x - 10
		b.y = b.y + (7.5 * (math.sin(b.x) * math.random()))
  end

	-- bullet moval and removal
	for i,b in ipairs(player.bullets) do
    if b.x > x then
      table.remove(player.bullets, i)
    end
    b.x = b.x + 40
		b.y = b.y + math.sin(b.x)
  end

	-- Made if statement to protect from mem erro
	-- resets cooldown
	if player.cooldown < player.cooldownThreshold then
		player.cooldown = player.cooldown + 1
	end
	i=i+10
	if i > 360 then
		i = 0
	end

	-- bound player to screen
	if player.x <= 0 then
		player.x = 0
	end
	if player.y <= 0 then
		player.y = 0
	end
	if player.x + player.width >= x then
		player.x = x - player.width
	end
	if player.y + player.height >= y then
		player.y = y - player.height
	end

	-- bullet collision check
	for i,b in ipairs(player.bullets) do
		for i2,b2 in ipairs(mobs.enemies) do
	    if overlap(b, b2) then
				b2.hp = b2.hp - 10
				if b2.hp <= 0 then
					table.remove(mobs.enemies, i2)
					player.score = player.score + b2.score
				end
				table.remove(player.bullets, i)
			end
	  end
	end

	-- player x mob collision
	for i,b in ipairs(mobs.enemies) do
    if overlap(player, b) then
			table.remove(mobs.enemies, i)
			player.hp = player.hp - 10
		end
  end

	-- powerup collision
	for i,b in ipairs(mobs.hpup) do
    if overlap(player, b) then
			if b.type == 1 then
				player.hp = player.hp + 10
			else
				if player.cooldownThreshold ~= 0 then
					player.cooldownThreshold = player.cooldownThreshold - 1
				end
			end
			player.score = player.score + 10
			table.remove(mobs.hpup, i)
		end
  end

	-- check if hp is over capacity
	-- allowing overload of hp because it's fun af
	if player.hp > player.maxhp then
		player.hp = player.maxhp
	end

	-- change stars depending on player hp
	if player.hp >= 150 and player.hp <= 199 then
		player.bHeight = 10
		player.state = 1
		stars = 25
	elseif player.hp >= 200 then
		player.bHeight = 60
		stars = 50
		player.state = 1
	else
		player.bHeight = 5
		stars = 10
		player.state = 0
	end
	if player.score - 1000 >= prevScorInc then
		prevScorInc = player.score
		ach:rewind()
		ach:play()
	end

	if player.hp <= 0 then
		player.hp = 0
		gameover.isGameover = true
	end
	if gameover.isGameover then
		if gameover.t < 300 then
			gameover.y = gameover.y + 7
			gameover.t = gameover.t + 1
		else
			state="menu"
			love.load()
		end
	end
end

function gamedraw()
	love.graphics.setColor(255, 255, 255)
	--love.graphics.draw(bg,math.random(1, -800),math.random(1, -800))

	--make stars
	love.graphics.setColor(255, 255, 255)
	for i=1,stars do
		if player.state == 1 then
			love.graphics.setColor(math.random(0,255), math.random(0,255), math.random(0,255))
		end
		love.graphics.rectangle("fill", math.random(0,x), math.random(0,y), 5, 5)
	end
	for i=1,stars do
		if player.state == 1 then
			love.graphics.setColor(math.random(0,255), math.random(0,255), math.random(0,255))
		end
		love.graphics.rectangle("fill", math.random(0,x), math.random(0,y), 20, 5)
	end

	-- draw earth
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.draw(earth,ex,ey)

  -- draw bullets
  for _,b in pairs(player.bullets) do
		-- love.graphics.setColor(255, math.random(0, 255), math.random(0, 255))
		love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
  end

	-- draw enemies
	for _,b in pairs(mobs.enemies) do
		if b.level == 0 then
			love.graphics.setColor(105, 105, 105, 255)
			love.graphics.draw(en1, b.x, b.y)
		else
			love.graphics.setColor(105,105 + b.hp,105,255)
	    love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
	end
  end

	-- draw hpups
	for _,b in pairs(mobs.hpup) do
		if b.type == 1 then
			love.graphics.setColor(255,0,0,255)
		elseif b.type == 2 then
			love.graphics.setColor(0,0,255,255)
		end
    love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
  end

	-- draw player
	if gameover.isGameover ~= true then
		love.graphics.setColor(player.hp * 0.775, player.hp * 0.775, player.hp * 0.755)
		-- love.graphics.setColor(255, 255, 255, player.hp * 0.755)
		love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
		--love.graphics.setColor(255, 255, 255)
		--love.graphics.rectangle("line", player.x, player.y, player.width, player.height)

		-- draw trail
	  for _,b in pairs(player.particles) do
			love.graphics.setColor(255 - math.random(0,205), 0, 0)
	    love.graphics.rectangle("fill", b.x, b.y + player.height * 0.35, 10, 10)
	  end
	end

	-- draw overlay
	love.graphics.setColor(155, 155, 255, 255)
	-- love.graphics.print(player.hp .. "% hp\t" .. player.score .. " score\t" .. love.timer.getFPS() .. " fps\t".. deadliness .. " deadliness")
	love.graphics.print(player.score .. " score")

	if gameover.isGameover then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(game_over, x*0.25, y*0.4)
	end
end

firstrun = true

function love.load()
	love.audio.stop()
	--image import
	earth=love.graphics.newImage("8bitearth.png")
	game_over = love.graphics.newImage("game_over.png")
	title = love.graphics.newImage("title.png")
	play = love.graphics.newImage("play.png")

	--initialise music
	mbm = love.audio.newSource("Star Commander1.wav", "static")
	mbm:setLooping(true)

	--important vars
	x,y = love.graphics.getDimensions()
	if firstrun == true then
		state = "menu"
		firstrun = false
		timerator = 0
		gx = {}
		gx.ent = {}
		gx.makeEnt = function (x,y,w,l)
			en = {}
			en.x = x
			en.y = y
			en.width = w
			en.height = l
			table.insert(gx.ent, en)
		end
	end
	if state == "play" then
		gameload()
	elseif state == "menu" then
		mbm:play()
	end
end

function love.update(dt)
	if state == "play" then
		gameupdate(dt)
	elseif state == "menu" then
		if timerator >= 360 then
			timerator = 0
		else
			timerator = timerator + 0.01
		end
		if love.keyboard.isDown("space") then
			state = "play"
			love.load()
	  end
		for i=1,100 do
			gx.makeEnt(math.random(1,x), y, 10, 10)
		end
		for i,b in ipairs(gx.ent) do
			b.x = b.x + (7.5 * (math.sin(b.y) * math.random()))
			b.y = b.y - 5.8
			if b.y <= y - 150 and math.random() < 0.10 then
				table.remove(gx.ent, i)
			end
		end
	end
end

function love.mousepressed(mx, my, button)
   if button == 1
   and mx >= x * 0.35 and mx < x * 0.35 + play:getWidth()
   and my >= y * 0.65 and my < y * 0.65 + play:getHeight() then
		 state = "play"
		 love.load()
   end
end

function love.draw()
	if state == "play" then
		gamedraw()
	elseif state == "menu" then
		for i=1,10 do
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("fill", math.random(0,x), math.random(0,y), 5, 5)
		end
		for i=1,10 do
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("fill", math.random(0,x), math.random(0,y), 5, 20)
		end

		for i,b in ipairs(gx.ent) do
			love.graphics.setColor(math.random(50, 255), 0 , 0, 255)
			love.graphics.rectangle("fill", math.random() *b.x, b.y, b.width, b.height)
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(earth,x*0.25,y*0.25)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(title,((x * 0.5) - (title:getWidth() * 0.35 * 0.5)  + (math.sin(timerator)*x*0.05)), y * 0.1, 0, 0.35, 1.75)

		for i,b in ipairs(gx.ent) do
			love.graphics.setColor(math.random(50, 255), 0 , 0, 255)
			love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
		end

		love.graphics.setColor(50, 0, 0)
		--love.graphics.rectangle("fill", x * 0.36, y * 0.57, 250, 90)
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(play, x * 0.35, y * 0.65)
	end
end
