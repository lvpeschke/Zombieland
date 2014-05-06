functor
import
   Application
   OS

   % Our functors
   Config
   Controller

   System %%

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

   proc {NewFacing OldF ?NewF}
      case OldF
      of [~1 0] then
	 NewF = [0 1]
      [] [0 1] then
	 NewF = [1 0]
      [] [1 0] then 
	 NewF = [0 ~1]
      [] [0 ~1] then
	 NewF = [~1 0]
      else
	 {System.show 'Bad facing! '#OldF}
	 {Application.exit 1}
      end	 
   end

   proc {Move F OldL OldC ?NewL ?NewC}
      % F is [DLine DCol]
      NewL = OldL+F.1
      NewC = OldC+F.2.1
   end
   
      

   %% States
   % - yourturn
   % - notyourturn

   %% Messages
   % - yourturn(zombie)

   fun {ZombieState Init}
      ZSid = {Config.newPortObject Init
	      fun {$ Msg state(Mode Line Col F ActionsLeft)}
		 case Mode
		    
		 of notyourturn then % zombie not active
		    case Msg
		    of yourturn(zombie) then
		       state(yourturn Line Col F Config.nAllowedMovesZ)
		       
		    else
		       {System.show 'Zombie : etat '#Mode#', message '#Msg}
		       {Application.exit 1}
		    end

		    
		 [] yourturn then % zombie active

		    if ActionsLeft == 0 then % no more moves
		       {Send Controller.controllerState finish(zombie)}
		       state(notyourturn Line Col F 0)

		    else
		       L0 C0 Ack in
		       {Move F Line Col L0 C0} % compute new cell in same direction
		       {Send Config.mapPorts.L0.C0 zombie(enter Ack)} % try new cell in same direction
		       {Wait Ack}
		       
		       if Ack == ok then
			  {Send Config.mapPorts.Line.Col zombie(quit)}
			  state(yourturn L0 C0 F ActionsLeft-1)
			  
		       elseif Ack == 2 orelse Ack == 3 orelse Ack == 4 then
			  {Send Config.mapPorts.Line.Col zombie(quit)}
			  if ActionsLeft >= 2  andthen {RollDice5} then % random pickup, 20% chance
			     {Send Config.mapPorts.L0.C0 zombie(pickup)}
			     state(yourturn L0 C0 F ActionsLeft-2)
			  else
			     state(yourturn L0 C0 F ActionsLeft-1)
			  end

		       elseif Ack == ko then
			  F1 in
			  {NewFacing F F1}
			  state(yourturn Line Col F1 ActionsLeft)
			  
		       else
			  {System.show 'Zombie : etat '#Mode#', ack '#Ack}
			  {Application.exit 1}
		       end
		    end
		 else
		    {System.show 'Zombie :error in the state'}
		    {Application.exit 1}
		 end
	      end}
   in
      ZSid
   end
end
