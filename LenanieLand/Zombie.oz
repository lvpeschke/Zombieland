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
	      fun {$ state(Mode Line Col F Item ActionsLeft) Msg}
		 case Mode
		    
		 of notyourturn then % zombie not active
		    case Msg
		       
		    of yourturn then
		       {System.show 'Zombie.oz 64 '#ZombieNumber#'premier go, reste '#Config.nAllowedMovesZ}
		       {Send Config.zombiesPorts.ZombieNumber go} % send message to yourself % TODO
		       state(yourturn Line Col F Item Config.nAllowedMovesZ)
		       
		    [] go then
		       {System.show 'Zombie.oz 69'#'erreur'}
		       {Application.exit 1}
		       
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

		       if ActionsLeft == 0 then % stop moving
			  {System.show 'Zombie.oz 90 '#ZombieNumber#'Zombie send(finish)'}
			  {Send Config.controllerPort finish(zombie)}
			  state(notyourturn Line Col F Item 0)

		       else % move
			  {System.show 'Zombie.oz 90 '#ZombieNumber#' go go go, reste '#ActionsLeft}
			  {Send Config.zombiesPorts.ZombieNumber go} % keep moving!
			  
			  L0 C0 Ack in
			  {Move F Line Col L0 C0} % compute new cell in same direction
			  {Send Config.mapPorts.L0.C0 zombie(tryenter Ack)} % try new cell in same direction % TODO
			  {Wait Ack}

			  if Ack == ok then
			     {Send Config.mapPorts.Line.Col zombie(quit)} % quit previous cell
			     state(yourturn L0 C0 F Item ActionsLeft-1)
			  
			  elseif Ack == 0 orelse Ack == 2 orelse Ack == 3 orelse Ack == 4 then

			    {GUI.drawCell Item Line Col}
			    {Send Config.mapPorts.Line.Col zombie(quit)}
			    {GUI.drawCell zombie L0 c0}
			    {Send Config.mapPorts.L0.c0 zombie(enter)}
			     if ActionsLeft >= 2 andthen {RollDice5} then
				{Send Config.mapPorts.L0.C0 zombie(pickup)}
				state(yourturn L0 C0 F empty ActionsLeft-2)
			     else
				state(yourturn L0 C0 F Ack ActionsLeft-1)
			     end
			     
			  elseif Ack == ko then
			     {System.show 'Zombie.oz 116 '#ZombieNumber#' nouveau face '#ActionsLeft}
			     F1 in
			     {NewFacing F F1}
			     state(yourturn Line Col F1 Item ActionsLeft)	   
			  else
			     {System.show 'Zombie.oz 120'#ZombieNumber#'erreur'}
			     {Application.exit 1}
			  end
		       end
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
