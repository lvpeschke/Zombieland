functor
export
   Map % the map of the room to be displayed
   AllowedMoves % the number of moves the player is allowed in 1 turn
   WantedNObjects % the number of objects the player has to collect
   NZombies % the initial number of zombies in the room

   
define
   Map = map((1 1 1 1 1) (1 0 0 2 1) (1 4 0 1 1) (1 5 1 1 1)) %%
   AllowedMoves = 2
   WantedNObjects = 3
   NZombies = 0
end
