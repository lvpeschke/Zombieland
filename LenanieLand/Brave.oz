functor
import
   Application
   OS

   % Our functors
   Config
 
   System %%
export
   BraveState
define

   fun {Success}
      {System.show 'You won'}
      {Application.exit 0}
   end

   fun {GameOver}
      {System.show 'You loose'}
      {Application.exit 0}
   end
   
   fun {NewPos X Y Move}
      [X+Move.1 Y+Move.2.1 Move]
   end
    
   fun {BraveState Init}
      Cid={NewPortObject Init
	   fun {$ state(Mode X Y F ActionsLeft NBullets NObjects) Msg}
	     {System.show Msg}
	     {System.show Mode}
	      if Mode==notyourturn then
		 case Msg
		 of yourturn then state(yourturn X Y F 2 NBullets NObjects)
		 % A SUPPRIMER
		 else {Show Msg} {Show 'alors qu on est en mode notyourturn'}
		    state(Mode X Y F ActionsLeft NBullets NObjects)
		 end
	      elseif Mode==yourturn
		 if ActionsLeft==0 then
		    {Send Config.controllerPort finish(brave)}
		    state(Mode X Y F ActionsLeft NBullets NObjects)
		 else
		    {System.show Msg}
		    case Msg
		    of move(D) then
		       local Ack in
			  local NewX NewY NewZ in
			     [NewX NewY NewF] = {NewPos X Y D}
			     {Send Config.mapPorts.NewX.NewY brave(enter Ack)}
			     {Wait Ack}
			     if Ack==ok then
				{Send Config.mapPorts.X.Y brave(quit)}
				state(Mode NewX NewY NewF ActionsLeft-1 NBullets NObjects)
			     else
				state(Mode X Y F ActionsLeft NBullets NObjects)
			     end
			  end
		       [] pickup then
			  {Send Config.mapPorts.X.Y brave(pickup Ack)}
			  {Wait Ack}
			  if Ack==2 then state(Mode X Y F ActionsLeft-1 NBullets+3 NObjects)
			  elseif {Or Ack==3 Ack==4} then state(Mode X Y F ActionsLeft-1 NBullets NObjects+1)
			  elseif Ack==5 then
			     if NObjects==Config.nObjects then {Success}
			     else state(Mode X Y F ActionsLeft NBullets NObjects) end
			  else
			     state(Mode X Y F ActionsLeft NBullets NObjects)
			  end
		       else
			  state(Mode X Y F ActionsLeft NBullets NObjects)
		       end
		    end
		 end
	      end
	   end
	  end}
   in
      Cid
   end
end
