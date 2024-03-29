functor
import
   Application
   OS
   Property
   QTk at 'x-oz://system/wp/QTk.ozf'

   % For file reading
   Open
   Pickle

   % Our functors
   Config
   GUI
   Brave
   Controller
   Zombie
   Cell
   
define
   /* Variables */
   % Dimensions and content of the map
   Map
   MapHeight
   MapWidth
   EmptyCount
   ItemsCount

   Window

   % Arguments of the game
   X_init % the initial position
   Y_init % the initial position
   F_init % the initial facing
   NWantedObjects % the number of objects the player has to collect
   NBullets % the initial number of bullets
   NZombies % the initial number of zombies

   /* Procedures */
   % Input arguments
   Args = {Application.getArgs
	   record(
	      map(single char:&m type:atom default:'map_test.ozp')
	      zombie(single char:&s type:int default:Config.nZombiesDefault)
	      item(single char:&b type:int default:Config.nWantedObjectsDefault) 
	      bullet(single char:&n type:int default:Config.nBulletsDefault) 
	      )}

   % Load function for the map
   fun {LoadPickle URL}
      F = {New Open.file init(url:URL flags:[read])}
   in
      try
	 VBS
      in
	 {F read(size:all list:VBS)}
	 {Pickle.unpack VBS}
      finally
	 {F close}
      end
   end

   % Computes the number of items to be picked
   fun {ConvertPercentage Percent TotalCount}
      RPercent in
      if Percent < 0 then RPercent = 0
      elseif Percent > 100 then RPercent = 100
      else RPercent = Percent
      end

      if (RPercent*TotalCount) mod 100 == 0 then
	 (RPercent*TotalCount) div 100
      else
	 ((RPercent*TotalCount) div 100) + 1
      end
   end	 

   % Find the door on the map
   proc {FindDoor Map ?IDoor ?JDoor ?FDoor}
      Lines = {Width Map}
      Columns = {Width Map.Lines}
   in
      for I in 1..Lines do
	 for J in 1..Columns do
	    if Map.I.J == 5 then % door found!
	       IDoor = I JDoor = J
	       if I == 1 then FDoor = [1 0] % down
	       elseif I == Lines then FDoor = [~1 0]
	       elseif J == 1 then FDoor = [0 1]
	       elseif J == Columns then FDoor = [0 ~1]
	       else IDoor = error JDoor = error FDoor = error
	       end
	    end
	 end
      end
   end

    % Count the number of empty spaces and items on a map
   fun {DecryptMap Map}
      Lines = {Width Map}
      Columns = {Width Map.Lines}
      fun {Count I J EmptyA ItemsA}
	 if J < Columns then
	    if Map.I.J == 0 then % empty cell
	       {Count I J+1 EmptyA+1 ItemsA}
	    elseif Map.I.J == 3 orelse Map.I.J == 4 then % food or medicine
	       {Count I J+1 EmptyA ItemsA+1}
	    else
	       {Count I J+1 EmptyA ItemsA}
	    end
	 else % end of line
	    if I < Lines then
	       if Map.I.J == 0 then % empty cell
		  {Count I+1 1 EmptyA+1 ItemsA}
	       elseif Map.I.J == 3 orelse Map.I.J == 4 then % food or medicine
		  {Count I+1 1 EmptyA ItemsA+1}
	       else
		  {Count I+1 1 EmptyA ItemsA}
	       end
	    else % end of column
	       if Map.I.J == 0 then % empty cell
		  EmptyA+1#ItemsA
	       elseif Map.I.J == 3 orelse Map.I.J == 4 then % food or medecine
		  EmptyA#ItemsA+1
	       else % should happen
		  EmptyA#ItemsA
	       end
	    end
	 end
      end
   in
      {Count 1 1 0 0}     
   end
 

   % Checks if there is enough space on the map for the desired
   % number of zombies. If not, returns an upper bound :
   % the number of empty cells.
   proc {CheckZombiesCount EmptyCells Wanted ?Granted}
      if Wanted < EmptyCells then
	 Granted = Wanted
      else
	 Granted = EmptyCells
      end
   end
 
   % Randomly place the zombies on the map
   proc {PlaceZombies Height Width X_init Y_init F_init NZombies}
      proc {Place N}
	 if (N > NZombies) then skip
	 else
	    local RandX RandY RandF Ack in
	       RandX = ({OS.rand} mod Height)+1
	       RandY = ({OS.rand} mod Width)+1
	       RandF = {Config.randFacing}
	       
	       if (RandX == X_init+(F_init.1) andthen
		   RandY == Y_init+(F_init.2.1)) then
		  {Place N}
	       else
		  {Send Config.mapPorts.RandX.RandY zombie(enter Config.zombiesPorts.N RandF Ack)}
		  {Wait Ack}
		  if Ack == ko then
		     {Place N}
		  else
		     {GUI.drawCellBis Ack zombie RandX RandY RandF}
		     Config.zombiesPorts.N = {Zombie.zombieState N state(notyourturn RandX RandY RandF Ack 0)}
		     {Place N+1}
		  end
	       end
	    end
	 end
      end
   in
      {Place 1}
   end

   Zombieland % main function
in
   /* MASTER FUNCTION */
   proc {Zombieland}   
      /* Seed random number generator (only needed in Mozart1) */
      % {OS.srand 0}

      /* Get arguments */
      Map = {LoadPickle Args.map}
      MapHeight = {Width Map}
      MapWidth = {Width Map.1}
      {FindDoor Map X_init Y_init F_init}
      EmptyCount#ItemsCount = {DecryptMap Map}
      Config.nWantedObjects = Args.item
      NWantedObjects = {ConvertPercentage Config.nWantedObjects ItemsCount}
      Config.nBullets = Args.bullet
      NBullets = Config.nBullets
      {CheckZombiesCount EmptyCount Args.zombie Config.nZombies}
      NZombies = Config.nZombies

      /* Set up the GUI */
      {GUI.initLayout Map Window Config.bravePort GUI.grid GUI.gridHandle}
      %Window = GUI.window
      Window = {QTk.build GUI.desc}
      {Window set(title:"ZOMBIELAND")}
      {GUI.updateGoalCount NWantedObjects}
      {GUI.updateBulletsCount NBullets}

      /* Initialize the PortObjects */
      % Grid of cells
      Config.mapPorts = {MakeTuple mapPorts MapHeight}
      for I in 1..MapHeight do
	 Config.mapPorts.I = {MakeTuple r MapWidth}
	 for J in 1..MapWidth do
	    Config.mapPorts.I.J = {Cell.cellState I J state(nobody Map.I.J)}
	 end
      end
   
      % Zombies
      Config.zombiesPorts = {MakeTuple zombiesPorts NZombies}
      {PlaceZombies MapHeight MapWidth X_init Y_init F_init NZombies}

      % Controller
      Config.controllerPort = {Controller.controllerState X_init Y_init
			       state(brave NZombies Config.zombiesPorts 0 NWantedObjects ItemsCount)}

      % Brave
      {Send Config.mapPorts.X_init.Y_init brave(enter F_init NBullets)}
      {GUI.drawCellBis 0 brave X_init Y_init F_init}
      Config.bravePort = {Brave.braveState state(yourturn X_init Y_init F_init 5 Config.nAllowedMovesB NBullets 0 0)}

      /* Display the game */
      {Window show}
   end

   {Zombieland}
end
