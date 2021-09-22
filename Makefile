CFLAGS += -Wstrict-prototypes

.PHONY: all clean

all: zns-bench

zns-bench: librocksdb src/zns-bench.cc
	$(CXX) $@.cc -o$@ # TODO: put static lib dir: ../librocksdb.a -I../include -O2 -std=c++11
