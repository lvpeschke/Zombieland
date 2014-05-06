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
		       
		    of brave(enter Ack) then
		       if Item == 1 then
			  Ack = ko
			  state(nobody Item)
		       elseif Item == 5 then
			  Ack = door
			  state(nobody Item) %% A DISCUTER, mais sinon on peut avoir un brave qui va la ou
			                     %% il y a un brave s'il tente plusieurs fois la porte
		       elseif Item == 0 orelse Item == 2 orelse Item == 3 orelse Item == 4 then
			  Ack = ok
			  {GUI.drawCell brave Y X}
			  state(brave Item)
		       else
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
			  state(Person Item)
		       end
		       
		    [] brave(pickup Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)

		    [] brave(quit) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)
		       		       
		    [] zombie(enter Ack) then
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
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
			  state(Person Item)
		       end

		    [] zombie(pickup) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)

		    [] zombie(quit) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)
			  
		    else
		       {System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		       state(Person Item)
		    end

		    
		 [] brave then % brave on the cell
		    case Msg
		       
		    of brave(enter Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)
		       
		    [] brave(pickup Ack) then
		       if Item == 1 orelse Item == 5 then
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
			  state(Person Item)
		       elseif Item == 2 orelse Item == 3 orelse Item == 4 then
			  Ack = Item
			  state(brave 0) % empty now that something has been picked up
		       elseif Item == 0 then
			  Ack = ko
			  state(brave Item)
		       else
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
			  state(Person Item)
		       end

		    [] brave(quit) then
		       {GUI.drawCell Item Y X}
		       state(nobody Item)
		       
		    [] zombie(enter Ack) then
		       Ack = ko
		       state(brave Item)
		       
		    [] zombie(pickup) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)

		    [] zombie(quit) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)
		       
		    else
		       {System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		       state(Person Item)
		    end

		    
		 [] zombie then % zombie on the cell
		    case Msg
		       
		    of brave(enter Ack) then
		       Ack = ko
		       state(zombie Item)
		       
		    [] brave(pickup Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)

		    [] brave(quit) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       state(Person Item)
		       
		    [] zombie(enter Ack) then
		       Ack = ko
		       state(zombie Item)
		       
		    [] zombie(pickup) then
		       if Item == 0 orelse Item == 1 orelse Item == 5 then
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
			  state(Person Item)
		       elseif Item == 2 orelse Item == 3 orelse Item == 4 then
			  state(zombie 0) % empty now that something has been picked up
		       else
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
			  state(Person Item)
		       end

		    [] zombie(quit) then
		       {GUI.drawCell Item Y X}
		       state(nobody Item)
			  
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