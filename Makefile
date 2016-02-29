MODULE_big = argm
OBJS = argm.o

EXTENSION = argm
DATA = argm--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
