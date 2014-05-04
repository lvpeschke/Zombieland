functor
import
   Application
   OS
   QTk at 'x-oz://system/wp/QTk.ozf'
   System

   % For file reading
   %Open
   %Pickle

   % Our functors
   Config

export
   Window % the GUI

   InitLayout % initialize layout and bind keys to player
   
   DrawCell % update a cell image
   UpdateBulletsCount % update bullets count for GUI
   UpdateItemsCount % update collected items count for GUI
   UpdateMovesCount % update moves left for GUI

define
   % Current working directory
   CD = {OS.getCWD}#'/images'
   
   % Images
   Brave = {QTk.newImage photo(file:CD#'/brave.gif')}
   Bullets = {QTk.newImage photo(file:CD#'/bullets.gif')}
   Floor = {QTk.newImage photo(file:CD#'/floor.gif')}
   Food = {QTk.newImage photo(file:CD#'/food.gif')}
   Medicine = {QTk.newImage photo(file:CD#'/medicine.gif')}
   Wall = {QTk.newImage photo(file:CD#'/wall.gif')}
   Zombie = {QTk.newImage photo(file:CD#'/zombie.gif')}
   Unknown = {QTk.newImage photo(file:CD#'/unknown.gif')}
   /** AJOUTER **/
   %Door

   % Example of a map (from file...) /** LOAD REAL MAP AS INPUT **/ %%
   /*MapExample = map(
		r(9 1 1 1 1 1 1 5 1 1 1 1 1 1 1)
		r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
		r(1 3 0 0 0 0 0 0 0 1 2 0 0 0 1)
		r(1 0 0 0 0 0 0 0 4 1 0 0 0 0 1)
		r(1 0 0 0 0 0 0 0 0 1 1 1 0 0 1)
		r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
		r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
		r(1 1 1 0 0 1 1 1 1 1 0 0 0 0 1)
		r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
		r(1 3 0 0 0 0 0 1 4 0 0 0 0 3 1)
		r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
		r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
		r(1 0 0 0 0 0 0 1 2 0 0 0 0 0 1)
		r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
		r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
		   )*/

   % GUI handles
   GridHandle % grid handler
   MovesCountHandle % handler to display the number of moves left
   BulletsCountHandle % handler to display the number of bullets left
   ItemsCountHandle % handler to display the number of collected items
   
   % Layout description
   Desc = td(
	     lr(% Map
		grid(handle:GridHandle)
		td(
		   % Information about the brave
		   lr(label(text:"Moves left : ")
		      label(init:Config.nAllowedMoves handle:MovesCountHandle)
		      glue:nw)
		   lr(label(text:"Bullets left : ")
		      label(init:Config.nBullets handle:BulletsCountHandle)
		      glue:nw)
		   lr(label(text:"Collected items : ")
		      label(init:0 handle:ItemsCountHandle)
		      label(text:"/"#Config.nWantedObjects)
		      glue:nw)
		   % Quit button
		   button(text:"Quit game"
			  action: proc {$} {Application.exit 0} end
			  glue:s)

		   /* Ajouter une légende */
		   /* Ajouter le nombre d'objets souhaités */
		   )
		)
	     )

   % Transforms a number to the corresponding GUI image
   fun {NumberToImage Number} %% A METTRE A JOUR
      if Number == 0 then Floor
      elseif Number == 1 then Wall
      elseif Number == 2 then Bullets
      elseif Number == 3 then Food
      elseif Number == 4 then Medicine
      elseif Number == 5 then Floor %% DOOR
      elseif Number == b then Brave
      elseif Number == z then Zombie
      else Unknown
      end
   end

   % Sets up a cell with an image, given a certain number
   proc {DrawCell Number Y X}
      Image = {NumberToImage Number}
   in
      {GridHandle configure(label(image:Image)
			    row:Y
			    column:X)}
   end

   % Sets the bullet count to
   proc {UpdateBulletsCount NewNumberOfBullets}
      {BulletsCountHandle set(NewNumberOfBullets)}
   end

   % Sets the collected items count
   proc {UpdateItemsCount NewNumberOfItems}
      {ItemsCountHandle set(NewNumberOfItems)}
   end

   % Sets the number of moves left
   proc {UpdateMovesCount NewNumberOfMoves}
      {MovesCountHandle set(NewNumberOfMoves)}
   end

   % Sets actions for the arrow keys %% UPDATE MELANIE
   /*proc {BindArrowKeysToPlayer PlayerPort}
      {Window bind(event:"<Up>" action:proc{$} {Send PlayerPort r(~1 0)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send PlayerPort r(0 ~1)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send PlayerPort r(1 0)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send PlayerPort r(0 1)} end)}
      {Window bind(event:"<space>" action:proc{$} {Send PlayerPort finish} end)}
     end*/
   proc {BindArrowKeysToPlayer Window ServerPort}
      {Window bind(event:"<Up>" action:proc{$} {Send ServerPort brave(move([~1 0]))} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send ServerPort brave(move([0 ~1]))} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send ServerPort brave(move([1 0]))}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send ServerPort brave(move([0 1]))} end)}
      {Window bind(event:"<space>" action:proc{$} {Send ServerPort brave(pickup)} end)}
   end
   

   % Sets up the initial map from a tuple
   proc {InitLayout Map Window PlayerPort}
      Lines = {Width Map}
      Columns = {Width Map.Lines}
   in
      if Lines == 0 orelse Columns == 0 then
	 skip
      else           
	 for Y in 1..Lines do
	    for X in 1..Columns do
	       {DrawCell Map.Y.X Y X}
	    end
	 end
	 % bind arrow keys
	 {BindArrowKeysToPlayer Window PlayerPort}
      end     
   end

   % Build the GUI, not yet initialized
   Window = {QTk.build Desc}
   {Window set(title:"ZOMBIELAND")}



   
   
   % Port for the player (user) %% REAL PORT TO BE DECIDED IN GAME
   %Player
   %PlayerPort = {NewPort Player}
   %{InitLayoutGUI MapExample Window PlayerPort} %% ACTUAL MapFile in GAME  
   
   
   % Game controller (test pour voir si les autres fonctions marchent) %% SEE GAME
   /*proc {Game OldX OldY Command}
      NewX NewY
      NextCommand

      fun {User Command Count X Y ?Xs ?Ys}
	 NX NY in
	 case Command
	 of r(DX DY)|T then
	    if Count == 0 then % pas de mouvement
	       {User T Count X Y Xs Ys}
	    else
	       NX = X + DX
	       NY = Y + DY
	       {DrawCellGUI 0 X Y}
	       {DrawCellGUI b NX NY}
	       {UpdateMovesCountGUI Count-1}
	       {User T Count-1 NX NY Xs Ys}
	    end
	 [] finish|T then
	    {UpdateMovesCountGUI Config.nAllowedMoves}
	    Xs = X
	    Ys = Y
	    T
	 end
      end
   in
      NextCommand = {User Command Config.nAllowedMoves OldX OldY ?NewX ?NewY}
      {Game NewX NewY NextCommand}
   end*/

   % Display GUI
   %{System.show CD}
   %{Window show} %% IN GAME
   
   %{Delay 1000}
   %{DrawCell Wall 1 7} % test pour changer une cellule
   %{Grid configure(label(text:"5") column:2 row:2)}
   %{Grid configure(label(text:"0" bg:white)
   %column:1 columnspan:3 row:4 sticky:we)}

   % Start game
   %{DrawCellGUI b 1 7} %% IN GAME
   %{Game 1 7 Player} %% IN GAME
end