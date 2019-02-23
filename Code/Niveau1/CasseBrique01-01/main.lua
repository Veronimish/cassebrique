local balle = {
	x		= 300,
	y		= 300,
    radius	= 10
}

local raquette = {
	x		= 500,
	y		= 500,
	width	= 70,
	height	= 20
}

local brique = {
	x		= 100,
	y		= 100,
	width	= 50,
	height	= 30
}

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