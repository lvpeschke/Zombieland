declare
fun {Room Init}
   Cid={NewPortObject Init
	fun {$ state(Map Pos NObjects NBullets NZombies ActionsLeft) Msg}
	   case Msg
	   of Person(Action)
	      if Person==brave && ActionsLeft==0 then skip
	      else
		 case Action
		 of move(D) then NewPos = {CalcNewPos Pos D}
		    if {ValidMove Map NewPos Person NObjects}==0 %tester si 0 
		       state(Map Pos NObjects NBullets NZombies ActionsLeft)
		    else
		       state(Map NewPos NObjects NBullets NZombies ActionsLeft-1)
		    end
		 [] pickup then
		    if {ValidPickUp Map Pos}==0
		       state(Map Pos NObjects NBullets NZombies ActionsLeft)
		    else
		       if Person==brave
			  state(Map Pos NObjects NBullets NZombies ActionsLeft-1)
		       else
			  % dire au zombie de décrémenter son action left
		       end
		    end       
		 end
	      end
	   end
	end}
in
   Cid
end

fun {CalcNewPos Pos Move}
   Pos = [X Y F]
   Move = [DX DY]
   [X+DX Y+DY Move]
end

fun {ValidMove Map Pos Person NObjects}
   Pos = [X Y F]
   Value = Map.X.Y
   if Value == 1
      0
   elseif Value==5
	 if Person==Brave && NObjects==WantedNObjects
	    1
	 else
	    0
	 end
   else
      1
   end   
end

fun {ValidPickUp Map Pos}
   Pos = [X Y Z]
   Value = Map.X.Y
   if Value==2 || Value==3 || Value==4
      1
      % incrémenter le pickup si brave
      % virer de la mapy
   else
      0
   end
   % enlever de la MAP et envoyer message à afficage
end
