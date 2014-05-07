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
	     fun {$ state(Mode X Y F Item ActionsLeft NBullets NObjects) Msg} %% retenir la commande
		{System.show 'message '#Msg#', mode '#Mode}
	      
		case Mode
		 
		of notyourturn then
		   case Msg
		    
		   of yourturn then
		      {GUI.updateMovesCount Config.nAllowedMovesB}
		      state(yourturn X Y F Item Config.nAllowedMovesB NBullets NObjects) %%
		    
		   [] move(D) then % skip
		      {System.show 'Brave2 39 move vide'}
		      state(Mode X Y F Item ActionsLeft NBullets NObjects)
		    
		   [] pickup then % skip
		      {System.show 'Brave2 42 pickup vide'}
		      state(Mode X Y F Item ActionsLeft NBullets NObjects)
		    
		 % A SUPPRIMER
		   else
		      {System.show Msg#' alors qu on est en mode notyourturn'}
		      state(Mode X Y F Item ActionsLeft NBullets NObjects) %%
		   end

		 
		[] yourturn then

		   case Msg
		    
		 % A SUPPRIMER
		   of yourturn then
		      {System.show Msg#' alors qu on est en mode yourturn'}
		      state(Mode X Y F Item ActionsLeft NBullets NObjects) %%
		    
		   [] move(D) then
		      {System.show 'a priori ActionsLeft est > 0...'#ActionsLeft}
		      local NewX NewY NewF Ack in
			 [NewX NewY NewF] = {NewPos X Y D}
			 {Send Config.mapPorts.NewX.NewY brave(tryenter Ack)}
			 {Wait Ack}
		       
			 if Ack==0 orelse Ack==2 orelse Ack==3 orelse Ack==4 then
			    {GUI.drawCell Item X Y}
			    {Send Config.mapPorts.X.Y brave(quit)}
			    {GUI.drawCell brave NewX NewY}
			    {Send Config.mapPorts.NewX.NewY brave(enter)}
			    if ActionsLeft == 1 then {Send Config.controllerPort finish(brave)} end
			    {GUI.updateMovesCount ActionsLeft-1}
			    state(Mode NewX NewY NewF Ack ActionsLeft-1 NBullets NObjects)
			   			     
			 elseif Ack==5 then
			    if NObjects == Config.nWantedObjects then
			       {Success} % end of game
			        state(Mode X Y F Item ActionsLeft NBullets NObjects) % ???? what to do?
			    else
			       state(Mode X Y F Item ActionsLeft NBullets NObjects) % skip
			    end
			  
			 elseif Ack==ko then
			    state(Mode X Y F Item ActionsLeft NBullets NObjects) % skip
			  
			 else
			    {System.show Msg#' alors qu on est en mode yourturn'}
			    state(Mode X Y F Item ActionsLeft NBullets NObjects) %%
			 end
		      end
		    
		    
		   [] pickup then
		      {System.show 'a priori ActionsLeft est > 0...'#ActionsLeft}
		      local Ack in
			 {Send Config.mapPorts.X.Y brave(pickup)}
		       
			 if Item == 2 then
			    if ActionsLeft == 1 then {Send Config.controllerPort finish(brave)} end
			    {GUI.updateBulletsCount NBullets+3}
			    state(notyourturn X Y F empty 0 NBullets+3 NObjects) %%
			  
			 elseif Item == 3 orelse Item == 4 then
			    if ActionsLeft == 1 then {Send Config.controllerPort finish(brave)} end
			    {GUI.updateItemsCount NObjects+1}
			    state(Mode X Y F empty ActionsLeft-1 NBullets NObjects+1) %%
			  
			 elseif Ack == ko then	  
			    state(Mode X Y F Item ActionsLeft NBullets NObjects) % skip
			  
			 else
			    {System.show 'Brave 119 Ack == '#Ack}
			    state(Mode X Y F Item ActionsLeft NBullets NObjects) %%
			 end
		      end
		    
		   else
		       
		      {System.show 'Brave 123 grosse erreur!'}
		      state(Mode X Y F Item ActionsLeft NBullets NObjects) %%
		   end
		end
	     end}
   in
      Cid
   end
end
