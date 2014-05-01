declare
QTk
[QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}

local
   % Current working directory
   CD = {OS.getCWD}
   {Show CD} % print CD to emulator'

   % Images
   Brave = {QTk.newImage photo(file:CD#'/brave.gif')}
   Bullets = {QTk.newImage photo(file:CD#'/bullets.gif')}
   Floor = {QTk.newImage photo(file:CD#'/floor.gif')}
   Food = {QTk.newImage photo(file:CD#'/food.gif')}
   Medicine = {QTk.newImage photo(file:CD#'/medicine.gif')}
   Wall = {QTk.newImage photo(file:CD#'/wall.gif')}
   Zombie = {QTk.newImage photo(file:CD#'/zombie.gif')}
   
   Canvas
  % DEFAULT_COLOR = beige

   % Cell dimensions
   WidthCell = 30
   HeightCell = 30

   % Number of cells
   NW = 20 %%
   NH = 20 %%

   % Total dimensions
   W = WidthCell*NW
   H = HeightCell*NH

   % number of steps the player can take in a turn
   PLAYER_MAXSTEP = 2

   % Command for the player (user)
   Command 
   CommandPort = {NewPort Command}

   % GUI with a canvas widget
   Desc = td(canvas(bg:green
		    width:W
		    height:H
		    handle:Canvas))

   % Builds the GUI
   Window = {QTk.build Desc}
   %{Window set(title:"ZOMBIELAND")}

   % Sets actions for the arrow keys
   {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}
   {Window bind(event:"<space>" action:proc{$} {Send CommandPort finish} end)}

   % Sets up a box with a background
   proc {DrawBox Color X Y}
      {Canvas create(rect
		     X*WidthCell
		     Y*HeightCell
		     X*WidthCell+WidthCell
		     Y*HeightCell+HeightCell
		     fill:Color
		     outline:black)}
   end

   % Sets up a box with an image %% TEST
   proc {ImageBox Image X Y}
      {Canvas create(image
		     X*WidthCell
		     Y*HeightCell
		     X*WidthCell+WidthCell
		     Y*HeightCell+HeightCell
		     image:Image
		     outline:black)}
      end

   % Initializes the layout
      proc {InitLayout ListToDraw}
      % draws black horizontal lines, recursive
	 proc {DrawHline X1 Y1 X2 Y2}
	 % checks that the dimensions are not outside the frame
	    if X1 > W orelse X1 < 0 orelse Y1 > H orelse Y1 < 0 then
	       skip
	    else
	       {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	       {DrawHline X1+HeightCell Y1 X2+HeightCell Y2}
	    end
	 end
      % draws blackvertical lines, recursive
	 proc {DrawVline X1 Y1 X2 Y2}
	 % checks that the dimensions are not outside the frame
	    if X1 > W orelse X1 < 0 orelse Y1 > H orelse Y1 < 0 then
	       skip
	    else
	       {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	       {DrawVline X1 Y1+WidthCell X2 Y2+WidthCell}
	    end
	 end
      % draws the squares, recursive
	 proc {DrawUnits L} %% CHANGER
	    case L of r(Color X Y)|T then
	       {DrawBox Color X Y}
	       {DrawUnits T}
	    else
	       skip
	    end
	 end
      in
	 {DrawHline 0 0 0 H} % check
	 {DrawVline 0 0 W 0}
	 {DrawUnits ListToDraw}
      end

   % Game controller
      proc{Game OldX OldY Command}
	 NewX NewY % new position, unbound
	 NextCommand % new command, unbound

      % User input
	 fun {UserCommand Command Count X Y ?LX ?LY}
	    IX IY in
	    case Command
	 % arrow keys   
	    of r(DX DY)|T then
	    % does nothing
	       if Count == PLAYER_MAXSTEP then
		  {UserCommand T Count X Y  LX LY}
	    % moves   
	       else
		  IX = X+DX
		  IY = Y+DY
		  {ImageBox Floor X Y}  % new empty box
		  {DrawBox white IX IY} % new position of player
		  {UserCommand T Count+1 IX IY LX LY }
	       end
	 % space bar
	    [] finish|T then
	       LX = X
	       LY = Y
	       T
	    end
	 end
      in
	 NextCommand = {UserCommand Command 0 OldX OldY ?NewX ?NewY}
	 {Game NewX NewY NextCommand}
      end
   in
   % Display GUI
      {Window show}
    
   % Initialize zombies and user
      {InitLayout [r(yellow 1 12) r(blue 10 3) r(black 11 10) r(white 8 8)]}
      {Game 8 8 Command}
   end


    
   