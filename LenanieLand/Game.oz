declare
QTk
[QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

local
   %% CONFIG
   BRAVE_MAXSTEP = 2 % number of steps the brave can take in a turn
   BULLETS_INIT = 3 % initial number of bullets
   OBJECTS_WANTED = 3
   X_INIT = 1
   Y_INIT = 7
   F_INIT = [1 0]
   MAP = map(r(1 1 1 1 1 1 5 1 1 1 1 1 1 1 1 1 1 1 1 1)
	  r(1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1)
	  r(1 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	  r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 0 1)
	  r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	  r(1 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 1)
	  r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	  r(1 0 3 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 1)
	  r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	  r(1 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 1)
	  r(1 0 4 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	  r(1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 4 0 1)
	  r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
   ServerPort
   
   %% AFFICHAGE
   % Current working directory
   {OS.chDir '/Users/melaniesedda'}
   CD = {OS.getCWD}
   {Show CD} % print CD to emulator'

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

   %% LISTENERS
   % Sets actions for the arrow keys
   {Window bind(event:"<Up>" action:proc{$} {Send ServerPort brave(move([~1 0]))} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send ServerPort brave(move([0 ~1]))} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send ServerPort brave(move([1 0]))}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send ServerPort brave(move([0 1]))} end)}
   {Window bind(event:"<space>" action:proc{$} {Send ServerPort brave(pickup)} end)}

   %% FUNCTIONS
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

   % PortObject
   fun {NewPortObject Init Fun}
      proc {MsgLoop S1 State}
	 case S1 of Msg|S2 then
	    {Show Msg}
	    {MsgLoop S2 {Fun State Msg}}
	 [] nil then skip end
      end
      Sin
   in
      thread {MsgLoop Sin Init} end
      {NewPort Sin}
   end

   fun {ServerState Init}
      Cid={NewPortObject Init
	   fun {$ state(Map Pos NObjects NBullets ActionsLeft) Msg}
	      X Y F NewPos NewX NewY NewF Value in
	      [X Y F] = Pos
	      Value = Map.X.Y
	      {Show X} {Show Y} {Show F}
	      {Show Msg}
	      case Msg
	      of brave(move(D)) then
		 if ActionsLeft==0 then {Show 'filter'} state(Map Pos NObjects NBullets ActionsLeft)
		 else
		    {Show D}
		    NewPos = {CalcNewPos Pos D}
		    [NewX NewY NewF] = NewPos
		    if {Move Map Pos NewPos brave NObjects ActionsLeft}==0 then %faire truc plus propre
		       state(Map Pos NObjects NBullets ActionsLeft)
		    else
		       state(Map NewPos NObjects NBullets ActionsLeft-1)
		    end
		 end
	      [] brave(pickup) then
		 if {PickUp Map Pos brave NObjects NBullets ActionsLeft}==0 then
		    state(Map Pos NObjects NBullets ActionsLeft)
		 else
		    state(Map Pos NObjects+1 NBullets ActionsLeft-1)
		 end       
	      else
		 {Show 'mismatch'}
		 state(Map Pos NObjects NBullets ActionsLeft)
	      end % end case Msg
	   end} % end function
   in
      Cid
   end

   fun {CalcNewPos Pos Move}
      X Y F DX DY in
      Pos = [X Y F]
      Move = [DX DY]
      [X+DX Y+DY Move]
   end

   fun {Move Map Pos NewPos Person NObjects ActionsLeft}
      X Y F NewX NewY NewF Value NewValue in
      [X Y F] = Pos
      [NewX NewY NewF] = NewPos
      Value = Map.X.Y
      NewValue = Map.NewX.NewY
      if NewValue==1 then
	 0
      elseif NewValue==5 then
	 if {And Person==brave NObjects>=OBJECTS_WANTED} then {DrawCell Floor X Y} {UpdateMovesCount ActionsLeft-1} 1
	 else 0 end
      else
	 {UpdateMovesCount ActionsLeft-1}
	 if {Or Value==0 Value==5} then {DrawCell Floor X Y} end
	 if NewValue==0 then {DrawCell Brave NewX NewY} end
	 1
      end
   end

   fun {PickUp Map Pos Person NObjects NBullets ActionsLeft}
      X Y F Value in
      Pos = [X Y F]
      Value = Map.X.Y
      if {Or {Or Value==2 Value==3} Value==4} then
	 if Person==brave then
	    if Value==2 then {UpdateBulletsCount NBullets+3}
	    else {UpdateItemsCount NObjects+1} end
	    {UpdateMovesCount ActionsLeft-1}
	 end
	 {DrawCell Floor X Y}
	 % TO DO: vraiment le virer de la MAP
	 1
      else 0 end
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
   {DrawCell Brave X_INIT Y_INIT}
   ServerPort = {ServerState state(MAP [X_INIT Y_INIT F_INIT] 0 BULLETS_INIT BRAVE_MAXSTEP+100)}
end
