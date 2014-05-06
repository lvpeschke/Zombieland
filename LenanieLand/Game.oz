functor
import
   Application
   OS
   Property

   % For file reading
   Open %at 'x-oz://system/Open.ozf'
   Pickle

   % Our functors
   Config
   GUI
   Brave
   Controller
   Zombies
   Cell2
   % Zombie

   System %%
define
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

   fun {RandFacing}
      local X in
	 X = {OS.rand} mod 4
	 if X==0 then [~1 0]
	 elseif X==1 then [0 1]
	 elseif X==2 then [1 0]
	 else [0 ~1] end
      end
   end
	    
   proc {PlaceZombies Height Width}
      proc {Place N}
	 {System.show ''#N}
	 if (N>Config.nZombies) then skip
	 else
	    local RandX RandY RandF Ack in
	       RandX = ({OS.rand} mod Height)+1
	       RandY = ({OS.rand} mod Width)+1
	       RandF = {RandFacing}
	       {System.show ''#RandX#' '#RandY#' '#RandF}
	       {Send Config.mapPorts.RandX.RandY zombie(enter Ack)}
	       {System.show ''#N#' message sent'}
	       {Wait Ack}
	       {System.show ''#N#' ack bound'}
	       if Ack==ok then
		  zombiesPorts.N={Zombies.zombieState state(notyourturn RandX RandY RandF 0)}
		  {Place N+1}
	       else {Place N}
	       end
	    end
	 end
      end
   in
      {Place 1}
   end

   %% CONFIG
   X_INIT = 1
   Y_INIT = 7
   F_INIT = [1 0]
   MAP1 = Config.map
   /*MAP2 = map(
	     r(9 1 1 1 1 1 1 5 1 1 1 1 1 1 1)
	     r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	     r(1 3 0 0 0 0 0 0 0 1 2 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 4 1 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 1 1 1 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	     r(1 1 1 0 0 1 1 1 1 1 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	     r(1 3 0 0 0 0 0 1 4 0 0 0 0 3 1)
	     r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 1 2 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	     r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
	     )*/
   Height = 13
   Width = 20
   %CurrentMap = Args.map

   Window = GUI.window
   {GUI.initLayout Config.map Window Config.bravePort}

   ZombiesPorts
in
   % Help message
   /*if Args.help then
      {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
      {Say "Options:"}
      {Say "  -m, --map FILE\tFile containing the map (default "#Config.map#")"}
      {Say "  -z, --zombie INT\tNumber of zombies"}
      {Say "  -i, --item INT\tTotal number of items to pick"}
      {Say "  -n, --bullet INT\tInitial number of bullets"}
      {Say "  -h, -?, --help\tThis help"}
      {Application.exit 0}
     end */
   
   
   % Display GUI
   {Window show}
   
   %{Delay 1000}
   %{DrawCell Wall 1 7} % test pour changer une cellule
   %{Grid configure(label(text:"5") column:2 row:2)}
   %{Grid configure(label(text:"0" bg:white)
   %column:1 columnspan:3 row:4 sticky:we)}

   % Start game
   {GUI.drawCell b X_INIT Y_INIT}

   % Les Ports
   % La MAP
   Config.mapPorts = {MakeTuple mapPorts Height}
   for I in 1..Height do
      Config.mapPorts.I = {MakeTuple r Width}
      for J in 1..Width do
	 {System.show ''#I#' '#J}
	 Config.mapPorts.I.J = {Cell.cellState I J state(nobody Config.map.I.J)}
      end
   end
   
   % Les zombies
   ZombiesPorts = {MakeTuple zombiesPorts Config.nZombies}
   {PlaceZombies Height Width}

   % Le controleur
   Config.controllerPort = {Controller.controllerState state(brave Config.nZombies Config.zombiesPorts 0)}

   % Le brave
   Config.bravePort = {Config.braveState state(yourturn X_INIT Y_INIT F_INIT Config.nAllowedMovesB Config.nBullets 0)}
end
