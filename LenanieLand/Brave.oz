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
   
   fun {NewPos X Y Move}
      [X+Move.1 Y+Move.2.1 Move]
   end

      % CheckKill
   proc {CheckKill X Y F NBullets Item}
      {System.show 'Brave : checkkill'}
      local FF FL FR AckF AckL AckR ZombieF in
	 FF = [~F.1 ~F.2.1]
	 FL = {Config.left F} {System.show ''#F#'left'#FL}
	 FR = {Config.right F} {System.show ''#F#'right'#FR}
	 {System.show ''#X#Y#(X-FF.1)#(Y-FF.2.1)}
	 {Send Config.mapPorts.(X-FF.1).(Y-FF.2.1) brave(tryenter AckF)}
	 {Wait AckF}
	 {System.show ''#AckF}
	 case AckF
	 of zombie(ZombiePort ZombieF) then
	    if ZombieF == FF andthen NBullets==0 then {System.show 'Face : Le brave est tue'} {Config.gameOver}
	    else
	       {Send Config.bravePort updateNBullets}
	       {System.show 'Face : Le zombie est tue'}
	       {Send ZombiePort kill}
	    end
	 else
	    skip
	 end
	 
	 if Item\=5 then % REECRIRE CA PROPREMENT
	    {Send Config.mapPorts.(X-FL.1).(Y-FL.2.1) brave(tryenter AckL)} {System.show ''#X#Y#(X-FL.1)#(Y-FL.2.1)}
	    {Send Config.mapPorts.(X-FR.1).(Y-FR.2.1) brave(tryenter AckR)} {System.show ''#X#Y#(X-FR.1)#(Y-FR.2.1)}
	    % ATTENTION VA FALLOIR CHANGER CA POUR PAS QUE CA BLOQUE INUTILMENT
	    {Wait AckL}
	    {Wait AckR}
	    {System.show ''#AckL#AckR}
	    case AckL
	    of zombie(ZombiePort ZombieF) then
	       if ZombieF == FL then {System.show 'Face : Le brave est tue'} {Config.gameOver} end
	    else
	       skip
	    end
	    case AckR
	    of zombie(ZombiePort ZombieF) then
	       if ZombieF == FR then {System.show 'Face : Le brave est tue'} {Config.gameOver} end
	    else
	       skip
	    end
	 end
      end
   end
   
	    
   fun {BraveState Init}
      Cid = {Config.newPortObject Init
	     fun {$ state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) Msg} %% retenir la commande
		
		{System.show 'Brave message '#Msg#', mode '#Mode}

		case Mode
		of killed then
		   {GUI.drawCell Item X Y}
		   state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine)
		
		[] notyourturn then
		   case Msg
		    
		   of yourturn then
		      {GUI.updateMovesCount Config.nAllowedMovesB}
		      state(yourturn X Y F Item Config.nAllowedMovesB NBullets NFood NMedicine) %%
		    
		   [] move(D) then % skip
		      {System.show 'Brave2 39 move vide'}
		      state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine)
		    
		   [] pickup then % skip
		      {System.show 'Brave2 42 pickup vide'}
		      state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine)
		      
		   [] kill then
		      {GUI.drawCell Item X Y}
		      {Send Config.mapPorts.X.Y brave(quit)}
		      % et fermer port
		      {Config.gameOver}
		      state(killed X Y F Item ActionsLeft NBullets NFood NMedicine)

		   [] getFacingBullet(FacingBullets) then
		      FacingBullets = [F NBullets]
		      state(killed X Y F Item ActionsLeft NBullets NFood NMedicine)

		   [] updateNBullets then
		      {GUI.updateBulletsCount NBullets-1}
		      state(Mode X Y F Item ActionsLeft NBullets-1 NFood NMedicine)
		   
		 % A SUPPRIMER
		   else
		      {System.show Msg#' alors qu on est en mode notyourturn'}
		      state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) %%
		   end

		 
		[] yourturn then

		   case Msg
		    
		 % A SUPPRIMER
		   of yourturn then
		      {System.show Msg#' alors qu on est en mode yourturn'}
		      state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) %%
		    
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
			    {Send Config.mapPorts.NewX.NewY brave(enter NewF NBullets)}
			    if ActionsLeft == 1 then
			       {CheckKill NewX NewY NewF NBullets Item}
			       {Send Config.controllerPort finish(brave)}
			       {GUI.updateMovesCount ActionsLeft-1}
			       state(notyourturn NewX NewY NewF Ack ActionsLeft-1 NBullets NFood NMedicine)
			    else
			       {GUI.updateMovesCount ActionsLeft-1}
			       {CheckKill NewX NewY NewF NBullets Item}
			       state(Mode NewX NewY NewF Ack ActionsLeft-1 NBullets NFood NMedicine)
			    end
			   			     
			 elseif Ack==5 then
			    if NMedicine+NFood >= Config.nWantedObjects then
			       {Config.success} % end of game
			        state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) % ???? what to do?
			    else
			       state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) % skip
			    end
			    
			 else
			    {System.show Ack}
			    state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) %%
			 end
		      end
		    
		    
		   [] pickup then
		      {CheckKill X Y F NBullets Item}
		      {System.show 'a priori ActionsLeft est > 0...'#ActionsLeft}
		      {Send Config.mapPorts.X.Y brave(pickup)}
		       
		      if Item == 2 then
			 if ActionsLeft == 1 then
			    {Send Config.controllerPort finish(brave)}
			    {GUI.updateBulletsCount NBullets+3}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    state(notyourturn X Y F 0 ActionsLeft-1 NBullets+3 NFood NMedicine)
			 else
			    {GUI.updateBulletsCount NBullets+3}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    state(Mode X Y F 0 ActionsLeft-1 NBullets+3 NFood NMedicine) %%
			 end
			  
		      elseif Item == 3 then
			 if ActionsLeft == 1 then
			    {Send Config.controllerPort finish(brave)}
			    {GUI.updateCollectedItemsCount NFood+NMedicine+1 NFood+1 Item}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    state(notyourturn X Y F 0 ActionsLeft-1 NBullets NFood+1 NMedicine) %%
			 else
			    {GUI.updateCollectedItemsCount NFood+NMedicine+1 NFood+1 Item}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    state(Mode X Y F 0 ActionsLeft-1 NBullets NFood+1 NMedicine) %%
			 end
			 
		      elseif Item == 4 then
			 if ActionsLeft == 1 then
			    {Send Config.controllerPort finish(brave)}
			    {GUI.updateCollectedItemsCount NFood+NMedicine+1 NMedicine+1 Item}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    state(notyourturn X Y F 0 ActionsLeft-1 NBullets NFood NMedicine+1) %%
			 else
			    {GUI.updateCollectedItemsCount NFood+NMedicine+1 NMedicine+1 Item}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    state(Mode X Y F 0 ActionsLeft-1 NBullets NFood NMedicine+1) %%
			 end
			    
		      else
			 state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) %%
		      end
		      
		   [] kill then
		      {GUI.drawCell Item X Y}
		      {Send Config.mapPorts.X.Y brave(quit)}
		      % et fermer port
		      {Config.gameOver}
		      state(killed X Y F Item ActionsLeft NBullets NFood NMedicine)
		      
		   [] updateNBullets then
		      {GUI.updateBulletsCount NBullets-1}
		      state(Mode X Y F Item ActionsLeft NBullets-1 NFood NMedicine)
		      
		   else
		       
		      {System.show 'Brave 123 grosse erreur!'}
		      state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) %%
		   end
		end
	     end}
   in
      Cid
   end
end
