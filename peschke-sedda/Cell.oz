%%%%%%%%%%%%%%%%%%%%%
%     THE CELL      %
%%%%%%%%%%%%%%%%%%%%%

functor
import
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
   % - zombie(scout Ack)
   % - zombie(enter ZombiePort)
   % - zombie(pickup Ack)
   % - zombie(quit)

    % Manages the Cell PortObjects
   fun {CellState Y X Init}
      CSid = {Config.newPortObject Init
	      fun {$ state(Person Item) Msg}
		 case Person

		 % nobody on the cell   
		 of nobody then

		    case Msg

		    of brave(scout Ack) then
		       if Item == 1 then % wall
			  Ack = ko
			  state(Person Item)
		       else % empty, bullets, food, med or door
			  Ack = Item
			  state(Person Item)
		       end

		    [] brave(enter F NBullets) then
		       state(brave(F NBullets) Item)
		       
		    [] brave(pickup) then
		       state(Person Item)

		    [] brave(quit) then
		       state(Person Item)
		       		       
		    [] zombie(scout Ack) then
		       if Item == 1 orelse Item == 5 then % wall or door
			  Ack = ko
			  state(Person Item)
		       else % empty, bullets, food or med
			  Ack = Item
			  state(Person Item)
		       end

		    [] zombie(enter ZombiePort2 ZombieF Ack) then
		       if Item == 1 orelse Item == 5 then
			  Ack = ko
			  state(Person Item)
		       else
			  Ack = Item
			  state(zombie(ZombiePort2 ZombieF) Item)
		       end

		    [] zombie(pickup) then
		       state(Person Item)
		       
		    [] zombie(quit) then
		       state(Person Item)
			  
		    else
		       state(Person Item)
		    end

		 % brave on the cell   
		 [] brave(F NBullets) then
		    case Msg
		       
		    of brave(pickup) then
		       if Item == 0 orelse Item == 1 orelse Item == 5 then % empty, wall or door
			  state(Person Item)
		       else % bullets, food or med
			  state(Person 0)
		       end

		    [] brave(quit) then
		       state(nobody Item)
		       
		    [] zombie(scout Ack) then
		       Ack = brave(F NBullets)
		       state(Person Item)

		    [] decreaseNBullets then
		       state(brave(F NBullets-1) Item)
		          
		    [] brave(scout Ack) then
		       Ack = ko
		       state(Person Item)

		    [] brave(enter) then
		       state(Person Item)
		       
		    [] zombie(enter ZombiePort ZombieF Ack) then
		       Ack = ko
		       state(Person Item)
		       
		    [] zombie(pickup) then
		       state(Person Item)

		    [] zombie(quit) then
		       state(Person Item)
		       
		    else
		       state(Person Item)
		    end

		 % zombie on the cell   
		 [] zombie(ZombiePort ZombieF) then
		    case Msg
		       
		    of brave(scout Ack) then
		       Ack = zombie(ZombiePort ZombieF)
		       state(Person Item)

		    [] brave(enter) then
		       state(Person Item)
		       
		    [] brave(pickup) then
		       state(Person Item)

		    [] brave(quit) then
		       state(Person Item)
		       
		    [] zombie(scout Ack) then
		       Ack = zombie(ZombiePort ZombieF)
		       state(Person Item)

		    [] zombie(enter ZombiePort ZombieF Ack) then
		       Ack = ko
		       state(Person Item)
		       
		    [] zombie(pickup) then
		       if Item == 0 orelse Item == 1 orelse Item == 5 then % empty, wall or door
			  state(Person Item)
		       else % bullets, food or med
			  state(Person 0)
		       end

		    [] zombie(quit) then
		       state(nobody Item)
			  
		    else
		       state(Person Item)
		    end
		    
		 % error in the state 
		 else
		    state(Person Item)
		 end
	      end}
   in
      CSid
   end
   
end