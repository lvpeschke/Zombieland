functor
import
   Application %%
   System %%

   % Our functors
   Config
   GUI

export
  CellState

define

   %% States
   % - nobody
   % - brave
   % - zombie

   %% Messages
   % - brave(enter Ack)
   % - brave(pickup Ack)
   % - brave(quit)
   % - zombie(enter Ack)
   % - zombie(pickup Ack)
   % - zombie(quit)

   fun {CellState Y X Init}
      CSid = {Config.newPortObject Init
	      fun {$ Msg state(Person Item)}
		 case Person
		    
		 of nobody then % nobody on the cell

		    case Msg

		    of zombie(enter Ack) then
		       if Item == 1 orelse Item == 5 then
			  Ack = ko
			  state(nobody Item)
		       elseif Item == 0 then
			  Ack = ok
			  {GUI.drawCell zombie Y X}
			  state(zombie Item)
		       elseif Item == 2 orelse item == 3 orelse Item == 4 then
			  Ack = Item
			  {GUI.drawCell zombie Y X}
			  state(zombie Item)
		       else
			  %{System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  %{Application.exit 1}
			  state(Person Item)
		       end
		    else
		       {System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		       state(Person Item)
		    end
		    
		 % error in the state 
		 else
		    {System.show 'Cell : etat impossible!'}
		    {Application.exit 1}
		    state(Person Item)
		 end
	      end}
   in
      CSid
   end
   
end