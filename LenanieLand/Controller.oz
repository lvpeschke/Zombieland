%%%%%%%%%%%%%%%%%%%%%%%%%%
%     THE CONTROLLER     %
%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
   % Our functors
   Config
   GUI
 
   System %%
   
export
   ControllerState
   
define
   
   fun {ControllerState IDoor JDoor Init}
      Cid = {Config.newPortObject Init
	   fun {$ state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft) Msg}
             {System.show 'Etat controller : '#Mode#NZombies#Msg}
	      case Mode
		 
	      of brave then
		 
		 case Msg
		 of finish(brave) then
		    for I in 1..Config.nZombies do
		       if Config.zombiesPorts.I == empty then
			  skip
		       else {Send Config.zombiesPorts.I yourturn}
		       end
		    end
		    {System.show 'Controller 27 just sent YOURTURN to all ZOMBIES'}
		    if NZombies > 0 then
		       state(zombie NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft) %%
		    else {Send Config.bravePort yourturn}
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft)
		    end

		 [] destroy(brave) then
		    if ItemsGoal-1 == 0 then
		       {GUI.drawCell openDoor IDoor JDoor}
		    end
		    if ItemsGoal-1 > ItemsLeft-1 then % should not happen!!
		       {System.show 'Controller 46 '#'erreur :le brave s est fait avoir...'}
		       {GUI.endOfGame lose}
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal-1 ItemsLeft-1) %%
		    else
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal-1 ItemsLeft-1)
		    end
		    
		 % A SUPPRIMER
		 [] finish(zombie) then
		    {System.show 'Controller 31 '#'erreur : finish(zombie) alors qu on est en mode brave'}
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft) %%

		 [] destroy(zombie) then
		    {System.show 'Controller 31 '#'erreur : destroy(zombie) alors qu on est en mode brave'}
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft-1) %%
		    
		 [] kill(ZombieNumber) then
		    local NewZombiesPorts in
		       NewZombiesPorts = {MakeTuple zombiesPorts NZombies}
		       for I in 1..NZombies do
			  if I == ZombieNumber then
			     NewZombiesPorts.I=empty
			  else
			     NewZombiesPorts.I = ZombiesPorts.I
			  end
		       end
		       {System.show ''#NZombies#NResponses}
		       state(Mode NZombies-1 NewZombiesPorts NResponses ItemsGoal ItemsLeft)
		    end
		 end
		 
	      [] zombie then
		 
		 case Msg
		    
		 of finish(zombie) then
		    if NResponses+1 \=  NZombies then
		       {System.show 'Controller 38 '#' got finish(zombie), nr'#NResponses+1}
		       state(Mode NZombies ZombiesPorts NResponses+1 ItemsGoal ItemsLeft) %%
		    elseif NResponses+1 == NZombies then
		       {System.show 'Controller 41 '#' LAST FINISH, BRAVE NOW'}
		       {Send Config.bravePort yourturn}
		       state(brave NZombies ZombiesPorts 0 ItemsGoal ItemsLeft) %%
		        % A SUPPRIMER
		    else
		       {System.show 'Controller 43 '#'erreur : finish(zombie) EN TROP'}
		       state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft) %%
		    end

		 [] destroy(zombie) then
		    if ItemsGoal == 0 then
		       {System.show 'Controller 100 '#'erreur : les zombies se font avoir...'}
		       {GUI.drawCell openDoor IDoor JDoor}
		    end
		    if ItemsGoal > ItemsLeft-1 then
		       {GUI.endOfGame lose}
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft-1) %%
		    else
		       state(brave NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft-1)
		    end
		 % A SUPPRIMER
		 [] finish(brave) then
		    {System.show 'Controller 46 '#'erreur : finish(brave) alors qu on est en mode zombie'}
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal ItemsLeft) %%

		 [] destroy(brave) then
		    {System.show 'Controller 103 '#'erreur : destroy(brave) alors qu on est en mode zombie'}
		    state(Mode NZombies ZombiesPorts NResponses ItemsGoal-1 ItemsLeft-1) %%	    
		    
		 [] kill(ZombieNumber) then
		    {System.show 'Controller : kill('#ZombieNumber}
		    local NewZombiesPorts in 
		       NewZombiesPorts = {MakeTuple zombiesPorts Config.nZombies}
		       for I in 1..Config.nZombies do
			  if I == ZombieNumber then
			     NewZombiesPorts.I=empty
			  else
			     NewZombiesPorts.I = Config.zombiesPorts.I
			  end
		       end
		       {System.show 'NZombies et NResponses :'#NZombies#NResponses}
		       if (NZombies-1 == NResponses) then
			  {Send Config.bravePort yourturn}
			  state(brave NZombies-1 NewZombiesPorts 0 ItemsGoal ItemsLeft)
		       else
			  state(Mode NZombies-1 NewZombiesPorts NResponses ItemsGoal ItemsLeft)
		       end
		    end
		 end
	      end
	   end} % end function
   in
      Cid
   end
end
