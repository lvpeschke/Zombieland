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
             {System.show Msg}
	     {System.show Mode}
	      case Mode
	      of brave then
		 case Msg
		 of finish(brave) then
		    for I in 1..Config.nZombies do
		       {Send Config.zombiesPorts.I yourturn}
		    end
		    state(zombie NZombies ZombiesPorts NResponses)
		 % A SUPPRIMER
		 [] finish(zombie) then {System.show 'erreur : finish(zombie) alors qu on est en mode brave'}
		    state(Mode NZombies ZombiesPorts NResponses)
		 end
	      [] zombie then
		 case Msg
		 of finish(zombie) then
		    if NResponses \=  NZombies-1 then state(Mode NZombies ZombiesPorts NResponses+1)
		    else {Send Config.bravePort yourturn} state(Mode NZombies ZombiesPorts 0) end
		 % A SUPPRIMER
		 [] finish(brave) then {System.show 'erreur : finish(brave) alors qu on est en mode zombie'}
		    state(Mode NZombies ZombiesPorts NResponses)
		 end
	      end
	   end} % end function
   in
      Cid
   end
end
