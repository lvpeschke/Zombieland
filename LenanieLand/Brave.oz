functor
import
   Application
   OS

   % Our functors
   Config
 
   System %%
   
define
   fun {NewPos X Y Move}
      [X+Move.1 Y+Move.2.1 Move]
   end
    
   fun {BraveState Init}
      Cid={NewPortObject Init
	   fun {$ state(Mode X Y F ActionsLeft NBullets NObjects) Msg}
	      if Mode==notyourturn then
		 case Msg
		 of yourturn then state(yourturn X Y F 2 NBullets NObjects)
		 % A SUPPRIMER
		 else {Show Msg} {Show 'alors qu on est en mode notyourturn'}
		    state(Mode X Y F ActionsLeft NBullets NObjects)
		 end
	      elseif Mode==yourturn
		 if ActionsLeft==0 then {Send Config.controllerPort finish(brave)} state(Mode X Y F ActionsLeft NBullets NObjects)
		 else
		    case Msg
		    of move(D) then local NewX NewY NewZ in
				       [NewX NewY NewF] = {NewPos X Y D}
				       {Send Config.mapPorts.NewX.NewY }
				    end
		       
		 % A SUPPRIMER
		    [] finish(brave) then {Show 'erreur : finish(brave) alors qu on est en mode zombie'}
		       state(Mode NZombies Zombies NResponses)
		    end
		 end
	      end
	   end} % end function
   in
      Cid
   end
end
