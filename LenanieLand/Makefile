CC = ozc
SRCS = Brave.oz Cell.oz Config.oz Controller.oz GUI.oz Zombie.oz 
OBJS = $(SRCS:.oz=.ozf)
MAIN = Game.oz
EXEC = Game

.PHONY: clean mrproper

all: $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	ozc -x $(MAIN)

Brave2.ozf: Brave2.oz Config.oz GUI.oz
	ozc -c Brave2.oz -o Brave2.ozf

Cell.ozf: Cell.oz Config.oz GUI.oz
	ozc -c Cell.oz -o Cell.ozf

Config.ozf: Config.oz
	ozc -c Config.oz -o Config.ozf

Controller.ozf: Config.oz Controller.oz
	ozc -c Controller.oz -o Controller.ozf

GUI.ozf: GUI.oz Config.oz
	ozc -c GUI.oz -o GUI.ozf

Zombie.ozf: Zombie.oz Config.oz
	ozc -c Zombie.oz -o Zombie.ozf

clean:
	@rm -rf *.ozf

mrproper: clean
	@rm -rf $(EXEC)
