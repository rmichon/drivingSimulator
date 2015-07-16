ENDIANESS=OSC_DETECT_ENDIANESS #source code will detect using preprocessor

UNAME := $(shell uname)

CXX := g++
INCLUDES := -I.
COPTS  := -Wall -Wextra -O3
CDEBUG := -Wall -Wextra -g 
CXXFLAGS := $(COPTS) $(INCLUDES) -D$(ENDIANESS)

UDP2OSC := udp2osc

SENDSOURCES := osc/OscOutboundPacketStream.cpp
NETSOURCES := ip/posix/UdpSocket.cpp ip/IpEndpointName.cpp ip/posix/NetworkingUtils.cpp
COMMONSOURCES := osc/OscTypes.cpp

SENDOBJECTS := $(SENDSOURCES:.cpp=.o)
NETOBJECTS := $(NETSOURCES:.cpp=.o)
COMMONOBJECTS := $(COMMONSOURCES:.cpp=.o)

UDP2OSCSOURCES := udp2osc.cpp
UDP2OSCOBJECTS := $(UDP2OSCSOURCES:.cpp=.o)

LIBOBJECTS := $(COMMONOBJECTS) $(SENDOBJECTS) $(RECEIVEOBJECTS) $(NETOBJECTS)

all: $(UDP2OSC)

# Build rule and common dependencies for all programs
# | specifies an order-only dependency so changes to bin dir modified date don't trigger recompile
$(UDP2OSC) : $(COMMONOBJECTS)
	$(CXX) -o $@ $^

$(UDP2OSC) : $(UDP2OSCOBJECTS) $(SENDOBJECTS) $(NETOBJECTS)

clean:
	rm -rf $(LIBOBJECTS) $(UDP2OSC) $(UDP2OSCOBJECTS) $(LIBFILENAME) include lib oscpack &> /dev/null

$(LIBFILENAME): $(LIBOBJECTS)
ifeq ($(UNAME), Darwin)
	#Mac OS X case
	$(CXX) -dynamiclib -Wl,-install_name,$(LIBSONAME) -o $(LIBFILENAME) $(LIBOBJECTS) -lc
else
	#GNU/Linux case
	$(CXX) -shared -Wl,-soname,$(LIBSONAME) -o $(LIBFILENAME) $(LIBOBJECTS) -lc
endif

lib: $(LIBFILENAME)

