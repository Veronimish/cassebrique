local balle = {
	x		= 300,
	y		= 300,
    radius	= 10,
    vx		= 300,	-- Vitesse en X (vitesse horizontale)
    vy		= 300	-- Vitesse en Y (vitesse verticale)
}

balle.update = function(dt)	-- Nous récupérons le deltaTime
	balle.x = balle.x + balle.vx * dt
	balle.y = balle.y + balle.vy * dt
end

balle.draw = function()
	love.graphics.circle("line", 
        balle.x, balle.y,
        balle.radius)
end

local raquette = {
	x		= 500,
	y		= 500,
	width	= 70,
	height	= 20,
	vx		= 300,	-- Vitesse en X (vitesse horizontale)
}

raquette.update = function(dt) -- Nous récupérons le deltaTime
   if love.keyboard.isDown("right") then
      raquette.x = raquette.x + (raquette.vx * dt)
   end
   
   if love.keyboard.isDown("left") then
      raquette.x = raquette.x - (raquette.vx * dt)
   end
end

raquette.draw = function()
	love.graphics.rectangle("line", 
        raquette.x, raquette.y, 
        raquette.width, raquette.height)
end

local brique = {
	x		= 100,
	y		= 100,
	width	= 50,
	height	= 30
}

brique.draw = function()
	love.graphics.rectangle("line",
    	brique.x, brique.y,
    	brique.width, brique.height)
end

function love.update(dt)
	balle.update(dt)	-- Nous fournissons le deltaTime
	raquette.update(dt)	-- au fonctions update des objets
end

function love.draw()
	balle.draw()		-- nous utilisons les fonctions draw
	raquette.draw()		-- des objets.
	brique.draw()
end
