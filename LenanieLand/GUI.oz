functor
import
   Application
   OS
   QTk at 'x-oz://system/wp/QTk.ozf'
   System

   % Our functors
   Config

export
   /* Variables */
   Window
   Desc % GUI description
   Grid
   GridHandle

   /* Procedures */
   InitLayout % initialize layout and bind keys to player
   
   DrawCell % update a cell image
   
   UpdateBulletsCount % update bullets count for GUI
   %UpdateItemsCount % update collected items count for GUI %% ENlEVER
   UpdateCollectedItemsCount % update collected items count for GUI
   UpdateMovesCount % update moves left for GUI

   EndOfGame % closes the window game and shows the issue

define
   
   % Current working directory
   CD = {OS.getCWD}#'/images2'
   
   % Images
   Brave = {QTk.newImage photo(file:CD#'/floor_merida_right.gif')} %%
   Bullets = {QTk.newImage photo(file:CD#'/floor_arrows.gif')}
   Floor = {QTk.newImage photo(file:CD#'/floor.gif')}
   Food = {QTk.newImage photo(file:CD#'/floor_food.gif')}
   Medicine = {QTk.newImage photo(file:CD#'/floor_pills.gif')}
   Wall = {QTk.newImage photo(file:CD#'/wall.gif')}
   Zombie = {QTk.newImage photo(file:CD#'/floor_bear_left.gif')} %%
   Door = {QTk.newImage photo(file:CD#'/door.gif')}
   Unknown = {QTk.newImage photo(file:CD#'/unknown.gif')}

   Youwin =  {QTk.newImage photo(file:CD#'/youwin.gif')}
   Gameover =  {QTk.newImage photo(file:CD#'/gameover.gif')}
   Steps =  {QTk.newImage photo(file:CD#'/steps.gif')}
   Basket =  {QTk.newImage photo(file:CD#'/basket.gif')}
   
   /** AJOUTER **/
   %Brave + Food
   %Brave + Medicine
   %Brave + Bullets
   %Zombie + Food
   %Zombie + Medicine
   %Zombie + Bullets
   % Food, Med, Bull alone

   Window
   Grid
   
   % GUI handles
   GridHandle % grid handler
   MovesCountHandle % handler to display the number of moves left
   BulletsCountHandle % handler to display the number of bullets left
   ItemsCountHandle % handler to display the number of collected items
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
		   label(text:"/ "#Config.nWantedObjects)
		   glue:nw)
		lrline(glue:ew)
		lrspace(width:50 glue:w)
		  
		button(% Quit button
		       text:"Surrender"  
		       action: proc {$} {Application.exit 0} end
		       glue:s)
	       )
	     
	     tdspace(width:20 glue:w)
	    )

   % Transforms a number to the corresponding GUI image
   fun {NumberToImage Number} %% A METTRE A JOUR
      if Number == 0 then Floor
      elseif Number == 1 then Wall
      elseif Number == 2 then Bullets
      elseif Number == 3 then Food
      elseif Number == 4 then Medicine
      elseif Number == 5 then Door
      elseif Number == brave then Brave
      elseif Number == zombie then Zombie
      else Unknown
      end
   end

   % Sets up a cell with an image, given a certain number
   proc {DrawCell Number Y X}
      Image = {NumberToImage Number}
   in
      {GridHandle.Y.X set(image:Image)} 
   end

   % Sets the bullet count
   proc {UpdateBulletsCount NewNumberOfBullets}
      {BulletsCountHandle set(NewNumberOfBullets)}
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
      {Window bind(event:"<Up>" action:proc{$} {Send BravePort move([~1 0])} end)} %%% TODO VERIFIER LES MESSAGES
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
   proc {EndOfGame Issue WinToClose}
      {WinToClose close}
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
		   lr(button(
			 text:"New game ?"  
			 action: proc {$} {NewWin close} end %%
			 glue:s)
		      button(
			 text:"Quit"
			 action: proc {$} {Application.exit 0} end
			 glue:s)
		     ))
      NewWin = {QTk.build NewDesc}
      {NewWin set(title:Text)}
      {NewWin show}
   end
end
