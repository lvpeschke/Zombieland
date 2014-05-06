CC = ozc
SRCS = Config.oz GUI.oz Cell.oz
OBJS = $(SRCS:.oz=.ozf)
MAIN = Game.oz
EXEC = Game

.PHONY: clean mrproper

all: $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	ozc -x $(MAIN)

Cell.ozf: Config.oz GUI.oz
	ozc -c Cell.oz -o Cell.ozf

Config.ozf: Config.oz
	ozc -c Config.oz -o Config.ozf

GUI.ozf: GUI.oz Config.oz
	ozc -c GUI.oz -o GUI.ozf

clean:
	@rm -rf *.ozf

mrproper: clean
	@rm -rf $(EXEC)
