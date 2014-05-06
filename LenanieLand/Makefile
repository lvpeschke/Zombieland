CC = ozc
SRCS = Config.oz GUI.oz
OBJS = $(SRCS:.oz=.ozf)
MAIN = Game.oz
EXEC = Game

.PHONY: clean mrproper

all: $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	ozc -x $(MAIN)

Config.ozf: Config.oz
	ozc -c Config.oz -o Config.ozf

GUI.ozf: GUI.oz Config.oz
	ozc -c GUI.oz -o GUI.ozf

Controller.ozf: Congif.oz
	ozc -c Controller.oz -o Controller.ozf

clean:
	@rm -rf *.ozf

mrproper: clean
	@rm -rf $(EXEC)
