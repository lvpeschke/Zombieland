functor
import
   Application
   OS
   Property
   QTk at 'x-oz://system/wp/QTk.ozf'

   % For file reading
   Open %at 'x-oz://system/Open.ozf'
   Pickle

   % Our functors
   Config
   GUI
   Brave
   Controller
   Zombie
   Cell

   System %%
   
define
   /* Variables */
   % Dimensions of the map
   Map
   MapHeight
   MapWidth

   % Arguments of the game
   X_init %%
   Y_init %%
   F_init %%
   NWantedObjects % the default number of objects the player has to collect
   NBullets % the default initial number of bullets  
   NZombies % the default initial number of zombies in the room

   /* Procedures */
   % Input arguments
   Say = System.showInfo
   Args = {Application.getArgs
	   record(
	      map(single char:&m type:atom default:Config.map)
	      zombie(single char:&s type:int default:Config.nZombies)
	      item(single char:&b type:int default:Config.nWantedObjects) 
	      bullet(single char:&n type:int default:Config.nBullets) 
	      help(single char:[&? &h] default:false)
	      )}

   % Load function for the map /** NOT YET USED **/
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

   % Find the door on a map
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

   % Counts the number of empty spaces on the map
   proc {CountEmpty Map ?N}
      Lines = {Width Map}
      Columns = {Width Map.Lines}
      fun {Count I J Acc}
	 if J < Columns then % still in the line
	    if Map.I.J == 0 then {Count I J+1 Acc+1}
	    else {Count I J+1 Acc}
	    end
	 else % end of line
	    if I < Lines then % next line
	       if Map.I.J == 0 then {Count I+1 1 Acc+1}
	       else {Count I+1 1 Acc}
	       end
	    else % end of column
	       if Map.I.J == 0 then Acc+1
	       else Acc
	       end
	    end
	 end
      end
   in
      N = {Count 1 1 0}
   end
 
   % Randomly place the zombies on the map
   proc {PlaceZombies Height Width} %% X Y F nzombies
      proc {Place N}
	 if (N > Config.nZombies) then skip %%
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
		     {GUI.drawCellBis zombie RandX RandY RandF}
		     Config.zombiesPorts.N={Zombie.zombieState N state(notyourturn RandX RandY RandF Ack 0)}
		     {Place N+1}
		  end
	       end
	    end
	 end
      end
   in
      {Place 1}
   end

in   
   /* Help message */
   if Args.help then
      {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
      {Say "Options:"}
      {Say "  -m, --map FILE\tFile containing the map (default "#Config.map#")"}
      {Say "  -z, --zombie INT\tNumber of zombies"}
      {Say "  -i, --item INT\tTotal number of items to pick"}
      {Say "  -n, --bullet INT\tInitial number of bullets"}
      {Say "  -h, -?, --help\tThis help"}
      {Application.exit 0}
   end

   /* This and that */
   % Seed random number generator
   {OS.srand 0}

   /* Get arguments */
   Map = Args.map
   MapHeight = {Width Map}
   MapWidth = {Width Map.1}
   % Arguments of the game
   X_init = 1%%
   Y_init = 7%%
   F_init = [1 0]%%
   NWantedObjects = Config.nWantedObjects %%
   NBullets = Config.nBullets %%
   NZombies = Config.nZombies %%

   /* Set up the GUI */
   {GUI.initLayout Config.map GUI.window Config.bravePort GUI.grid GUI.gridHandle} %% map
   GUI.window = {QTk.build GUI.desc}
   {GUI.window set(title:"ZOMBIELAND")}

   /* Initialize the PortObjects */
   % Grid of cells
   Config.mapPorts = {MakeTuple mapPorts MapHeight}
   for I in 1..MapHeight do
      Config.mapPorts.I = {MakeTuple r MapWidth}
      for J in 1..MapWidth do
	 Config.mapPorts.I.J = {Cell.cellState I J state(nobody Config.map.I.J)} %%
      end
   end
   
   % Zombies
   Config.zombiesPorts = {MakeTuple zombiesPorts NZombies}
   {PlaceZombies MapHeight MapWidth}

   % Controller
   Config.controllerPort = {Controller.controllerState state(brave NZombies Config.zombiesPorts 0)}

   % Brave
   local Ack in
      {Send Config.mapPorts.X_init.Y_init brave(enter F_init Config.nBullets)}  %%
   end
   {GUI.drawCell brave X_init Y_init}
   Config.bravePort = {Brave.braveState state(yourturn X_init Y_init F_init 5 Config.nAllowedMovesB Config.nBullets 0 0)}

   % Display the game
   {GUI.window show}
end
