%%%%%%%%%%%%%%%%%%%%%
%     THE BRAVE     %
%%%%%%%%%%%%%%%%%%%%%

functor
import
   System %%
   
   % Our functors
   Config
   GUI
   
export
   BraveState
   
define

   % Checks if someone has to be killed
   proc {CheckKill X Y F NBullets Item}
      
      {System.show 'Brave : checkkill'}
      
      local FF FL FR AckF AckL AckR in
	 % Checks if there is a zombie in front of the brave
	 FF = [~F.1 ~F.2.1]
	 FL = {Config.left F} {System.show ''#F#'left'#FL}
	 FR = {Config.right F} {System.show ''#F#'right'#FR}
	 {System.show ''#X#Y#(X-FF.1)#(Y-FF.2.1)}
	 {Send Config.mapPorts.(X-FF.1).(Y-FF.2.1) brave(scout AckF)}
	 {Wait AckF}
	 {System.show ''#AckF}
	 case AckF
	 of zombie(ZombiePort ZombieF) then
	    % If NBullets==0, the brave dies, otherwise the zombie dies
	    if ZombieF == FF andthen NBullets==0 then
	       {System.show 'Face : Le brave est tue'}
	       %{Config.gameOver}
	       {GUI.endOfGame lose}
	    else
	       {Send Config.bravePort updateNBullets}
	       {System.show 'Face : Le zombie est tue'}
	       {Send ZombiePort kill}
	    end
	 else
	    skip
	 end

	 % If the brave is not on a door, we have to check right and left
	 % If there is a zombie looking towards the brave, the brave dies
	 if Item \= 5 then
	    {Send Config.mapPorts.(X-FL.1).(Y-FL.2.1) brave(scout AckL)} {System.show ''#X#Y#(X-FL.1)#(Y-FL.2.1)}
	    {Send Config.mapPorts.(X-FR.1).(Y-FR.2.1) brave(scout AckR)} {System.show ''#X#Y#(X-FR.1)#(Y-FR.2.1)}
	    % ATTENTION VA FALLOIR CHANGER CA POUR PAS QUE CA BLOQUE INUTILMENT
	    {Wait AckL}
	    {Wait AckR}
	    {System.show ''#AckL#AckR}
	    case AckL
	    of zombie(ZombiePort ZombieF) then
	       if ZombieF == FL then
		  {System.show 'Face : Le brave est tue'}
		  %{Config.gameOver}
		  {GUI.endOfGame lose}
	       end
	    else
	       skip
	    end
	    case AckR
	    of zombie(ZombiePort ZombieF) then
	       if ZombieF == FR then
		  {System.show 'Face : Le brave est tue'}
		  %{Config.gameOver}
		  {GUI.endOfGame lose}
	       end
	    else
	       skip
	    end
	 end
      end
   end
   

   % Manages the Brave PortObject
   % X Y F = line, column, facing direction
   % Item = the item on the current cell
   fun {BraveState Init}
      Cid = {Config.newPortObject Init
	     fun {$ state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) Msg} %% retenir la commande
		
		{System.show 'Brave message '#Msg#', mode '#Mode}

		case Mode

		% Killed mode : every message is ignored   
		of killed then
		   state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine)

		% Notyourturn mode : only the yourturn, kill, getFacingBullet and updateNBullets are relevant
		[] notyourturn then
		   
		   case Msg
		    
		   of yourturn then
		      {GUI.updateMovesCount Config.nAllowedMovesB}
		      state(yourturn X Y F Item Config.nAllowedMovesB NBullets NFood NMedicine) %%
		      
		   [] kill then
		      {GUI.drawCell Item X Y}
		      {Send Config.mapPorts.X.Y brave(quit)}
		      % et fermer port
		      %{Config.gameOver}
		      {GUI.endOfGame lose}
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

		% Yourturn mode : you can now move and pickup
		[] yourturn then

		   case Msg
		    
		   of move(NewF) then
		      {System.show 'a priori ActionsLeft est > 0...'#ActionsLeft}
		      local NewX NewY Ack in
			 {Config.nextCell NewF X Y NewX NewY}
			 {Send Config.mapPorts.NewX.NewY brave(scout Ack)}
			 {Wait Ack}

			 % If you can go to the next cell, you do
			 if Ack == 0 orelse Ack == 2 orelse Ack == 3 orelse Ack == 4 then
			    {GUI.drawCell Item X Y}
			    {Send Config.mapPorts.X.Y brave(quit)}
			    {GUI.drawCellBis Ack brave NewX NewY NewF}
			    {Send Config.mapPorts.NewX.NewY brave(enter NewF NBullets)}
			    % If the brave has not more actions, it's no more it's turn
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

			 % If it is a door, you have to be sure that you have enough objects
			 elseif Ack == 5 then
			    if NMedicine+NFood >= Config.nWantedObjects then
			       %{Config.success} % end of game
			       {GUI.endOfGame win}
			        state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine)
			    else
			       state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) % skip
			    end
			 % If you can't move, you remain in you state   
			 else
			    {System.show Ack}
			    state(Mode X Y F Item ActionsLeft NBullets NFood NMedicine) %%
			 end
		      end
		    
		   % You pickup and update you state if there is an object 
		   [] pickup then
		      {CheckKill X Y F NBullets Item}
		      {System.show 'a priori ActionsLeft est > 0...'#ActionsLeft}
		      {Send Config.mapPorts.X.Y brave(pickup)}
		      {Send Config.controllerPort destroy(brave)}
		       
		      if Item == 2 then
			 {GUI.drawCellBis 0 brave X Y F}
			 if ActionsLeft == 1 then
			    {GUI.updateBulletsCount NBullets+3}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    {Send Config.controllerPort finish(brave)}
			    state(notyourturn X Y F 0 ActionsLeft-1 NBullets+3 NFood NMedicine)
			 else
			    {GUI.updateBulletsCount NBullets+3}
			    {GUI.updateMovesCount ActionsLeft-1}
			    {CheckKill X Y F NBullets Item}
			    state(Mode X Y F 0 ActionsLeft-1 NBullets+3 NFood NMedicine) %%
			 end
			  
		      elseif Item == 3 then
			 {GUI.drawCellBis 0 brave X Y F}
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
			 {GUI.drawCellBis 0 brave X Y F}
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

		   % A zombie killed you, you loose   
		   [] kill then
		      {GUI.drawCell Item X Y}
		      {Send Config.mapPorts.X.Y brave(quit)}
		      % et fermer port
		      %{Config.gameOver}
		      {GUI.endOfGame lose}
		      state(killed X Y F Item ActionsLeft NBullets NFood NMedicine)

		   % You killed a zombie, you lost one bullet   
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
