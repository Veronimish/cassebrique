-- Définition de la balle et de ses fonctions
local balle = {
	x		= 200,
	y		= 500,
    radius	= 10,
    vx		= 700,	-- Vitesse en X (vitesse horizontale)
    vy		= 700	-- Vitesse en Y (vitesse verticale)
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

balle.rebondis = function( decalageX, decalageY )
	local decalage_minimum = math.min(		-- nous déterminons quelle est la valeur la plus petite
				math.abs( decalageX ),		-- entre decalageX et decalageY
				math.abs( decalageY )
			)
			   
	if math.abs( decalageX ) == decalage_minimum then	-- Si la plus petite est decalageX
		decalageY = 0									-- alors decalageY = 0
	else
		decalageX = 0									-- Sinon decalageX = 0
	end
	
	balle.x = balle.x + decalageX		-- on ajoute decalageX à balle.x
	balle.y = balle.y + decalageY		-- on ajoute decalageY à balle.y
   
	if decalageX ~= 0 then
		balle.vx = -balle.vx			-- Si decalageX différent de 0 alors on inverse balle.vx
	end
	if decalageY ~= 0 then
		balle.vy  = -balle.vy			-- Si decalageY différent de 0 alors on inverse balle.vy
	end
end

balle.repositionne = function ()
	balle.x = 200
	balle.y = 500   
end


-- Définition de la raquette et de ses fonctions
local raquette = {
	x		= 500,
	y		= 500,
	width	= 70,
	height	= 20,
	vx		= 500,	-- Vitesse en X (vitesse horizontale)
}

raquette.update = function(dt) -- Nous récupérons le deltaTime
   if love.keyboard.isDown("right") then
      raquette.x = raquette.x + (raquette.vx * dt)
   end
   
   if love.keyboard.isDown("left") then
      raquette.x = raquette.x - (raquette.vx * dt)
   end
end

raquette.rebondis = function ( decalageX )
	raquette.x = raquette.x + decalageX
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
	width			= 50,		-- largeur d'une brique
	height			= 30,		-- hauteur d'une brique
	plusDeBriques	= false;	-- Si true alors le niveau est vide
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

briques.touchee = function( index )
   table.remove( briques.niveau_courant, index )
end

briques.preparerNiveau = function( niveau )
	briques.plusDeBriques = false;
	for index_ligne, ligne in ipairs(niveau) do
		for colonne_index, colonne in ipairs(ligne) do
			if colonne ~= 0 then
				local brique = {}
				brique.x =	briques.origineX +
							( colonne_index - 1 ) *
							( briques.width + briques.decalageX )
				brique.y = briques.origineY +
							( index_ligne - 1 ) *
							( briques.height + briques.decalageY )
				brique.width = briques.width
				brique.height = briques.height
				briques.add( brique )
			end
		end      
	end   
end

briques.update = function( dt )
	if #briques.niveau_courant == 0 then
		briques.plusDeBriques = true
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
	local decalageX, decalageY = 0, 0
	if not (	rectangle1.x + rectangle1.width < rectangle2.x or
			rectangle2.x + rectangle2.width < rectangle1.x or
			rectangle1.y + rectangle1.height < rectangle2.y or 
			rectangle2.y + rectangle2.height < rectangle1.y ) then
		collision = true

		if ( rectangle1.x + rectangle1.width / 2 ) < ( rectangle2.x + rectangle2.width / 2 ) then
			decalageX = ( rectangle1.x + rectangle1.width ) - rectangle2.x
		else 
			decalageX = rectangle1.x - ( rectangle2.x + rectangle2.width )
		end
		if ( rectangle1.y + rectangle1.height / 2 ) < ( rectangle2.y + rectangle2.height / 2 ) then
			decalageY = ( rectangle1.y + rectangle1.height ) - rectangle2.y
		else
			decalageY = rectangle1.y - ( rectangle2.y + rectangle2.height )      
		end      
	end
	return collision, decalageX, decalageY
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
	
	local collision, decalageX, decalageY = collisions.CollisionRectangles( rectangle1, rectangle2 )
	if collision then
		balle.rebondis( decalageX, decalageY )
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
		local collision, decalageX, decalageY = 
				collisions.CollisionRectangles( rectangle1, rectangle2 )
		if collision then
			balle.rebondis( decalageX, decalageY )
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
	
	for index, brique in pairs( briques.niveau_courant ) do
		local rectangle1 = {
			x		= brique.x,
			y		= brique.y,
			width	= brique.width,
			height	= brique.height 
		}
		local collision, decalageX, decalageY = 
				collisions.CollisionRectangles( rectangle1, rectangle2 )
		if collision then
			balle.rebondis( decalageX, decalageY )
			briques.touchee( index )
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

		local collision, decalageX = 
				collisions.CollisionRectangles( rectangle1, raquette )
	  
 		if collision then
			raquette.rebondis( decalageX)
		end      
	end
end

collisions.tester_collisions = function()
	collisions.balle_Raquette( balle, raquette )
	collisions.balle_murs( balle, murs )
	collisions.balle_briques( balle, briques )
	collisions.raquette_murs( raquette, murs )
end

-- Niveaux
local niveaux = {
	courant	= 1,
	jeuFini	= false,
	liste = {
		[1] = {
				{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
				{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
				{ 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1 },
				{ 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1 },
				{ 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0 },
				{ 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0 },
				{ 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0 },
				{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
		},
		[2] = {
				{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
				{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
				{ 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1 },
				{ 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0 },
				{ 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0 },
				{ 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0 },
				{ 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1 },
				{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
		}
	}
}

niveaux.suivant = function( briques )
	if briques.plusDeBriques then
		if niveaux.courant < #niveaux.liste then
			niveaux.courant = niveaux.courant + 1
			briques.preparerNiveau(niveaux.liste[niveaux.courant])
			balle.repositionne()
		else
			niveaux.jeuFini = true
		end
	end
end


function love.load()   
	briques.preparerNiveau(niveaux.liste[niveaux.courant])
	murs.preparerMurs()
end

function love.update(dt)
	balle.update(dt)	-- Nous fournissons le deltaTime
	raquette.update(dt)	-- au fonctions update des objets
	collisions.tester_collisions()
	briques.update(dt)
	niveaux.suivant( briques )
end

function love.draw()
	balle.draw()		-- nous utilisons les fonctions draw
	raquette.draw()		-- des objets.
	briques.draw()
	murs.draw()
	if niveaux.jeuFini then
		love.graphics.printf( "Félicitations!\n" ..
							  "Vous avez fini le jeu!",
							300, 250, 200, "center" )
	else
   end
end
