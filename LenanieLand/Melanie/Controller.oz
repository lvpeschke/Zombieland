functor
import
   Application
   OS

   % Our functors
   Config
 
   System %%
   
define
   fun {WakeZombies NZombies Zombies}
      fun {WakeZombie X}
	 if X=<NZombies then {Send Zombies.X yourturn} {WakeZombie X+1}
	 else skip end
      end
   in
      {WakeZombie 1}
   end
   
   fun {ControllerState Init}
      Cid={NewPortObject Init
	   fun {$ state(Mode NZombies Zombies NResponses) Msg}
	      if Mode==brave then
		 case Msg
		 of finish(brave) then {WakeZombies Zombies} state(zombie NZombies Zombies NResponses)
		 % A SUPPRIMER
		 [] finish(zombie) then {Show 'erreur : finish(zombie) alors qu on est en mode brave'}
		    state(Mode NZombies Zombies NResponses)
		 end
	      else
		 case Msg
		 of finish(zombie) then
		    if NResponses \=  NZombies-1 then state(Mode NZombies Zombies NResponses+1)
		    else {Send BravePort yourturn} state(Mode NZombies Zombies 0) end
		 % A SUPPRIMER
		 [] finish(brave) then {Show 'erreur : finish(brave) alors qu on est en mode zombie'}
		    state(Mode NZombies Zombies NResponses)
		 end
	      end
	   end} % end function
   in
      Cid
   end
end
