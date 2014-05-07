functor
import
   Application %%
   System %%

   % Our functors
   Config

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
	      fun {$ state(Person Item) Msg}
		 case Person
		    
		 of nobody then % nobody on the cell

		    case Msg

		    of brave(tryenter Ack) then
		       if Item == 1 then % wall
			  Ack = ko
			  state(Person Item) % skip
		       else % empty, bullets, food, med or door
			  Ack = Item
			  state(Person Item) % skip
		       end

		    [] brave(enter) then
		       state(brave Item)
		       
		    [] brave(pickup) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip

		    [] brave(quit) then
		       state(Person Item) % skip
		       		       
		    [] zombie(tryenter Ack) then
		       if Item == 1 orelse Item == 5 then % wall or door
			  Ack = ko
			  state(Person Item) % skip
		       else % empty, bullets, food or med
			  Ack = Item
			  state(Person Item) % skip
		       end

		    [] zombie(enter) then
		       state(zombie Item)

		    [] zombie(pickup) then
		       state(Person Item) % skip
		       
		    [] zombie(quit) then
		       state(Person Item) % skip
			  
		    else
		       {System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		       state(Person Item)
		    end

		    
		 [] brave then % brave on the cell
		    case Msg
		       
		    of brave(tryenter Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       Ack = ko
		       state(Person Item) % skip

		    [] brave(enter) then
		       state(Person Item) % skip
		       
		    [] brave(pickup) then
		       if Item == 0 orelse Item == 1 orelse Item == 5 then % empty, wall or door
			  state(Person Item) % skip
		       else % bullets, food or med
			  state(Person 0)
		       end

		    [] brave(quit) then
		       state(nobody Item)
		       
		    [] zombie(tryenter Ack) then
		       Ack = ko
		       state(Person Item) % skip

		    [] zombie(enter) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip
		       
		    [] zombie(pickup) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip

		    [] zombie(quit) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip
		       
		    else
		       %{System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		       state(Person Item)
		    end

		    
		 [] zombie then % zombie on the cell
		    case Msg
		       
		    of brave(tryenter Ack) then
		       Ack = ko
		       state(Person Item) % skip

		    [] brave(enter) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip
		       
		    [] brave(pickup) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip

		    [] brave(quit) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip
		       
		    [] zombie(tryenter Ack) then
		       Ack = ko
		       state(Person Item) % skip

		    [] zombie(enter) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       state(Person Item) % skip
		       
		    [] zombie(pickup) then
		       if Item == 0 orelse Item == 1 orelse Item == 5 then % empty, wall or door
			  state(Person Item) % skip
		       else % bullets, food or med
			  state(Person 0)
		       end

		    [] zombie(quit) then
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