functor
import
   Application
   OS
   QTk at 'x-oz://system/wp/QTk.ozf'

   % Our functors
   Config

export
   /* Variables */
   Desc
   Grid
   GridHandle

   /* Procedures */
   InitLayout % initialize layout and bind keys to player

   DrawCell % update a cell image
   DrawCellBis % update a cell image for a player
   
   UpdateBulletsCount % update bullets count for GUI
   UpdateCollectedItemsCount % update collected items count for GUI
   UpdateMovesCount % update moves left for GUI
   UpdateGoalCount % update the total number of items to collect

   EndOfGame % closes the window game and shows the issue

define
   
   % Current working directory
   CD = {OS.getCWD}#'/images'
   
   /* Images */
   % Standard
   Bullets = {QTk.newImage photo(file:CD#'/floor_bullet.gif')}
   Floor = {QTk.newImage photo(file:CD#'/floor.gif')}
   Food = {QTk.newImage photo(file:CD#'/floor_food.gif')}
   Medicine = {QTk.newImage photo(file:CD#'/floor_pills.gif')}
   Wall = {QTk.newImage photo(file:CD#'/wall.gif')}

   Door = {QTk.newImage photo(file:CD#'/door.gif')}
   Unknown = {QTk.newImage photo(file:CD#'/unknown.gif')}

   Youwin =  {QTk.newImage photo(file:CD#'/youwin.gif')}
   Gameover =  {QTk.newImage photo(file:CD#'/gameover.gif')}
   Steps =  {QTk.newImage photo(file:CD#'/steps.gif')}
   Basket =  {QTk.newImage photo(file:CD#'/basket.gif')}
   
   % The zombies
   ZombieBurn = {QTk.newImage photo(file:CD#'/unknown.gif')}
   
   ZombieHaut = {QTk.newImage photo(file:CD#'/ZombieHaut.gif')}
   ZombieBas = {QTk.newImage photo(file:CD#'/ZombieBas.gif')}
   ZombieGauche = {QTk.newImage photo(file:CD#'/ZombieGauche.gif')}
   ZombieDroite = {QTk.newImage photo(file:CD#'/ZombieDroite.gif')}

   BulletsZombieHaut = {QTk.newImage photo(file:CD#'/ZombieHautBullet.gif')}
   BulletsZombieBas = {QTk.newImage photo(file:CD#'/ZombieBasBullet.gif')}
   BulletsZombieGauche = {QTk.newImage photo(file:CD#'/ZombieGaucheBullet.gif')}
   BulletsZombieDroite = {QTk.newImage photo(file:CD#'/ZombieDroiteBullet.gif')}

   FoodZombieHaut = {QTk.newImage photo(file:CD#'/ZombieHautFood.gif')}
   FoodZombieBas = {QTk.newImage photo(file:CD#'/ZombieBasFood.gif')}
   FoodZombieGauche = {QTk.newImage photo(file:CD#'/ZombieGaucheFood.gif')}
   FoodZombieDroite = {QTk.newImage photo(file:CD#'/ZombieDroiteFood.gif')}

   MedicineZombieHaut = {QTk.newImage photo(file:CD#'/ZombieHautMedicine.gif')}
   MedicineZombieBas = {QTk.newImage photo(file:CD#'/ZombieBasMedicine.gif')}
   MedicineZombieGauche = {QTk.newImage photo(file:CD#'/ZombieGaucheMedicine.gif')}
   MedicineZombieDroite = {QTk.newImage photo(file:CD#'/ZombieDroiteMedicine.gif')}

   % The brave
   BraveHaut = {QTk.newImage photo(file:CD#'/BraveHaut.gif')}
   BraveBas = {QTk.newImage photo(file:CD#'/BraveBas.gif')}
   BraveGauche = {QTk.newImage photo(file:CD#'/BraveGauche.gif')}
   BraveDroite = {QTk.newImage photo(file:CD#'/BraveDroite.gif')}

   BulletsBraveHaut = {QTk.newImage photo(file:CD#'/BraveHautBullet.gif')}
   BulletsBraveBas = {QTk.newImage photo(file:CD#'/BraveBasBullet.gif')}
   BulletsBraveGauche = {QTk.newImage photo(file:CD#'/BraveGaucheBullet.gif')}
   BulletsBraveDroite = {QTk.newImage photo(file:CD#'/BraveDroiteBullet.gif')}

   FoodBraveHaut = {QTk.newImage photo(file:CD#'/BraveHautFood.gif')}
   FoodBraveBas = {QTk.newImage photo(file:CD#'/BraveBasFood.gif')}
   FoodBraveGauche = {QTk.newImage photo(file:CD#'/BraveGaucheFood.gif')}
   FoodBraveDroite = {QTk.newImage photo(file:CD#'/BraveDroiteFood.gif')}

   MedicineBraveHaut = {QTk.newImage photo(file:CD#'/BraveHautMedicine.gif')}
   MedicineBraveBas = {QTk.newImage photo(file:CD#'/BraveBasMedicine.gif')}
   MedicineBraveGauche = {QTk.newImage photo(file:CD#'/BraveGaucheMedicine.gif')}
   MedicineBraveDroite = {QTk.newImage photo(file:CD#'/BraveDroiteMedicine.gif')}

   Grid
   
   % GUI handles
   GridHandle % grid handler
   MovesCountHandle % handler to display the number of moves left
   BulletsCountHandle % handler to display the number of bullets left
   ItemsCountHandle % handler to display the number of collected items
   GoalHandle % handler to display the total number of items to collect
   FoodCountHandle % handler todisplay the number of collected foods
   MedCountHandle % handler todisplay the number of collected medicines
   
   % Layout description
   Desc = lr(Grid % Map

	     tdspace(width:20 glue:w)
		
	     td(% Information about the game
		lrspace(width:20 glue:w)
		message(aspect:200
			init:"Use the arrow keys to move around and the space bar to pick up items.
			Watch out for the zombies, they move fast!"
				     glue:nw)

		lrspace(width:20 glue:w)
		lrline(glue:ew)
		lr(label(image:Steps)
		   label(text:"Moves left : ")
		   label(init:Config.nAllowedMovesB handle:MovesCountHandle)
		   glue:nw)		   
		lrline(glue:ew)
		lr(label(image:Bullets)
		   label(text:"Arrows left : ")
		   label(init:Config.nBullets handle:BulletsCountHandle)
		   glue:nw)		   
		lrline(glue:ew)
		lr(label(image:Food)
		   label(text:"Food : ")
		   label(init:0 handle:FoodCountHandle)
		   glue:nw)
		lr(label(image:Medicine)
		   label(text:"Medicine : ")
		   label(init:0 handle:MedCountHandle)
		   glue:nw)		   
		lr(label(image:Basket)
		   label(text:"Collected items : ")
		   label(init:0 handle:ItemsCountHandle)
		   label(text:"/")
		   label(init:0 handle:GoalHandle)
		   glue:nw)
		lrline(glue:ew)
		lrspace(width:50 glue:w)
		  
		button(% Quit button
		       text:"Quit        "  
		       action: proc {$} {Application.exit 0} end
		       glue:s)
	       )
	     
	     tdspace(width:20 glue:w)
	    )

   % Transforms a number to the corresponding GUI image
   fun {NumberToImage Number}
      if Number == 0 then Floor
      elseif Number == 1 then Wall
      elseif Number == 2 then Bullets
      elseif Number == 3 then Food
      elseif Number == 4 then Medicine
      elseif Number == 5 then Door
      elseif Number == zombieburn then ZombieBurn
      else Unknown
      end
   end

   % Sets up a cell with an image, given a certain number
   proc {DrawCell Number Y X}
      Image = {NumberToImage Number}
   in
      {GridHandle.Y.X set(image:Image)} 
   end

   % Sets up a cell with an image for a player, given a certain direction
   proc {DrawCellBis Item Number Y X F}
      Image
   in
      if Number == zombie then
	 if Item == 0 then
	    if F == [~1 0] then Image = ZombieHaut
	    elseif F == [1 0] then Image = ZombieBas
	    elseif F == [0 1] then Image = ZombieDroite
	    else Image = ZombieGauche end
	 elseif Item == 2 then
	    if F == [~1 0] then Image = BulletsZombieHaut
	    elseif F == [1 0] then Image = BulletsZombieBas
	    elseif F == [0 1] then Image = BulletsZombieDroite
	    else Image = BulletsZombieGauche end
	 elseif Item == 3 then
	    if F == [~1 0] then Image = FoodZombieHaut
	    elseif F == [1 0] then Image = FoodZombieBas
	    elseif F == [0 1] then Image = FoodZombieDroite
	    else Image = FoodZombieGauche end
	 elseif Item == 4 then
	    if F == [~1 0] then Image = MedicineZombieHaut
	    elseif F == [1 0] then Image = MedicineZombieBas
	    elseif F == [0 1] then Image = MedicineZombieDroite
	    else Image = MedicineZombieGauche end
	 end
      elseif Number == brave then
	 if Item == 0 then
	    if F == [~1 0] then Image = BraveHaut
	    elseif F == [1 0] then Image = BraveBas
	    elseif F == [0 1] then Image = BraveDroite
	    else Image = BraveGauche end
	 elseif Item == 2 then
	    if F == [~1 0] then Image = BulletsBraveHaut
	    elseif F == [1 0] then Image = BulletsBraveBas
	    elseif F == [0 1] then Image = BulletsBraveDroite
	    else Image = BulletsBraveGauche end
	 elseif Item == 3 then
	    if F == [~1 0] then Image = FoodBraveHaut
	    elseif F == [1 0] then Image = FoodBraveBas
	    elseif F == [0 1] then Image = FoodBraveDroite
	    else Image = FoodBraveGauche end
	 elseif Item == 4 then
	    if F == [~1 0] then Image = MedicineBraveHaut
	    elseif F == [1 0] then Image = MedicineBraveBas
	    elseif F == [0 1] then Image = MedicineBraveDroite
	    else Image = MedicineBraveGauche end
	 end
      end
      {GridHandle.Y.X set(image:Image)} 
   end
      

   % Sets the bullet count
   proc {UpdateBulletsCount NewNumberOfBullets}
      {BulletsCountHandle set(NewNumberOfBullets)}
   end

   % Sets thegoal count
   proc {UpdateGoalCount Goal}
      {GoalHandle set(Goal)}
   end

   % Sets the collected items count
   proc {UpdateCollectedItemsCount NewTotal NewNumber OfWhat}
      case OfWhat
      of 3 then % food
	 {FoodCountHandle set(NewNumber)}
      [] 4 then
	 {MedCountHandle set(NewNumber)}
      else
	 skip
      end
      {ItemsCountHandle set(NewTotal)}
   end

   % Sets the number of moves left
   proc {UpdateMovesCount NewNumberOfMoves}
      {MovesCountHandle set(NewNumberOfMoves)}
   end

   % Sets actions for the arrow keys
   proc {BindArrowKeysToPlayer Window BravePort}
      {Window bind(event:"<Up>" action:proc{$} {Send BravePort move([~1 0])} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send BravePort move([0 ~1])} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send BravePort move([1 0])}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send BravePort move([0 1])} end)}
      {Window bind(event:"<space>" action:proc{$} {Send BravePort pickup} end)}
   end

   % Sets up the initial map from a tuple			      
   proc {InitLayout Map Window BravePort ?Grid ?GridHandle}
      Lines = {Width Map}
      Columns = {Width Map.Lines}
   in
      Grid = {MakeTuple td {Width Map}}
      GridHandle = {MakeTuple td {Width Map}}
      if Lines == 0 orelse Columns == 0 then skip
      else
	 for I in 1..Lines do
	    Line = {MakeTuple lr Columns}
	    LineHandle = {MakeTuple lr Columns} in
	    for J in 1..Columns do
	       Image = {NumberToImage Map.I.J} in
	       Line.J = label(image:Image handle:LineHandle.J)
	    end
	    Grid.I = Line
	    GridHandle.I = LineHandle
	 end
      end
      % bind arrow keys
      thread {BindArrowKeysToPlayer Window BravePort} end
   end

   % Sets the GUI for an end of game
   proc {EndOfGame Issue}
      NewDesc NewWin Image Text in
      case Issue
      of win then
	 Image = Youwin
	 Text = 'You win !'
      else
	 Image = Gameover
	 Text = 'Game over...'
      end
	 
      NewDesc = td(label(image: Image)
		      button(
			 text:"Quit"
			 action: proc {$} {Application.exit 0} end
			 glue:s)
		     )
      NewWin = {QTk.build NewDesc}
      {NewWin set(title:Text)}
      {NewWin show}
      {Delay 5000}
      {NewWin close}
   end
end
