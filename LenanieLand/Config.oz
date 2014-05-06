functor
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
   
   % The port objects known by everybody
   ControllerPort
   BravePort
   MapPorts

   % Creates a new port object
   NewPortObject
   
define
   Map = map(
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
	    r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
	    )
   
   NAllowedMovesB = 2
   NAllowedMovesZ = 3
   NWantedObjects = 5
   NZombies = 5
   NBullets = 3

   % The port objects known by everybody
   ControllerPort
   BravePort
   MapPorts
   
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
end
