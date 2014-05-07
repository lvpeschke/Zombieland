functor
import
   Application
   OS

   % Our functors
   Config
   GUI
 
   System %%
export
   BraveState
   
define

   proc {Success}
      {System.show 'You win'}
      {Application.exit 0}
   end

   proc {GameOver}
      {System.show 'You loose'}
      {Application.exit 0}
   end
   
   fun {NewPos X Y Move}
      [X+Move.1 Y+Move.2.1 Move]
   end
    
   fun {BraveState Init}
      Cid = {Config.newPortObject Init
	     fun {$ state(Mode X Y F ActionsLeft NBullets NObjects) Msg} %% retenir la commande
		{System.show 'message '#Msg#', mode '#Mode}
	      
		case Mode
		 
		of notyourturn then
		   case Msg
		    
		   of yourturn then
		      state(yourturn X Y F Config.nAllowedMovesB NBullets NObjects) %%
		    
		   [] move(D) then % skip
		      {System.show 'Brave2 39 move vide'}
		      state(Mode X Y F ActionsLeft NBullets NObjects)
		    
		   [] pickup then % skip
		      {System.show 'Brave2 42 pickup vide'}
		      state(Mode X Y F ActionsLeft NBullets NObjects)
		    
		 % A SUPPRIMER
		   else
		      {System.show Msg#' alors qu on est en mode notyourturn'}
		      state(Mode X Y F ActionsLeft NBullets NObjects) %%
		   end

		 
		[] yourturn then

		   case Msg
		    
		 % A SUPPRIMER
		   of yourturn then
		      {System.show Msg#' alors qu on est en mode yourturn'}
		      state(Mode X Y F ActionsLeft NBullets NObjects) %%
		    
		   [] move(D) then
		      {System.show 'a priori ActionsLeft est > 0...'#ActionsLeft}
		      local NewX NewY NewF Ack in
			 [NewX NewY NewF] = {NewPos X Y D}
			 {Send Config.mapPorts.NewX.NewY brave(enter Ack)}
			 {Wait Ack}
		       
			 if Ack == ok then
			    {Send Config.mapPorts.X.Y brave(quit)}
			    if ActionsLeft == 1 then % last action
			       {Send Config.controllerPort finish(brave)}
			       state(notyourturn NewX NewY NewF 0 NBullets NObjects) %%
			    else 			  
			       state(Mode NewX NewY NewF ActionsLeft-1 NBullets NObjects) %%
			    end
			   			     
			 elseif Ack == door then
			    if NObjects == Config.nWantedObjects then
			       {Success} % end of game
			        state(Mode X Y F ActionsLeft NBullets NObjects) % ???? what to do?
			    else
			       state(Mode X Y F ActionsLeft NBullets NObjects) % skip
			    end
			  
			 elseif Ack == ko then
			    state(Mode X Y F ActionsLeft NBullets NObjects) % skip
			  
			 else
			    {System.show Msg#' alors qu on est en mode yourturn'}
			    state(Mode X Y F ActionsLeft NBullets NObjects) %%
			 end
		      end
		    
		    
		   [] pickup then
		      {System.show 'a priori ActionsLeft est > 0...'#ActionsLeft}
		      local Ack in
			 {Send Config.mapPorts.X.Y brave(pickup Ack)}
			 {Wait Ack}
		       
			 if Ack == 2 then
			    if ActionsLeft == 1 then % last action
			       {Send Config.controllerPort finish(brave)}
			       {GUI.updateBulletsCount NBullets+3}
			       state(notyourturn X Y F 0 NBullets+3 NObjects) %%
			    else
			       state(Mode X Y F ActionsLeft-1 NBullets+3 NObjects) %%
			    end
			  
			 elseif Ack == 3 orelse Ack == 4 then
			    if ActionsLeft == 1 then % last action
			       {Send Config.controllerPort finish(brave)}
			       {GUI.updateItemsCount NObjects+1}
			       state(notyourturn X Y F 0 NBullets NObjects+1) %%
			    else
			       state(Mode X Y F ActionsLeft-1 NBullets NObjects+1) %%
			    end
			  
			 elseif Ack == ko then	  
			    state(Mode X Y F ActionsLeft NBullets NObjects) % skip
			  
			 else
			    {System.show 'Brave 119 Ack == '#Ack}
			    state(Mode X Y F ActionsLeft NBullets NObjects) %%
			 end
		      end
		    
		   else
		       
		      {System.show 'Brave 123 grosse erreur!'}
		      state(Mode X Y F ActionsLeft NBullets NObjects) %%
		   end
		end
	     end}
   in
      Cid
   end
end
