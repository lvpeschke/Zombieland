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

   %%% Sets up a cell with an image, given a certain number
   proc {DrawCell Number Y X}
      Image = {NumberToImage Number}
   in
      {GridHandle configure(label(image:Image)
			    row:Y
			    column:X)}
   end

   %%% Sets the bullet count to
   proc {UpdateBulletsCount NewNumberOfBullets}
      {BulletsCountHandle set(NewNumberOfBullets)}
   end

   %%% Sets the collected items count
   proc {UpdateItemsCount NewNumberOfItems}
      {ItemsCountHandle set(NewNumberOfItems)}
   end

   %%% Sets the number of moves left
   proc {UpdateMovesCount NewNumberOfMoves}
      {MovesCountHandle set(NewNumberOfMoves)}
      %{System.show 'Moves updated to '#NewNumberOfMoves}
   end

   % Sets actions for the arrow keys
   proc {BindArrowKeysToPlayer Window ServerPort}
      {Window bind(event:"<Up>" action:proc{$} {Send ServerPort brave(move([~1 0]))} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send ServerPort brave(move([0 ~1]))} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send ServerPort brave(move([1 0]))}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send ServerPort brave(move([0 1]))} end)}
      {Window bind(event:"<space>" action:proc{$} {Send ServerPort brave(pickup)} end)}
   end
   

   %%% Sets up the initial map from a tuple
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

   %%% Build the GUI, not yet initialized
   Window = {QTk.build Desc}
   {Window set(title:"ZOMBIELAND")}
end