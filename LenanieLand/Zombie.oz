functor
import
   OS
   Application %%
   System %%

   % Our functors
   Config

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
      of [~1 0] then NewF = [0 1]
      [] [0 1] then NewF = [1 0]
      [] [1 0] then NewF = [0 ~1]
      [] [0 ~1] then NewF = [~1 0]
      else
	 {System.show 'Zombie.oz'#'Bad facing! '#OldF}%%
	 {Application.exit 1}%%
      end	 
   end

   proc {Move F OldL OldC ?NewL ?NewC}
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

   fun {ZombieState ZombieNumber Init}
      ZSid = {Config.newPortObject Init
	      fun {$ state(Mode Line Col F ActionsLeft) Msg}
		 case Mode
		    
		 of notyourturn then % zombie not active
		    {System.show 'Zombie.oz'#'la'}
		    case Msg
		       
		    of yourturn then
		       {System.show 'Zombie.oz 64 '#'Zombie : etat '#Mode#', message '#Msg}
		       {Send Config.zombiesPorts.ZombieNumber go} % send message to yourself % TODO
		       state(yourturn Line Col F Config.nAllowedMovesZ)
		       
		    [] go then
		       {System.show 'Zombie.oz 69'#'Zombie : etat '#Mode#', message '#Msg}
		       {Application.exit 1}
		       
		    else
		       {System.show 'Zombie.oz 73'#'Zombie : etat '#Mode#', message '#Msg}
		       {Application.exit 1}
		    end

		    
		 [] yourturn then % zombie active
		    {System.show 'Zombie.oz 79'#'Zombie yourturn, etat '#Msg}

		    case Msg		       

		    of yourturn then
		       {System.show 'Zombie.oz 84'#'Zombie : etat '#Mode#', message '#Msg#' PAS BIEN'}
		       {Application.exit 1}

		    [] go then

		       if ActionsLeft == 0 then % stop moving
			  {Send Config.controllerPort finish(zombie)}
			  state(notyourturn Line Col F 0)

		       else % move
			  {Send Config.zombiesPorts.ZombieNumber go} % keep moving!
			  
			  L0 C0 Ack in
			  {Move F Line Col L0 C0} % compute new cell in same direction
			  {Send Config.mapPorts.L0.C0 zombie(enter Ack)} % try new cell in same direction % TODO
			  {Wait Ack}

			  if Ack == ok then
			     {Send Config.mapPorts.Line.Col zombie(quit)} % quit previous cell
			     state(yourturn L0 C0 F ActionsLeft-1)
			  
			  elseif Ack == 2 orelse Ack == 3 orelse Ack == 4 then
			     {Send Config.mapPorts.Line.Col zombie(quit)} % quit previous cell
			     if ActionsLeft >= 2  andthen {RollDice5} then
				{Send Config.mapPorts.L0.C0 zombie(pickup)}  % random pickup, 20% chance
				state(yourturn L0 C0 F ActionsLeft-2)
			     else
				state(yourturn L0 C0 F ActionsLeft-1)
			     end

			  elseif Ack == ko then
			     F1 in
			     {NewFacing F F1}
			     state(yourturn Line Col F1 ActionsLeft)	   
			  else
			     {System.show 'Zombie.oz 120'#'Zombie : etat '#Mode#', ack '#Ack}
			     {Application.exit 1}
			  end
		       end
		    else
		       {System.show 'Zombie.oz 125'#'Zombie : error in the message'}
		       {Application.exit 1}
		    end
		 else
		    {System.show 'Zombie.oz 129'#'Zombie : error in the message'}
		    {Application.exit 1}
		 end
	      end}
      
   in
      ZSid
   end
end
