local balle = {
	x		= 300,
	y		= 300,
    radius	= 10,
	vx		= 300,	-- Vitesse en X (vitesse horizontale)
	vy		= 300	-- Vitesse en Y (vitesse verticale)
}

local raquette = {
	x		= 500,
	y		= 500,
	width	= 70,
	height	= 20,
	vx		= 300,	-- Vitesse en X (vitesse horizontale)
}

local brique = {
	x		= 100,
	y		= 100,
	width	= 50,
	height	= 30
}

function love.update( dt )
   balle.x = balle.x + balle.vx * dt
   balle.y = balle.y + balle.vy * dt
   
   if love.keyboard.isDown("right") then
      raquette.x = raquette.x + (raquette.vx * dt)
   end
   
   if love.keyboard.isDown("left") then
      raquette.x = raquette.x - (raquette.vx * dt)
   end
end

function love.draw()
    love.graphics.circle("line", 
        balle.x, balle.y,
        balle.radius)
    love.graphics.rectangle("line", 
        raquette.x, raquette.y, 
        raquette.width, raquette.height)
	love.graphics.rectangle("line",
    	brique.x, brique.y,
    	brique.width, brique.height)
end