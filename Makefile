# Copyright (c) 2009-2010 Satoshi Nakamoto
# Distributed under the MIT/X11 software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

# :=0 --> UPnP support turned off by default at runtime
# :=1 --> UPnP support turned on by default at runtime
# :=- --> No UPnP support - miniupnp not required
USE_UPNP:=-

# :=1 --> Enable IPv6 support
# :=0 --> Disable IPv6 support
USE_IPV6:=1

LINK:=$(CXX)

DEFS=-DBOOST_SPIRIT_THREADSAFE -D_FILE_OFFSET_BITS=64

DEFS += $(addprefix -I,$(CURDIR) $(CURDIR)/obj $(BOOST_INCLUDE_PATH) $(BDB_INCLUDE_PATH) $(OPENSSL_INCLUDE_PATH))
DEFS += $(addprefix -I,$(CURDIR) $(CURDIR)/obj $(BOOST_INCLUDE_PATH) $(BDB_INCLUDE_PATH) $(OPENSSL_INCLUDE_PATH))
LIBS = $(addprefix -L,$(BOOST_LIB_PATH) $(BDB_LIB_PATH) $(OPENSSL_LIB_PATH)) -l pthread -l boost_system -l boost_program_options -l boost_thread -l boost_filesystem

TESTDEFS = -DTEST_DATA_DIR=$(abspath test/data)

LMODE = dynamic
LMODE2 = dynamic
ifdef STATIC
    LMODE = static
    ifeq (${STATIC}, all)
        LMODE2 = static
    endif
else
    TESTDEFS += -DBOOST_TEST_DYN_LINK
endif

# for boost 1.37, add -mt to the boost libraries
LIBS += \
 -Wl,-B$(LMODE) \
   -l db_cxx$(BDB_LIB_SUFFIX) \
   -l ssl \
   -l crypto

TESTLIBS += \
 -Wl,-B$(LMODE) \
   -l boost_unit_test_framework$(BOOST_LIB_SUFFIX)

TESTLIBS += \
 -Wl,-B$(LMODE) \
   -l boost_unit_test_framework$(BOOST_LIB_SUFFIX)

ifndef USE_UPNP
	override USE_UPNP = -
endif
ifneq (${USE_UPNP}, -)
	LIBS += /usr/lib/libminiupnpc.a
	DEFS += -DUSE_UPNP=$(USE_UPNP)
endif

ifneq (${USE_IPV6}, -)
	DEFS += -DUSE_IPV6=$(USE_IPV6)
endif

LIBS+= \
 -Wl,-B$(LMODE2) \
   -l z \
   -l dl \
   -l pthread


# Hardening
# Make some classes of vulnerabilities unexploitable in case one is discovered.
#
    # This is a workaround for Ubuntu bug #691722, the default -fstack-protector causes
    # -fstack-protector-all to be ignored unless -fno-stack-protector is used first.
    # see: https://bugs.launchpad.net/ubuntu/+source/gcc-4.5/+bug/691722
    HARDENING=-fno-stack-protector

    # Stack Canaries
    # Put numbers at the beginning of each stack frame and check that they are the same.
    # If a stack buffer if overflowed, it writes over the canary number and then on return
    # when that number is checked, it won't be the same and the program will exit with
    # a "Stack smashing detected" error instead of being exploited.
    HARDENING+=-fstack-protector-all -Wstack-protector

    # Make some important things such as the global offset table read only as soon as
    # the dynamic linker is finished building it. This will prevent overwriting of addresses
    # which would later be jumped to.
    LDHARDENING+=-Wl,-z,relro -Wl,-z,now

    # Build position independent code to take advantage of Address Space Layout Randomization
    # offered by some kernels.
    # see doc/build-unix.txt for more information.
    ifdef PIE
        HARDENING+=-fPIE
        LDHARDENING+=-pie
    endif

    # -D_FORTIFY_SOURCE=2 does some checking for potentially exploitable code patterns in
    # the source such overflowing a statically defined buffer.
    HARDENING+=-D_FORTIFY_SOURCE=2
#


DEBUGFLAGS=-g

# CXXFLAGS can be specified on the make command line, so we use xCXXFLAGS that only
# adds some defaults in front. Unfortunately, CXXFLAGS=... $(CXXFLAGS) does not work.
xCXXFLAGS=-O2 -std=c++11 -pthread -Wall -Wextra -Wformat -Wformat-security -Wno-unused-parameter -Wno-unused-variable -Wno-deprecated-declarations -Wno-literal-suffix -Wno-unused-function -Wno-extra
#xCXXFLAGS=-O2 -pthread -Wall -Wextra -Wformat -Wformat-security -Wno-unused-parameter -Wno-unused-variable \
    $(DEBUGFLAGS) $(DEFS) $(HARDENING) $(CXXFLAGS)

