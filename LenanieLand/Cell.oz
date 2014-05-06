functor
import
   Application
   OS
   System

   % Our functors
   Config
   GUI

export
   MapCell

define

   % PortObject %% TODO : dans Config ???
   fun {NewPortObject Init Fun}
      proc {MsgLoop S1 State}
	 case S1 of Msg|S2 then
	    %{System.show Msg}
	    {MsgLoop S2 {Fun State Msg}}
	 [] nil then skip end
      end
      Sin
   in
      thread {MsgLoop Sin Init} end
      {NewPort Sin}
   end

   %% IL MANQUE LE QUIT!!!
   fun {MapCell Y X Init}
      MCid = {NewPortObject Init
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
			  state(nobody Item) %% A DISCUTER, mais sinon on peut avoir un brave qui va la ou il y a un brave s'il tente plusieurs fois la porte
		       elseif Item == 0 orelse Item == 2 orelse Item == 3 orelse Item == 4 then
			  Ack = ok
			  {GUI.drawCell brave Y X}
			  state(brave Item)
		       else
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
		       end
		       
		    [] brave(pickup Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}		       
		       
		    [] zombie(enter Ack) then
		       if Item == 1 orelse Item == 5 then
			  Ack = ko
			  state(nobody Item)
		       elseif Item == 0 orelse Item == 2 orelse item == 3 orelse Item == 4 then
			  Ack = ok
			  {GUI.drawCell zombie Y X}
			  state(zombie Item)
		       else
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
		       end

		    [] zombie(pickup Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
			  
		    else
		       {System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		    end

		    
		 [] brave then % brave on the cell
		    case Msg
		       
		    of brave(enter Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       
		    [] brave(pickup Ack) then
		       if Item == 1 orelse Item == 5 then
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
		       elseif Item == 2 orelse Item == 3 orelse Item == 4 then
			  Ack = Item
			  state(brave 0) % empty now that something has been picked up
		       elseif Item == 0 then
			  Ack = ko
			  state(brave Item)
		       else
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
		       end			  
		       
		    [] zombie(enter Ack) then
		       Ack = ko
		       state(brave Item)
		       
		    [] zombie(pickup Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       
		    else
		       {System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		    end

		    
		 [] zombie then % zombie on the cell
		    case Msg
		       
		    of brave(enter Ack) then
		       Ack = ko
		       state(zombie Item)
		       
		    [] brave(pickup Ack) then
		       {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
		       {Application.exit 1}
		       
		    [] zombie(enter Ack) then
		       Ack = ko
		       state(zombie Item)
		       
		    [] zombie(pickup Ack) then
		       if Item == 1 orelse Item == 5 then
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
		       elseif Item == 2 orelse Item == 3 orelse Item == 4 then
			  Ack = Item
			  state(zombie 0) % empty now that something has been picked up
		       elseif Item == 0 then
			  Ack = ko
			  state(zombie Item)
		       else
			  {System.show 'Cell : etat '#Person#', message '#Msg#' item '#Item}
			  {Application.exit 1}
		       end
			  
		    else
		       {System.show 'Cell : etat '#Person#' message interdit!'#Msg}
		       {Application.exit 1}
		    end
		    
		 % error in the state 
		 else
		    {System.show 'Cell : etat impossible!'}
		    {Application.exit 1}
		 end
		 
	      end}
   in
      MCid
   end
   
end