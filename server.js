const net = require('net');
const http = require('http');

// Cloud Run-ın rəsmi portunu oxuyuruq
const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
    // HTTP Injector payload-u qəbul edildikdə WebSocket keçidi verilir
    if (req.headers.upgrade && req.headers.upgrade.toLowerCase() === 'websocket') {
        res.writeHead(101, {
            'Upgrade': 'websocket',
            'Connection': 'Upgrade'
        });
        res.end();
    } else {
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end('SSH Proxy Tunnel Active\n');
    }
});

// Kənardan gələn HTTP/WS bağlantısını daxili Dropbear SSH (Port 22)-ə yönləndiririk
server.on('upgrade', (req, socket, head) => {
    const sshSocket = net.connect(22, '127.0.0.1', () => {
        sshSocket.write(head);
        socket.pipe(sshSocket).pipe(sshSocket);
    });

    sshSocket.on('error', () => socket.destroy());
    socket.on('error', () => sshSocket.destroy());
});

server.listen(port, '0.0.0.0', () => {
    console.log(`Server listening on port ${port}`);
});
