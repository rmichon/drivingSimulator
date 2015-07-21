// udp2osc.cpp
// CDR/VAIL/CCRMA - Stanford University
// 07/20/15

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <string>
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "osc/OscOutboundPacketStream.h"
#include "ip/UdpSocket.h"

#define RECEIVE_PORT 8089
#define SEND_ADDRESS "127.0.0.1"
#define SEND_PORT 5510
#define BUFFER_SIZE 2048

#define OSC_BASE_ADDRESS "/audioEngine/"

int main(int argc, char* argv[])
{
    (void) argc; // suppress unused parameter warnings
    (void) argv; // suppress unused parameter warnings

	struct sockaddr_in myaddr;	/* our address */
	struct sockaddr_in remaddr;	/* remote address */
	socklen_t addrlen = sizeof(remaddr);		/* length of addresses */
	int recvlen;			/* # bytes received */
	int fd;				/* our socket */
	unsigned char buf[BUFFER_SIZE];	/* receive buffer */

	/* create a UDP socket */

	if ((fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		perror("cannot create socket\n");
		return 0;
	}
	
    UdpTransmitSocket transmitSocket( IpEndpointName( SEND_ADDRESS, SEND_PORT ) );
	
	// The buffer out
    char buffer[BUFFER_SIZE];
    osc::OutboundPacketStream p( buffer, BUFFER_SIZE );
    
	/* bind the socket to any valid IP address and a specific port */

	memset((char *)&myaddr, 0, sizeof(myaddr));
	myaddr.sin_family = AF_INET;
	myaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	myaddr.sin_port = htons(RECEIVE_PORT);

	if (bind(fd, (struct sockaddr *)&myaddr, sizeof(myaddr)) < 0) {
		perror("bind failed");
		return 0;
	}
	else{ 
		printf("Listening to port %d\n", RECEIVE_PORT);
	}
	
	/* now loop, receiving data and printing what we received */
	for (;;) {
		recvlen = recvfrom(fd, buf, BUFFER_SIZE, 0, (struct sockaddr *)&remaddr, &addrlen);
		if (recvlen > 0) {
			buf[recvlen] = 0;
			
			// retrieving the data from the udp message
			std::string inMessage( buf, buf + sizeof buf / sizeof buf[0] ); // converting the input buffer to a string
			
			int inMessageLength = inMessage.find(";");
			int nParams = std::count(inMessage.begin(), inMessage.end(), '\n')-1;

			for(int i=0; i<nParams; i++){
				std::string oscAddress = OSC_BASE_ADDRESS;
				oscAddress.append(inMessage.substr(0,inMessage.find(":")));
				std::string oscValueString = inMessage.substr(inMessage.find(":")+1,inMessage.find("\n")-inMessage.find(":")-1);
				float oscValue = stof(oscValueString);
				printf("Rec: %s: ",oscAddress.c_str());
				printf("%f\n", oscValue);
				inMessage = inMessage.substr(inMessage.find("\n")+1,inMessage.find(";")-inMessage.find("\n"));
			
				// formating and sending the OSC message
		    	p.Clear();
		    	p << osc::BeginMessage(oscAddress.c_str())
		        	    << oscValue << osc::EndMessage;
		    	transmitSocket.Send( p.Data(), p.Size() );
			}
		}
	}
	/* never exits */
}




















