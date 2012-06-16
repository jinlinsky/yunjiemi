#ifndef _SOCKET_H_
#define _SOCKET_H_

class Socket
{
public:

	Socket()
	{
	}

	int     Connect    ( const char* ip, int port, bool nonblock );
	void	Disconnect ( void );
	void    Recv       ( char* buffer, int bufferSize );
	void	Send       ( const char* buffer, int bufferSize );
	bool	IsConnected( void );

	static  Socket gSharedSocket;

private:
};

#endif //_SOCKET_H_