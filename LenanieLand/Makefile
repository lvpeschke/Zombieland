SRCS = Config.oz Room.oz
OBJS = $(SRCS:.oz=.ozf)
MAIN = Game.oz
EXECUTABLE = ZombieLand

.PHONY: clean

$(EXECUTABLE): $(OBJS) $(MAIN)
	ozc -x $(MAIN)

Config.ozf: Config.oz
	ozc -c Config.oz -o Config.ozf

Room.ozf: Room.oz Config.ozf
	ozc -c Room.oz -o Room.ozf

all: $(EXECUTABLE)

clean:
	rm -f $(OBJS) $(EXECUTABLE)
