CC = ozc
SRCS = Config.oz GUI.oz Cell2.oz Zombie.oz Brave.oz Controller.oz
OBJS = $(SRCS:.oz=.ozf)
MAIN = Game.oz
EXEC = Game

.PHONY: clean mrproper

all: $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	ozc -x $(MAIN)

Cell2.ozf: Cell2.oz
	ozc -c Cell2.oz -o Cell2.ozf

Config.ozf: Config.oz
	ozc -c Config.oz -o Config.ozf

GUI.ozf: GUI.oz Config.oz
	ozc -c GUI.oz -o GUI.ozf

Controller.ozf: Config.oz
	ozc -c Controller.oz -o Controller.ozf

Brave.ozf: Config.oz
	ozc -c Brave.oz -o Brave.ozf

Zombie.ozf: Config.oz
	ozc -c Zombie.oz -o Zombie.ozf

clean:
	@rm -rf *.ozf

mrproper: clean
	@rm -rf $(EXEC)
