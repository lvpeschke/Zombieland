%%%%%%%%%%%%%%%%%%%%%%%%%%
%     THE CONTROLLER     %
%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
   Config
   GUI
   
export
   ControllerState
   
define

   %% States
   % - brave
   % - zombie

   %% Messages
   % - finish(brave)
   % - finish(zombie)
   % - destroy(brave)
   % - destroy(zombie)
   % - kill(ZombieNumber)
   
   % Manages the Controller PortObject
   fun {ControllerState IDoor JDoor Init}
      Cid = {Config.newPortObject Init
	   fun {$ state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft) Msg}

	      case Mode

	      % The Brave is playing his turn
	      of brave then
		 
		 case Msg
		    
		 of finish(brave) then
		    for I in 1..Config.nZombies do
		       if Config.zombiesPorts.I == empty then
			  skip
		       else {Send Config.zombiesPorts.I yourturn}
		       end
		    end
		    if NZombies > 0 then
		       state(zombie NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft)
		    else {Send Config.bravePort yourturn}
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft)
		    end

		 [] destroy(brave) then
		    if ItemsGoal-1 == 0 then
		       {GUI.drawCell opendoor IDoor JDoor}
		    end
		    if ItemsGoal-1 > ItemsLeft-1 then % should not happen!
		       {GUI.endOfGame lose}
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal-1 ItemsLeft-1)
		    else
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal-1 ItemsLeft-1)
		    end
		    
		 % A SUPPRIMER
		 [] finish(zombie) then
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft)

		 [] destroy(zombie) then
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft-1)
		    
		 [] kill(ZombieNumber) then
		    local NewZombiesPorts in
		       NewZombiesPorts = {MakeTuple zombiesPorts NZombies}
		       for I in 1..NZombies do
			  if I == ZombieNumber then
			     NewZombiesPorts.I = empty
			  else
			     NewZombiesPorts.I = ZombiesPorts.I
			  end
		       end
		       state(Mode NZombies-1 NewZombiesPorts NResponses ItemsGoal ItemsLeft)
		    end
		 end
		 
	      [] zombie then
		 
		 case Msg
		    
		 of finish(zombie) then
		    if NResponses+1 \=  NZombies then
		       state(Mode NZombies ZombiesPorts NResponses+1 ItemsGoal ItemsLeft)
		       
		    elseif NResponses+1 == NZombies then
		       {Send Config.bravePort yourturn}
		       state(brave NZombies ZombiesPorts 0 ItemsGoal ItemsLeft)
		       
		    else
		       state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft)
		    end

		 [] destroy(zombie) then
		    if ItemsGoal == 0 then
		       {GUI.drawCell opendoor IDoor JDoor}
		    end
		    if ItemsGoal > ItemsLeft-1 then
		       {GUI.endOfGame lose}
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft-1)
		    else
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft-1)
		    end

		 [] finish(brave) then
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft)

		 [] destroy(brave) then
		    if ItemsGoal == 1 then {GUI.drawCell opendoor IDoor JDoor} end
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal-1 ItemsLeft-1)	    
		    
		 [] kill(ZombieNumber) then
		    local NewZombiesPorts in 
		       NewZombiesPorts = {MakeTuple zombiesPorts Config.nZombies}
		       for I in 1..Config.nZombies do
			  if I == ZombieNumber then
			     NewZombiesPorts.I=empty
			  else
			     NewZombiesPorts.I = Config.zombiesPorts.I
			  end
		       end
		       if (NZombies-1 == NResponses) then
			  {Send Config.bravePort yourturn}
			  state(brave NZombies-1 NewZombiesPorts 0 ItemsGoal ItemsLeft)
		       else
			  state(Mode NZombies-1 NewZombiesPorts NResponses ItemsGoal ItemsLeft)
		       end
		    end
		 end
	      end
	   end}
   in
      Cid
   end
end
