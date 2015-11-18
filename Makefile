MODULE_big = argmax
OBJS = argmax.o

EXTENSION = argmax
DATA = argmax--1.0.sql

#SHLIB_LINK = $(filter -lcrypt, $(LIBS))

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
