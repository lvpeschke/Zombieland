%%%%%%%%%%%%%%%%%%%%%%%%%%
%     THE CONTROLLER     %
%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
   Application
   OS

   % Our functors
   Config
 
   System %%
   
export
   ControllerState
   
define
   
   fun {ControllerState Init}
      Cid={Config.newPortObject Init
	   fun {$ state(Mode NZombies ZombiesPorts NResponses) Msg}
             {System.show 'Etat controller : '#Mode#NZombies#Msg}
	      case Mode
	      of brave then
		 case Msg
		 of finish(brave) then
		    for I in 1..Config.nZombies do
		       if Config.zombiesPorts.I==empty then skip
		       else {Send Config.zombiesPorts.I yourturn} end
		    end
		    {System.show 'Controller 27 just sent YOURTURN to all ZOMBIES'}
		    if NZombies>0 then state(zombie NZombies ZombiesPorts NResponses) %%
		    else {Send Config.bravePort yourturn} state(brave NZombies ZombiesPorts NResponses) end
		 % A SUPPRIMER
		 [] finish(zombie) then
		    {System.show 'Controller 31 '#'erreur : finish(zombie) alors qu on est en mode brave'}
		    state(Mode NZombies ZombiesPorts NResponses) %%
		 [] kill(ZombieNumber) then
		    local NewZombiesPorts in
		       NewZombiesPorts = {MakeTuple zombiesPorts NZombies}
		       for I in 1..NZombies do
			  if I==ZombieNumber then NewZombiesPorts.I=empty
			  else NewZombiesPorts.I = ZombiesPorts.I end
		       end
		       {System.show ''#NZombies#NResponses}
		       state(Mode NZombies-1 NewZombiesPorts NResponses)
		    end
		 end
		 
	      [] zombie then
		 case Msg
		 of finish(zombie) then
		    if NResponses+1 \=  NZombies then
		       {System.show 'Controller 38 '#' got finish(zombie), nr'#NResponses+1}
		       state(Mode NZombies ZombiesPorts NResponses+1) %%
		    elseif NResponses+1 == NZombies then
		       {System.show 'Controller 41 '#' LAST FINISH, BRAVE NOW'}
		       {Send Config.bravePort yourturn}
		       state(brave NZombies ZombiesPorts 0) %%
		        % A SUPPRIMER
		    else
		       {System.show 'Controller 43 '#'erreur : finish(zombie) EN TROP'}
		       state(Mode NZombies ZombiesPorts NResponses) %%
		    end
		 % A SUPPRIMER
		 [] finish(brave) then {System.show 'Controller 46 '#'erreur : finish(brave) alors qu on est en mode zombie'}
		    state(Mode NZombies ZombiesPorts NResponses) %%
		 [] kill(ZombieNumber) then
		    {System.show 'Controller : kill('#ZombieNumber}
		    local NewZombiesPorts in 
		       NewZombiesPorts = {MakeTuple zombiesPorts Config.nZombies}
		       for I in 1..Config.nZombies do
			  if I==ZombieNumber then NewZombiesPorts.I=empty
			  else NewZombiesPorts.I = Config.zombiesPorts.I end
		       end
		       {System.show 'NZombies et NResponses :'#NZombies#NResponses}
		       if (NZombies-1==NResponses) then
			  {Send Config.bravePort yourturn}
			  state(brave NZombies-1 NewZombiesPorts 0)
		       else state(Mode NZombies-1 NewZombiesPorts NResponses) end
		    end
		 end
	      end
	   end} % end function
   in
      Cid
   end
end
