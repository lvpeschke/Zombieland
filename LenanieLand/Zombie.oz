%%%%%%%%%%%%%%%%%%%%%
%    THE ZOMBIE     %
%%%%%%%%%%%%%%%%%%%%%

functor
import
   OS

   % Our functors
   Config
   GUI

export
   ZombieState
   
define
   
   % True 20% of the time
   fun {RollDice5}
      if {OS.rand} mod 5 == 0 then true
      else false
      end
   end

   % Makes the next move
   % If you are stuck more than 15 times, you pass your turn
   proc {Move F Line Col ZombieNumber Compteur ?L0 ?C0 ?F0 ?Ack}
      local NewAck NewC NewL in
	 if Compteur >= 0 then
	    % You moves in the same direction if you can
	    {Config.nextCell F Line Col NewL NewC}
	    {Send Config.mapPorts.NewL.NewC zombie(enter Config.zombiesPorts.ZombieNumber F NewAck)}
	    % If you can't, you randomly change your facing direction and retrie
	    if NewAck == ko then
	       local NewF in
		  NewF = {Config.randFacing}
		  {Move NewF Line Col ZombieNumber Compteur-1 ?L0 ?C0 ?F0 ?Ack}
	       end
	    else
	       C0 = NewC
	       L0 = NewL
	       F0 = F
	       Ack = NewAck
	    end
	 else
	    L0 = Line
	    C0 = Col
	    F0 = F 
	    Ack = ko
	 end
      end
   end
      
   % Checks if someone has to be killed
   % If there is a brave with bullets in front of you, you lose
   % Otherwise, you win
   proc {CheckKill X Y F ZombieNumber ?Killed}
      local FF FL FR AckF AckL AckR K1 K2 K3 in
	 FF = [~F.1 ~F.2.1]
	 FL = {Config.left F}
	 FR = {Config.right F}
	 {Config.barrier
	  [proc {$} {Send Config.mapPorts.(X-FF.1).(Y-FF.2.1) zombie(scout AckF)} end
	   proc {$} {Send Config.mapPorts.(X-FL.1).(Y-FL.2.1) zombie(scout AckL)} end
	   proc {$} {Send Config.mapPorts.(X-FR.1).(Y-FR.2.1) zombie(scout AckR)} end]}
	 
	 case AckF
	 of brave(BraveF NBullets) then
	    if BraveF == FF andthen NBullets>0 then
	       K1 = 1
	       {Send Config.bravePort updateNBullets} 
	       {Send Config.zombiesPorts.ZombieNumber kill} 		  
	    else
	       K1 = 0
	       {Send Config.bravePort kill}
	    end
	 else
	    K1 = 0
	 end
	 case AckL
	 of brave(BraveF NBullets) then
	    if BraveF == FL andthen NBullets > 0 then
	       K2 = 1
	       {Send Config.bravePort updateNBullets}
	       {Send Config.zombiesPorts.ZombieNumber kill}
	    else
	       K2 = 0
	    end
	 else
	    K2 = 0
	 end
	 case AckR
	 of brave(BraveF NBullets) then
	    if BraveF == FR andthen NBullets > 0 then
	       K3 = 1
	       {Send Config.bravePort updateNBullets}
	       {Send Config.zombiesPorts.ZombieNumber kill}
	    else
	       K3 = 0
	    end
	 else
	    K3 = 0
	 end
	 Killed = K1 + K2 + K3
      end
   end

   %% States
   % - yourturn
   % - notyourturn
   % - killed

   %% Messages
   % - yourturn
   % - go
   % - kill

    % Manages the Zombie PortObject
   fun {ZombieState ZombieNumber Init}
      ZSid = {Config.newPortObject Init
	      fun {$ state(Mode Line Col F Item ActionsLeft) Msg}
		 
		 case Mode

		 % Killed mode : every message is ignored    
		 of killed then
		    state(Mode Line Col F Item ActionsLeft)

		 % Notyourturn mode : the zombie can only be killed or become active   
		 [] notyourturn then
		    
		    case Msg
		       
		    of yourturn then
		       {Send Config.zombiesPorts.ZombieNumber go}
		       state(yourturn Line Col F Item Config.nAllowedMovesZ)

		    [] kill then
		       {GUI.drawCell zombieburn1 Line Col}
		       {Delay 70}
		       {GUI.drawCell zombieburn2 Line Col}
		       {Delay 70}
		       {GUI.drawCell zombieburn3 Line Col}
		       {Delay 70}
		       {GUI.drawCell Item Line Col}
		       {Send Config.mapPorts.Line.Col zombie(quit)}
		       {Send Config.controllerPort kill(ZombieNumber)}
		       state(killed Line Col F Item ActionsLeft)
		       
		    else
		       state(Mode Line Col F Item ActionsLeft)
		    end

		 % Yourturn mode : the zombie can move   
		 [] yourturn then
		    
		    case Msg

		    % You can do something   
		    of go then
		       local Killed in
			  % First you check if someobody has to be killed
			  {CheckKill Line Col F ZombieNumber Killed}

			  % If you are still alive
			  if Killed == 0 then

			     % You can't move anymore, you become inactive
			     if ActionsLeft == 0 then % stop moving
				{Send Config.controllerPort finish(zombie)}
				state(notyourturn Line Col F Item 0)
				
			     % Otherwise you try to pick something if you can with 20% probability
			     else % move
				local Picked in
				   if (Item == 2 orelse Item == 3 orelse Item == 4) andthen {RollDice5} then
				      {Send Config.mapPorts.Line.Col zombie(pickup)}
				      Picked = 1
				   else
				      Picked = 0
				   end

				   % If you can move too, you move
				   if ActionsLeft > Picked then
				      local L0 C0 F0 Ack in
					 {Move F Line Col ZombieNumber 15 ?L0 ?C0 ?F0 ?Ack}
					 if Ack == ko then
					    {Send Config.zombiesPorts.ZombieNumber go} % keep moving!
					    {Delay 300}
					    if Picked == 1 then state(yourturn Line Col F 0 0)
					    else state(yourturn Line Col F Item 0) end
					 else
					    {Send Config.zombiesPorts.ZombieNumber go} % keep moving!
					    if Picked == 0 then {GUI.drawCell Item Line Col}
					    else {GUI.drawCell 0 Line Col} end
					    {Send Config.mapPorts.Line.Col zombie(quit)}
					    {GUI.drawCellBis Ack zombie L0 C0 F0}
					    {Delay 300}
					    state(yourturn L0 C0 F0 Ack ActionsLeft-1)
					 end
				      end
				   else
				      {Send Config.zombiesPorts.ZombieNumber go} % keep moving!
				      state(yourturn Line Col F 0 0)
				   end
				end
			     end

			  else
			     state(Mode Line Col F Item ActionsLeft)
			  end
		       end
			     
		    % Someone has killed you, you have to die burning  
		    [] kill then
		       {GUI.drawCell zombieburn1 Line Col}
		       {Delay 70}
		       {GUI.drawCell zombieburn2 Line Col}
		       {Delay 70}
		       {GUI.drawCell zombieburn3 Line Col}
		       {Delay 70}
		       {GUI.drawCell Item Line Col}
		       {Send Config.mapPorts.Line.Col zombie(quit)}
		       {Send Config.controllerPort kill(ZombieNumber)}
		       state(killed Line Col F Item ActionsLeft)
		       
		    else
		       % error
		       state(Mode Line Col F Item ActionsLeft)
		    end
		    
		 else
		    % error
		    state(Mode Line Col F Item ActionsLeft)
		 end
	      end}
      
   in
      ZSid
   end
end