# LDFLAGS can be specified on the make command line, so we use xLDFLAGS that only
# adds some defaults in front. Unfortunately, LDFLAGS=... $(LDFLAGS) does not work.
xLDFLAGS=$(LDHARDENING) $(LDFLAGS)

OBJS= \
    cryptopp/libcryptopp.a \
    leveldb/libleveldb.a \
    obj/version.o \
    obj/checkpoints.o \
    obj/netbase.o \
    obj/addrman.o \
    obj/crypter.o \
    obj/key.o \
    obj/db.o \
    obj/init.o \
    obj/keystore.o \
    obj/main.o \
    obj/net.o \
    obj/protocol.o \
    obj/bitcoinrpc.o \
    obj/rpcdump.o \
    obj/rpcnet.o \
    obj/rpcmining.o \
    obj/rpcwallet.o \
    obj/rpcblockchain.o \
    obj/rpcrawtransaction.o \
    obj/script.o \
    obj/sync.o \
    obj/util.o \
    obj/wallet.o \
    obj/walletdb.o \
    obj/hash.o \
    obj/bloom.o \
    obj/noui.o \
    obj/leveldb.o \
    obj/txdb.o \
    obj/keccak.o

all: obj maxcoind

test check: test_maxcoin FORCE
	./test_maxcoin

#
# LevelDB support
#
MAKEOVERRIDES =
LIBS += $(CURDIR)/leveldb/libleveldb.a $(CURDIR)/leveldb/libmemenv.a $(CURDIR)/cryptopp/libcryptopp.a

DEFS += $(addprefix -I,$(CURDIR)/leveldb/include)
DEFS += $(addprefix -I,$(CURDIR)/leveldb/helpers)
leveldb/libleveldb.a:
	@echo "Building LevelDB ..." && cd leveldb && $(MAKE) CC=$(CC) CXX=$(CXX) OPT="$(xCXXFLAGS)" libleveldb.a libmemenv.a && cd ..

# auto-generated dependencies:
-include obj/*.P
-include obj-test/*.P

obj/build.h: FORCE
	/bin/sh ./genbuild.sh obj/build.h
version.cpp: obj/build.h
DEFS += -DHAVE_BUILD_INFO

obj/%.o: %.cpp
	$(CXX) -c $(xCXXFLAGS) -MMD -MF $(@:%.o=%.d) -o $@ $<
	@cp $(@:%.o=%.d) $(@:%.o=%.P); \
	  sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	      -e '/^$$/ d' -e 's/$$/ :/' < $(@:%.o=%.d) >> $(@:%.o=%.P); \
	  rm -f $(@:%.o=%.d)

obj/%.o: %.c
	$(CXX) -c $(xCXXFLAGS) -fpermissive -MMD -MF $(@:%.o=%.d) -o $@ $<
	@cp $(@:%.o=%.d) $(@:%.o=%.P); \
	  sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	      -e '/^$$/ d' -e 's/$$/ :/' < $(@:%.o=%.d) >> $(@:%.o=%.P); \
	  rm -f $(@:%.o=%.d)

obj:
	-mkdir -p obj

cryptopp/libcryptopp.a:
	@$(MAKE) -C cryptopp static

maxcoind: $(OBJS:obj/%=obj/%)
	$(LINK) $(xCXXFLAGS) -o $@ $^ $(xLDFLAGS) $(LIBS)

TESTOBJS := $(patsubst test/%.cpp,obj-test/%.o,$(wildcard test/*.cpp))

obj-test/%.o: test/%.cpp
	$(CXX) -c $(TESTDEFS) $(xCXXFLAGS) -MMD -MF $(@:%.o=%.d) -o $@ $<
	@cp $(@:%.o=%.d) $(@:%.o=%.P); \
	  sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	      -e '/^$$/ d' -e 's/$$/ :/' < $(@:%.o=%.d) >> $(@:%.o=%.P); \
	  rm -f $(@:%.o=%.d)

test_maxcoin: $(TESTOBJS) $(filter-out obj/init.o,$(OBJS:obj/%=obj/%))
	$(LINK) $(xCXXFLAGS) -o $@ $(LIBPATHS) $^ $(TESTLIBS) $(xLDFLAGS) $(LIBS)

clean:
	-rm -f maxcoind test_maxcoin
	-rm -f obj/*.o
	-rm -f obj-test/*.o
	-rm -f obj/*.P
	-rm -f obj-test/*.P
	-rm -f obj/build.h
	-cd leveldb && $(MAKE) clean || true
	-cd cryptopp && $(MAKE) clean || true

FORCE:
