CFLAGS += -Wstrict-prototypes

.PHONY: all clean

all: zns-bench

zns-bench: src/zns-bench.cc
	$(CXX) $^ -o$@ /usr/local/lib/librocksdb.a -lpthread -ldl -I../rocksdb/include -O2 -std=c++11

clean:
	$(RM) zns-bench
