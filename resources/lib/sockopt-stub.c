/*  
    Source: therealkenc @ https://github.com/microsoft/WSL/issues/1953#issuecomment-452088338

    - added getsockopt() (to silence the symfony web server command running with php-fpm (https://symfony.com/doc/current/setup/symfony_server.html))

    sockopt-stub.c

    sudo apt-install build-essential
    gcc -fPIC -c -o sockopt-stub.o sockopt-stub.c
    gcc -shared -o sockopt-stub.so sockopt-stub.o -ldl
    export LD_PRELOAD="<DIRECTORY>/sockopt-stub.so"
    # ... run stuff    
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

typedef int (*getsockopt_)(int sockfd, int level, int optname, void *optval, socklen_t *optlen);
typedef int (*setsockopt_)(int sockfd, int level, int optname, const void *optval, socklen_t optlen);

int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen)
{
    getsockopt_ fn = (getsockopt_)(dlsym(RTLD_NEXT, "getsockopt"));

    if (level == IPPROTO_TCP && optname == TCP_INFO) {
        memset(optval, '\0', sizeof(struct tcp_info));
        return 0;
    }

    return fn(sockfd, level, optname, optval, optlen);
}

int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen)
{
    setsockopt_ fn = (setsockopt_)(dlsym(RTLD_NEXT, "setsockopt"));
    if (level == IPPROTO_TCP && optname == TCP_DEFER_ACCEPT) {
        return 0;
    }
    return fn(sockfd, level, optname, optval, optlen);
}
