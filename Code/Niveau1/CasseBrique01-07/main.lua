-- Définition de la balle et de ses fonctions
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

-- Définition de la raquette et de ses fonctions
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

-- Définition de la liste de briques et de ses fonctions
local briques = {
	lignes			= 8,		-- 8 lignes de briques
	colonnes		= 11,		-- 11 colonnes de briques
	origineX		= 70,		-- position de départ en X
	origineY		= 50,		-- position de départ en Y
	decalageX		= 10,		-- distance entre les briques en X
	decalageY		= 10,		-- distance entre les briques en Y
	width			= 50,
	height			= 30,
	niveau_courant	= {}
}

briques.new = function( _x, _y, _width, _height )
	return({
            x = _x, 
            y = _y,
            width = _width or briques.width,		-- si width ou height ne sont pas
	     	height = _height or briques.height 		-- renseigné; alors on prend les
        })											-- valeurs de briques.
end

briques.add = function( brique )
	table.insert( briques.niveau_courant, brique )
end

briques.drawBrique = function( brique )
   love.graphics.rectangle( 'line',
			    brique.x,
			    brique.y,
			    brique.width,
			    brique.height 
    	)
end

briques.draw = function()
	for _, brique in pairs( briques.niveau_courant) do
		briques.drawBrique( brique )
	end
end

briques.preparerNiveau = function()
	for ligne = 1, briques.lignes do
		for colonne = 1, briques.colonnes do
			local brique = {}
			brique.x =	briques.origineX +
						( colonne - 1 ) *
						( briques.width + briques.decalageX )
			brique.y = briques.origineY +
						( ligne - 1 ) *
						( briques.height + briques.decalageY )
			brique.width = briques.width
			brique.height = briques.height
			briques.add( brique )
		end      
	end   
end

-- Définition de la liste des murs et de ses fonctions
local murs = {
    epaisseur		= 20,
    niveau_courant	= {}
}

murs.new = function( _x, _y, _width, _height )
	return({
		x		= _x,
		y		= _y,
		width	= _width,
		height	= _height
	})
end

murs.drawMur = function( mur )
	love.graphics.rectangle( 'line',
			    mur.x,
			    mur.y,
			    mur.width,
			    mur.height 
	)
end

murs.preparerMurs = function()
	murs.niveau_courant["left"] = murs.new(
								0, 0, 
								murs.epaisseur, love.graphics.getHeight()
							)
							
	murs.niveau_courant["right"] = murs.new(
								love.graphics.getWidth() - murs.epaisseur, 0,
								murs.epaisseur, love.graphics.getHeight()
							)
							
	murs.niveau_courant["top"] = murs.new(
								0, 0, 
								love.graphics.getWidth(), murs.epaisseur
							)
							
	-- On va aussi en mettre un en bas, nous l'enlèverons plus tard
	murs.niveau_courant["bottom"] = murs.new(
								0, love.graphics.getHeight() - murs.epaisseur, 
								love.graphics.getWidth(), murs.epaisseur
							)
end

murs.draw = function()
	for _, mur in pairs( murs.niveau_courant ) do
		murs.drawMur( mur )
	end
end

-- définition des calculs de collisions
-- Collisions
local collisions = {}

collisions.CollisionRectangles = function( rectangle1, rectangle2 )
   local collision = false
   if not (	rectangle1.x + rectangle1.width < rectangle2.x or
			rectangle2.x + rectangle2.width < rectangle1.x or
			rectangle1.y + rectangle1.height < rectangle2.y or 
			rectangle2.y + rectangle2.height < rectangle1.y ) then
      collision = true
   end
   return collision
end

collisions.balle_Raquette = function( balle, raquette )
	local rectangle1 = {
		x		= raquette.x,
		y		= raquette.y,
		width	= raquette.width,
		height	= raquette.height 
    }
   local rectangle2 = {
		x		= balle.x - balle.radius,
		y		= balle.y - balle.radius,
		width	= 2 * balle.radius,
		height	= 2 * balle.radius 
    }
	if collisions.CollisionRectangles( rectangle1, rectangle2 ) then
		print( "Collision balle-raquette" )
	end      
end

collisions.balle_murs = function( balle, murs )
   local rectangle2 = {
		x		= balle.x - balle.radius,
		y		= balle.y - balle.radius,
		width	= 2 * balle.radius,
		height	= 2 * balle.radius 
    }
	
	for _, mur in pairs( murs.niveau_courant ) do
		local rectangle1 = {
			x		= mur.x,
			y		= mur.y,
			width	= mur.width,
			height	= mur.height 
		}
		if collisions.CollisionRectangles( rectangle1, rectangle2 ) then
			print( "Collision balle-mur" )
		end
	end
end

collisions.balle_briques = function( balle, briques )
   local rectangle2 = {
		x		= balle.x - balle.radius,
		y		= balle.y - balle.radius,
		width	= 2 * balle.radius,
		height	= 2 * balle.radius 
    }
	
	for _, brique in pairs( briques.niveau_courant ) do
		local rectangle1 = {
			x		= brique.x,
			y		= brique.y,
			width	= brique.width,
			height	= brique.height 
		}
		if collisions.CollisionRectangles( rectangle1, rectangle2 ) then
			print( "Collision balle-brique" )
		end
	end
end

collisions.raquette_murs = function( raquette, murs )
	for _, mur in pairs( murs.niveau_courant ) do
		local rectangle1 = {
			x		= mur.x,
			y		= mur.y,
			width	= mur.width,
			height	= mur.height 
		}
		if collisions.CollisionRectangles( rectangle1, raquette ) then
			print( "Collision raquette-mur" )
		end
	end
end

collisions.tester_collisions = function()
	collisions.balle_Raquette( balle, raquette )
	collisions.balle_murs( balle, murs )
	collisions.balle_briques( balle, briques )
	collisions.raquette_murs( raquette, murs )
end

function love.load()   
	briques.preparerNiveau()
	murs.preparerMurs()
end

function love.update(dt)
	balle.update(dt)	-- Nous fournissons le deltaTime
	raquette.update(dt)	-- au fonctions update des objets
	collisions.tester_collisions()
end

function love.draw()
	balle.draw()		-- nous utilisons les fonctions draw
	raquette.draw()		-- des objets.
	briques.draw()
	murs.draw()
end
