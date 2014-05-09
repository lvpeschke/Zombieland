CC = ozc
SRCS = Brave.oz Cell.oz Config.oz Controller.oz GUI.oz Zombie.oz 
OBJS = $(SRCS:.oz=.ozf)
MAIN = Game.oz
EXEC = Game.ozf

.PHONY: clean mrproper

# Compile
all: $(EXEC)

# Execute
play: $(EXEC)
	ozengine $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	$(CC) -c $(MAIN)

Brave.ozf: Brave.oz Config.oz GUI.oz
	$(CC) -c Brave.oz -o Brave.ozf

Cell.ozf: Cell.oz Config.oz
	$(CC) -c Cell.oz -o Cell.ozf

Config.ozf: Config.oz
	$(CC) -c Config.oz -o Config.ozf

Controller.ozf: Config.oz Controller.oz
	$(CC) -c Controller.oz -o Controller.ozf

GUI.ozf: GUI.oz Config.oz
	$(CC) -c GUI.oz -o GUI.ozf

Zombie.ozf: Zombie.oz Config.oz GUI.oz
	$(CC) -c Zombie.oz -o Zombie.ozf

# Remove files

clean:
	@rm -rf *.ozf

mrproper: clean
	@rm -rf $(EXEC)
