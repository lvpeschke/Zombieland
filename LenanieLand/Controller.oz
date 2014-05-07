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
             %{System.show 'Controller 18 message '#Msg}
	     %{System.show 'Controller 19 mode '#Mode}
	      case Mode
	      of brave then
		 case Msg
		 of finish(brave) then
		    for I in 1..Config.nZombies do
		       {Send Config.zombiesPorts.I yourturn}
		    end
		    %{System.show 'Controller 27 just sent YOURTURN to all ZOMBIES'}
		    state(zombie NZombies ZombiesPorts NResponses) %%
		 % A SUPPRIMER
		 [] finish(zombie) then
		    %{System.show 'Controller 31 '#'erreur : finish(zombie) alors qu on est en mode brave'}
		    state(Mode NZombies ZombiesPorts NResponses) %%
		 end
	      [] zombie then
		 case Msg
		 of finish(zombie) then
		    if NResponses \=  NZombies-1 then
		       %{System.show 'Controller 38 '#' got finish(zombie), nr'#NResponses+1}
		       state(Mode NZombies ZombiesPorts NResponses+1) %%
		    elseif NResponses == NZombies-1 then
		       %{System.show 'Controller 41 '#' LAST FINISH, BRAVE NOW'}
		       {Send Config.bravePort yourturn}
		       state(brave NZombies ZombiesPorts 0) %%
		        % A SUPPRIMER
		    else
		       %{System.show 'Controller 43 '#'erreur : finish(zombie) EN TROP'}
		       state(Mode NZombies ZombiesPorts NResponses) %%
		    end
		 % A SUPPRIMER
		 [] finish(brave) then %{System.show 'Controller 46 '#'erreur : finish(brave) alors qu on est en mode zombie'}
		    state(Mode NZombies ZombiesPorts NResponses) %%
		 end
	      end
	   end} % end function
   in
      Cid
   end
end
