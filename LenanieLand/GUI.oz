functor
import
   Application
   System
   OS
   Module

   % For file reading : map
   Open
   Pickle

   % Our files
   Config

export
  %?

define
   %% Needed for the GUI
   QTk
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

   %% Import map from file
   % Load function for the map (not yet used)
   fun {LoadPickle URL}
	F = {New Open.file init(url:URL flags:[read])}
     in
	try
	   VBS
	in
	   {F read(size:all list:VBS)}
	   {Pickle.unpack VBS}
	finally
	   {F close}
	end
     end

   % Map tuple
   PickleMap

   %% CONFIG
   PLAYER_MAXSTEP = 2 % number of steps the player can take in a turn
   BULLETS_INIT = 3 % initial number of bullets
   
   % Current working directory
   CD = {OS.getCWD}#'/Images2014'
   % Images
   Brave = {QTk.newImage photo(file:CD#'/brave.gif')}
   Bullets = {QTk.newImage photo(file:CD#'/bullets.gif')}
   Floor = {QTk.newImage photo(file:CD#'/floor.gif')}
   Food = {QTk.newImage photo(file:CD#'/food.gif')}
   Medicine = {QTk.newImage photo(file:CD#'/medicine.gif')}
   Wall = {QTk.newImage photo(file:CD#'/wall.gif')}
   Zombie = {QTk.newImage photo(file:CD#'/zombie.gif')}
   %% AJOUTER
   Door
   Unknown

   %% GUI handles
   GridHandle % grid handler
   MovesCountHandle % handler to display the nr of moves left
   BulletsCountHandle % handler to display the number of bullets left
   ItemsCountHandle % handler to display the number of collected items

   % Example of a map (from file...)
   MapExample = map(
		r(1 1 1 1 1 1 1 5 1 1 1 1 1 1 1)
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
		)

   %% Layout description
   Desc = td(
	     lr(
		% Map
		grid(
		   handle:GridHandle
		   )
		td(
		   % Information about the brave
		   lr(label(text:"Moves left : ") label(init:"2"handle:MovesCountHandle) glue:nw)
		   lr(label(text:"Bullets left : ") label(init:BULLETS_INIT handle:BulletsCountHandle) glue:nw)
		   lr(label(text:"Collected items : ") label(init:"0" handle:ItemsCountHandle) glue:nw)
		   % Quit button
		   button(text:"Quit game" action: proc {$} {Application.exit 0} end glue:s)

		   /* Ajouter une légende */
		   )
		)
	     )		   

   %% Set up the map
   proc {InitLayoutGUI Map}
      Lines = {Width Map}
      Columns = {Width Map.Lines}

      {System.show 'Lines'#Lines}
      {System.show 'Columns'#Columns}
   in     
      for Y in 1..Lines do
	 for X in 1..Columns do
	    {System.show 'Y'#Y#'X'#X}
	    {System.show 'Map.Y.X'#Map.Y.X}
	    {System.show 'image'#{NumberToImageGUI Map.Y.X}}
	    {DrawCellGUI {NumberToImageGUI Map.Y.X} Y X}
	 end
      end
   end

   % Sets up a cell with an image
   proc {DrawCellGUI Image Y X}
      %{System.show 'entered DrawCell with '#Y#X}
      %{Wait GridHandle}
      %{System.show 'GridHandle bound'}
      {GridHandle configure(label(image:Image)
			    row:Y
			    column:X)}
   end

   % Sets the bullet count
   proc {UpdateBulletsCountGUI NewNumberOfBullets}
      {BulletsCountHandle set(NewNumberOfBullets)}
   end

   % Sets the collected items count
   proc {UpdateItemsCountGUI NewNumberOfItems}
      {ItemsCountHandle set(NewNumberOfItems)}
   end

   % Sets the number of moves left
   proc {UpdateMovesCountGUI NewNumberOfMoves}
      {MovesCountHandle set(NewNumberOfMoves)}
   end

   % Transforms a number to the corresponding GUI image
   fun {NumberToImageGUI Number}
      if Number == 0 then Floor
      elseif Number == 1 then Wall
      elseif Number == 2 then Bullets
      elseif Number == 3 then Food
      elseif Number == 4 then Medicine
      elseif Number == 5 then Floor %% DOOR
      else Unknown
      end
   end

   % Build the GUI
   Window = {QTk.build Desc}
   {Window set(title:"ZOMBIELAND")}

   {InitLayoutGUI MapExample} %% ACTUAL MapFile
   

   % Port for the player (user) %% REAL PORT TO BE DECIDED
   Player
   PlayerPort = {NewPort Player}

   % Sets actions for the arrow keys %% REAL PORT TO BE INSERTED
   {Window bind(event:"<Up>" action:proc{$} {Send PlayerPort r(~1 0)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send PlayerPort r(0 ~1)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send PlayerPort r(1 0)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send PlayerPort r(0 1)} end)}
   {Window bind(event:"<space>" action:proc{$} {Send PlayerPort finish} end)}
   
   % Game controller (test pour voir si les autres fonctions marchent)
   proc {Game OldX OldY Command}
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
	       {DrawCellGUI Floor X Y}
	       {DrawCellGUI Brave NX NY}
	       {UpdateMovesCountGUI Count-1}
	       {User T Count-1 NX NY Xs Ys}
	    end
	 [] finish|T then
	    {UpdateMovesCountGUI PLAYER_MAXSTEP}
	    Xs = X
	    Ys = Y
	    T
	 end
      end
   in
      NextCommand = {User Command PLAYER_MAXSTEP OldX OldY ?NewX ?NewY}
      {Game NewX NewY NextCommand}
   end
      
in

   % Display GUI
   {System.show CD}
   {Window show}
   
   %{Delay 1000}
   %{DrawCell Wall 1 7} % test pour changer une cellule
   %{Grid configure(label(text:"5") column:2 row:2)}
   %{Grid configure(label(text:"0" bg:white)
   %column:1 columnspan:3 row:4 sticky:we)}

   % Start game
   {DrawCellGUI Brave 1 7}
   {Game 1 7 Player}
end