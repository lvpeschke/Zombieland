CC = ozc
SRCS = Config.oz GUI.oz Cell.oz Zombie.oz
OBJS = $(SRCS:.oz=.ozf)
MAIN = Game.oz
EXEC = Game

.PHONY: clean mrproper

all: $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	ozc -x $(MAIN)

Cell.ozf: Cell.oz
	ozc -c Cell.oz -o Cell.ozf

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
