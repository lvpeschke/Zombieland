declare
QTk
[QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

local

   %% CONFIG
   PLAYER_MAXSTEP = 2 % number of steps the player can take in a turn
   BULLETS_INIT = 3 % initial number of bullets

   % Current working directory
   CD CD2
   {OS.getCWD CD}
   CD2 = {OS.getCWD}
   {Show CD} % print CD to emulator'
   {Show CD2}

   % Images (IL FAUT LES METTRE DANS /Users/Melanie pour que ça marche!!!)
   Brave = {QTk.newImage photo(file:CD#'/brave.gif')}
   Bullets = {QTk.newImage photo(file:CD#'/bullets.gif')}
   Floor = {QTk.newImage photo(file:CD#'/floor.gif')}
   Food = {QTk.newImage photo(file:CD#'/food.gif')}
   Medicine = {QTk.newImage photo(file:CD#'/medicine.gif')}
   Wall = {QTk.newImage photo(file:CD#'/wall.gif')}
   Zombie = {QTk.newImage photo(file:CD#'/zombie.gif')}

   % GUI
   GridHandle % grid handler
   MovesCountHandle % handler to display the nr of moves left
   BulletsCountHandle % handler to display the number of bullets left
   ItemsCountHandle % handler to display the number of collected items
   Desc = lr(
	     grid(
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Floor) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline
		  
		label(image:Wall) label(image:Floor) label(image:Bullets) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Bullets) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Food) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Food) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Medicine) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Wall) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Wall) label(image:Floor) label(image:Floor)
		label(image:Floor) label(image:Floor) label(image:Medicine) label(image:Floor) label(image:Wall) newline

		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)
		label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall) label(image:Wall)

		handle:GridHandle
		)
	     td(
		lr(label(text:"Moves left : ") label(init:"2"handle:MovesCountHandle) glue:nw)
		lr(label(text:"Bullets left : ") label(init:BULLETS_INIT handle:BulletsCountHandle) glue:nw)
		lr(label(text:"Items collected : ") label(init:"0" handle:ItemsCountHandle) glue:nw)
		button(text:"Quitter le jeu" action:toplevel#close glue:s)
		)
	     )

   % Build the GUI
   Window = {QTk.build td(Desc)}
   {Window set(title:"ZOMBIELAND")}

   % Port for the player (user)
   Player
   PlayerPort = {NewPort Player}

   % Sets actions for the arrow keys
   {Window bind(event:"<Up>" action:proc{$} {Send PlayerPort r(~1 0)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send PlayerPort r(0 ~1)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send PlayerPort r(1 0)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send PlayerPort r(0 1)} end)}
   {Window bind(event:"<space>" action:proc{$} {Send PlayerPort finish} end)}
  
   % Load function for the map (not yet used)
  /* declare
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

   MapEmpty = {LoadPickle '/Users/Victoria/map_test.ozp'}*/

   % Map file
   %Pickle = {LoadPickle "http://icampus.uclouvain.be/claroline/backends/download.php?url=L1Byb2plY3QyMDE0TWF5L2V4YW1wbGVfY29kZS9tYXBfdGVzdC5venA%3D&cidReset=true&cidReq=INGI1131/map_test.ozp"}
   %Pickle = {LoadPickle "file:///Users/Victoria/git/Zombieland/example_code/map_test.ozp"}

   % Sets up a cell with an image
   proc {DrawCell Image X Y}
      {GridHandle configure(label(image:Image)
			    row:X
			    column:Y)}
   end

   % Sets the bullet count
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

   

  /* % Initializes the layout
   proc {InitLayout Map}
      ... % TODO
   end*/

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
	       {DrawCell Floor X Y}
	       {DrawCell Brave NX NY}
	       {UpdateMovesCount Count-1}
	       {User T Count-1 NX NY Xs Ys}
	    end
	 [] finish|T then
	    {UpdateMovesCount PLAYER_MAXSTEP}
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
   {Window show}
   
   %{Delay 1000}
   %{DrawCell Wall 1 7} % test pour changer une cellule
   %{Grid configure(label(text:"5") column:2 row:2)}
   %{Grid configure(label(text:"0" bg:white)
   %column:1 columnspan:3 row:4 sticky:we)}

   % Start game
   {DrawCell Brave 1 7}
   {Game 1 7 Player}
end