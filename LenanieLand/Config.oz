%%%%%%%%%%%%%%%%%%%%%%%%%%
%     CONFIGURATION      %
%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
   OS
   
export
   /* Variables */
   % Default
   NWantedObjectsDefault % the default number of objects the player has to collect
   NBulletsDefault % the default initial number of bullets  
   NZombiesDefault % the default initial number of zombies in the room
   NWantedObjects % the real number of objects the player has to collect
   NBullets % the real initial number of bullets  
   NZombies % the real initial number of zombies in the room
   
   % Turns
   % 1 move = move 1 cell (no diagonal) OR pick up 1 item
   NAllowedMovesB % the number of moves the player is allowed in 1 turn
   NAllowedMovesZ  % the number of moves the zombie is allowed in 1 turn

   /* Procedures */ 
   % The port objects known by everybody
   ControllerPort
   BravePort
   MapPorts
   ZombiesPorts
   
   % Creates a new port object
   NewPortObject

   % Moves
   RandFacing
   NextCell
   Left
   Right
   Barrier
   
define
   NWantedObjectsDefault = 3
   NWantedObjects
   NZombiesDefault = 10
   NZombies
   NBulletsDefault = 3
   NBullets
   
   NAllowedMovesB = 2
   NAllowedMovesZ = 3

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
   
   % Moves
   fun {RandFacing}
      local X in
	 X = {OS.rand} mod 4
	 if X == 0 then [~1 0]
	 elseif X == 1 then [0 1]
	 elseif X == 2 then [1 0]
	 else [0 ~1] end
      end
    end
    
   proc {NextCell F OldL OldC ?NewL ?NewC}
      [DLine DCol] = F in
      NewL = OldL+DLine
      NewC = OldC+DCol
   end
   
   fun {Right D}
      if D == [~1 0] then [0 ~1]
      elseif D == [0 ~1] then [1 0]
      elseif D == [1 0] then [0 1]
      else [~1 0] end
   end

   fun {Left D}
      if D == [~1 0] then [0 1]
      elseif D == [0 ~1] then [~1 0]
      elseif D == [1 0] then [0 ~1]
      else [1 0] end
   end

   % Barrier
   proc {Barrier Ps}
      fun {BarrierLoop Ps L}
	 case Ps
	 of P|Pr then M in
	    thread {P} M=L end
	    {BarrierLoop Pr M}
	 [] nil then L
	 end
      end
      S = {BarrierLoop Ps unit}
   in
      {Wait S}
   end
 
end
