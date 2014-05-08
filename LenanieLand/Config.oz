functor
import
   Application
   System
export
   Map % the default map of the room to be displayed
   
   % Turns
   % 1 move = move 1 cell (no diagonal) OR pick up 1 item
   NAllowedMovesB % the number of moves the player is allowed in 1 turn
   NAllowedMovesZ  % the number of moves the zombie is allowed in 1 turn

   % Input
   NWantedObjects % the default number of objects the player has to collect
   NBullets % the default initial number of bullets  
   NZombies % the default initial number of zombies in the room
   X_INIT
   Y_INIT
   F_INIT
   
   % The port objects known by everybody
   ControllerPort
   BravePort
   MapPorts
   ZombiesPorts
   
   % Creates a new port object
   NewPortObject
   Success
   GameOver
   NextCell
   Left
   Right
   
define
   Map = map(
	    r(1 1 1 1 1 1 5 1 1 1 1 1 1 1 1 1 1 1 1 1)
	    r(1 2 0 0 0 0 0 0 0 0 0 0 0 1 2 0 0 0 0 1)
	    r(1 2 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	    r(1 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 0 1)
	    r(1 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	    r(1 2 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 1)
	    r(1 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	    r(1 2 3 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 2 1)
	    r(1 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	    r(1 2 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 1)
	    r(1 4 4 3 3 3 3 3 3 3 3 3 1 0 0 0 0 0 0 1)
	    r(1 2 2 2 2 2 2 2 2 3 2 2 1 0 0 0 0 4 0 1)
	    r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
	    )
   
   NAllowedMovesB = 2
   NAllowedMovesZ = 3
   NWantedObjects = 2
   NZombies = 10
   NBullets = 3

   X_INIT = 1
   Y_INIT = 7
   F_INIT = [1 0]

   % The port objects known by everybody
   ControllerPort
   BravePort
   MapPorts
   ZombiesPorts
   
   % PortObject
   fun {NewPortObject Init Fun}
      proc {MsgLoop S1 State}
	 case S1 of Msg|S2 then
	    {MsgLoop S2 {Fun State Msg}}
	 [] nil then skip end
      end
      Sin
   in
      thread {MsgLoop Sin Init} end
      {NewPort Sin}
   end

   % Fail and success
   proc {Success}
      {System.show 'You win'}
      {Application.exit 0}
   end

   proc {GameOver}
      {System.show 'You loose'}
      {Application.exit 0}
   end

   % Moves
   proc {NextCell F OldL OldC ?NewL ?NewC}
      [DLine DCol] = F in
      NewL = OldL+DLine
      NewC = OldC+DCol
   end
    
   fun {Right D}
      if D==[~1 0] then [0 ~1]
      elseif D==[0 ~1] then [1 0]
      elseif D==[1 0] then [0 1]
      else [~1 0] end
   end

   fun {Left D}
      if D==[~1 0] then [0 1]
      elseif D==[0 ~1] then [~1 0]
      elseif D==[1 0] then [0 ~1]
      else [1 0] end
   end
   
end
