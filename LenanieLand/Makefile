CC = ozc
#SRCS = Config.oz GUI.oz
SRCS = $(wildcard *.oz)
OBJS = $(SRCS:.oz=.ozf)
# MAIN = Game.oz
EXEC = Zombieland

all: $(EXEC)

Zombieland: $(OBJS) $(MAIN)
	@$(CC) -x $@ $^

Config.ozf: Config.oz
GUI.ozf: GUI.oz Config.oz
Game.ozf: Config.oz Game.oz GUI.oz

.PHONY: clean mrproper

clean:
	@rm -rf *.ozf

mrproper: clean
	@rm -rf $(EXEC)
