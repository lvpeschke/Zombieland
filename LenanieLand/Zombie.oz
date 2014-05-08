functor
import
   OS
   Application %%
   System %%

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

   % Possible F values
   % Up [~1 0]
   % Left [0 ~1]
   % Down [1 0]
   % Right [0 1]

   proc {NewFacing ?NewF}
      local R in
	 R = ({OS.rand} mod 4)
	 if R==0 then NewF = [0 1]
	 elseif R==1 then NewF = [1 0]
	 elseif R==2 then NewF = [0 ~1]
	 else NewF = [~1 0]
	 end
      end
   end

   proc {Move F Line Col ZombieNumber Compteur ?L0 ?C0 ?F0 ?Ack}
      local NewAck NewC NewL in
	 {System.show 'Move'#Compteur}
	 if Compteur>=0 then
	    {NextCell F Line Col NewL NewC} % compute new cell in same direction
	    {Send Config.mapPorts.NewL.NewC zombie(enter Config.zombiesPorts.ZombieNumber F NewAck)}
	    if NewAck==ko then
	       {System.show 'Ack'#NewAck}
	       local NewF in
		  {NewFacing NewF}
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
   
   proc {NextCell F OldL OldC ?NewL ?NewC}
      [DLine DCol] = F in
      NewL = OldL+DLine
      NewC = OldC+DCol
   end
      
   %% States
   % - yourturn
   % - notyourturn

   %% Messages
   % - yourturn
   % - go

     % CheckKill
   
   proc {CheckKill X Y F ZombieNumber ?Killed}
      {System.show 'Zombie : checkkill'}
      local FF FL FR AckF AckL AckR BraveF K1 K2 K3 in
	 FF = [~F.1 ~F.2.1]
	 FL = {Config.left F} {System.show ''#F#'left'#FL}
	 FR = {Config.right F} {System.show ''#F#'right'#FR}
	 {Send Config.mapPorts.(X-FF.1).(Y-FF.2.1) zombie(tryenter AckF)}
	 {Send Config.mapPorts.(X-FL.1).(Y-FL.2.1) zombie(tryenter AckL)}
	 {Send Config.mapPorts.(X-FR.1).(Y-FR.2.1) zombie(tryenter AckR)}
	 {Wait AckF} {Wait AckL} {Wait AckR} % A CHANGER
	 {System.show ''#AckF#AckL#AckR}
	 case AckF
	 of brave(BraveF NBullets) then
	    if BraveF == FF andthen NBullets>0 then
	       {System.show 'Zombie : Face : Le zombie est tue'}
	       K1 = 1
	       {Send Config.bravePort updateNBullets} 
	       {Send Config.zombiesPorts.ZombieNumber kill} 		  
	    else
	       K1 = 0
	       {System.show 'Zombie :Face : Le brave est tue'}
	       {Send Config.bravePort kill}
	    end
	 else
	    K1 = 0
	 end
	 case AckL
	 of brave(BraveF NBullets) then
	    if BraveF == FL andthen NBullets>0 then
	       {System.show 'Zombie : Gauche : Le zombie est tue'}
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
	    if BraveF == FR andthen NBullets>0 then
	       {System.show 'Zombie : Droite : Le zombie est tue'}
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

   fun {ZombieState ZombieNumber Init}
      ZSid = {Config.newPortObject Init
	      fun {$ state(Mode Line Col F Item ActionsLeft) Msg}

		 {System.show 'Zombie '#Mode#Line#Col#F#Msg}
		 
		 case Mode

		 of killed then state(Mode Line Col F Item ActionsLeft)
		    
		 [] notyourturn then % zombie not active
		    case Msg
		       
		    of yourturn then
		       {System.show 'Zombie.oz 64 '#ZombieNumber#'premier go, reste '#Config.nAllowedMovesZ}
		       {Send Config.zombiesPorts.ZombieNumber go} % send message to yourself % TODO
		       state(yourturn Line Col F Item Config.nAllowedMovesZ)
		       
		    [] go then
		       {System.show 'Zombie.oz 69'#'erreur'}
		       {Application.exit 1}

		    [] kill then
		       {GUI.drawCell Item Line Col}
		       {Send Config.mapPorts.Line.Col zombie(quit)}
		       {Send Config.controllerPort kill(ZombieNumber)}
		       % et former port
		       state(killed Line Col F Item ActionsLeft)
		       
		    else
		       {System.show 'Zombie.oz 73'#'erreur'}
		       {Application.exit 1}
		    end

		    
		 [] yourturn then % zombie active
		    {System.show 'Zombie.oz 79'#ZombieNumber#'Zombie yourturn, message '#Msg}

		    case Msg		       

		    of yourturn then
		       {System.show 'Zombie.oz 84'#ZombieNumber#'Zombie : etat '#Mode#', message '#Msg#' PAS BIEN'}
		       {Application.exit 1}

		    [] go then
		       local Facing NBullets Killed in
			  
			  {CheckKill Line Col F ZombieNumber Killed}

			  if Killed == 0 then
			  
			     if ActionsLeft == 0 then % stop moving
				{System.show 'Zombie.oz 90 '#ZombieNumber#'Zombie send(finish)'}
				{Send Config.controllerPort finish(zombie)}
				state(notyourturn Line Col F Item 0)

			     else % move
				local Picked in 
				   {System.show 'Zombie.oz 90 '#ZombieNumber#' go go go, reste '#ActionsLeft}

				   if (Item==2 orelse Item==3 orelse Item==4) andthen {RollDice5} then
				      {Send Config.mapPorts.Line.Col zombie(pickup)}
				%{Send Config.zombiesPorts.ZombieNumber go} % keep moving!
				%state(yourturn Line Col F 0 ActionsLeft-1)
				      Picked=1
				   else
				      Picked=0
				   end

				   if ActionsLeft>Picked then
				      local L0 C0 F0 Ack in
					 {Move F Line Col ZombieNumber 15 ?L0 ?C0 ?F0 ?Ack}
					 if Ack==ko then
					    {Send Config.zombiesPorts.ZombieNumber go} % keep moving!
					    if Picked==1 then state(yourturn Line Col F 0 0)
					    else state(yourturn Line Col F Item 0) end
					 else
					    {Send Config.zombiesPorts.ZombieNumber go} % keep moving!
					    if Picked==0 then {GUI.drawCell Item Line Col}
					    else {GUI.drawCell 0 Line Col} end
					    {Send Config.mapPorts.Line.Col zombie(quit)}
					    {GUI.drawCell zombie L0 C0}
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
			     
		       
		    [] kill then
		       {GUI.drawCell Item Line Col}
		       {Send Config.mapPorts.Line.Col zombie(quit)}
		       {Send Config.controllerPort kill(ZombieNumber)}
		       % et former port
		       state(killed Line Col F Item ActionsLeft)
		       
		    else
		       {System.show 'Zombie.oz 125'#ZombieNumber#'Zombie : error in the message'}
		       {Application.exit 1}
		    end
		 else
		    {System.show 'Zombie.oz 129'#ZombieNumber#'Zombie : error in the state'}
		    {Application.exit 1}
		 end
	      end}
      
   in
      ZSid
   end
end
