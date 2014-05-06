functor
import
   Application
   OS

   % Our functors
   Config

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

   proc {NewFacing OldF OldL OldC ?NewF ?NewL ?NewC}
      case OldF
      of [~1 0] then
	 NewF = [0 1]  NewL = OldL   NewC = OldC+1
      [] [0 1] then
	 NewF = [1 0]  NewL = OldL+1 NewC = OldC
      [] [1 0] then 
	 NewF = [0 ~1] NewL = OldL   NewC = OldC-1
      [] [0 ~1] then
	 NewF = [~1 0] NewL = OldL-1 NewC = OldC
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
		    
		 of notyourturn then skip % zombie not active
		    case Msg
		    of yourturn(zombie) then
		       state(yourturn Line Col F Config.nAllowedMovesZ)
		       
		    else
		       {System.show 'Zombie : etat '#Mode#', message '#Msg}
		       {Application.exit 1}
		    end

		    
		 [] yourturn then skip % zombie active

		    case Msg
		    of yourturn(zombie) then
		       {System.show 'Zombie : etat '#Mode#', message '#Msg}
		       {Application.exit 1}
		       
		    else
		       NewL0 NewC0 Ack in

		       % try forward
		       {Move F Line Col NewL NewC}
		       {Send MapPorts.NewL.NewC zombie(enter Ack)}
		       {Wait Ack}
		       if Ack == ok then
			  {Send MapPorts.Line.Col zombie(quit)}
			  state(yourturn NewL NewC ActionsLeft-1)
		       elseif Ack == 2 orelse Ack == 3 orelse Ack == 4 then
			  
		    end

		       %% NOT 4 IF LEVELS!!! CHANGE STATE EACH TIME!!
		    
		 else skip

		    
		 end
	      end}
   in
      ZSid
   end
end
