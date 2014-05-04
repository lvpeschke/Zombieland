functor
import
   Application
   OS

   % For file reading
   Open %at 'x-oz://system/Open.ozf'
   Pickle

   % Our functors
   Config
   GUI
   Room
   % Zombie

   System %%
   
define
   % Load function for the map /** NOT YET USED **/
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

   

   %% CONFIG
   X_INIT = 1
   Y_INIT = 7
   F_INIT = [1 0]
   LENGTH = 20
   HEIGHT = 13
   MAP1 = map(
	     r(1 1 1 1 1 1 5 1 1 1 1 1 1 1 1 1 1 1 1 1)
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
   MAP2 = map(
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
	     )

   CurrentMap = MAP1

   ServerPort

   Window = GUI.window
   {GUI.initLayout CurrentMap Window ServerPort}


   % Sets the Map
   /*fun {UpdateMap Map X Y}
      fun {UpdateMap2 I J}e
	 {System.show 'salut'}
      end
   in
      {UpdateMap2 0 0}
   end*/
   
   % PortObject
   fun {NewPortObject Init Fun}
      proc {MsgLoop S1 State}
	 case S1 of Msg|S2 then
	    {System.show Msg}
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
	      {System.show X} {System.show Y} {System.show F}
	      {System.show Msg}
	      case Msg
	      of brave(move(D)) then
		 if ActionsLeft==0 then {System.show 'filter'} state(Map Pos NObjects NBullets ActionsLeft)
		 else
		    {System.show D}
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
		 {System.show 'mismatch'}
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
	 if {And Person==brave NObjects>=Config.nWantedObjects} then {GUI.drawCell 0 X Y} {GUI.updateMovesCount ActionsLeft-1} 1
	 else 0 end
      else
	 {GUI.updateMovesCount ActionsLeft-1}
	 if {Or Value==0 Value==5} then {GUI.drawCell 0 X Y} end
	 if NewValue==0 then {GUI.drawCell b NewX NewY} end
	 1
      end
   end

   fun {PickUp Map Pos Person NObjects NBullets ActionsLeft}
      X Y F Value in
      Pos = [X Y F]
      Value = Map.X.Y
      if {Or {Or Value==2 Value==3} Value==4} then
	 if Person==brave then
	    if Value==2 then {GUI.updateBulletsCount NBullets+3}
	    else {GUI.updateItemsCount NObjects+1} end
	    {GUI.updateMovesCount ActionsLeft-1}
	 end
	 {GUI.drawCell 0 X Y}
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
   {GUI.drawCell b X_INIT Y_INIT}
   ServerPort = {ServerState state(CurrentMap [X_INIT Y_INIT F_INIT] 0 Config.nBullets Config.nAllowedMoves+100)}
end
