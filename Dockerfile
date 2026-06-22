FROM alpine:latest

# Lazımi paketləri (Dropbear SSH, Python və sistem alətləri) yükləyirik
RUN apk add --no-cache dropbear python3 bash sudo

# Dropbear SSH üçün lazımi qovluğu yaradırıq
RUN mkdir -p /etc/dropbear

# SSH üçün istifadəçi məlumatlarını təyin edirik:
# İstifadəçi adı: proksima
# Şifrə: ssh_pass_2026
RUN adduser -D -s /bin/bash proksima && echo "proksima:ssh_pass_2026" | chpasswd
RUN echo "proksima ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Cloud Run port mühitini təyin edirik (Default: 8080)
ENV PORT=8080

# Kənardan gələn HTTP Payload-u qarşılayıb daxili SSH-ə körpü quran skript
RUN echo 'import socket, select, sys, threading\n\
def tunnel(client, port):\n\
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
    server.connect(("127.0.0.1", port))\n\
    while True:\n\
        r, w, x = select.select([client, server], [], [])\n\
        if client in r:\n\
            data = client.recv(4096)\n\
            if not data: break\n\
            server.send(data)\n\
        if server in r:\n\
            data = server.recv(4096)\n\
            if not data: break\n\
            client.send(data)\n\
def start():\n\
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
    s.bind(("0.0.0.0", int(sys.argv[1])))\n\
    s.listen(200)\n\
    while True:\n\
        try:\n\
            c, a = s.accept()\n\
            req = c.recv(1024).decode("utf-8", errors="ignore")\n\
            if "Upgrade: websocket" in req or "CONNECT" in req or "HTTP/" in req:\n\
                c.send(b"HTTP/1.1 101 Switching Protocols\\r\\nUpgrade: websocket\\r\\nConnection: Upgrade\\r\\n\\r\\n")\n\
                threading.Thread(target=tunnel, args=(c, 22)).start()\n\
            else: c.close()\n\
        except: pass\n\
if __name__ == "__main__": start()' > /usr/local/bin/wstunnel.py

# Dropbear SSH-i daxili 22 portunda, Python skriptini isə xarici Cloud Run portunda başladırıq
CMD dropbear -E -p 127.0.0.1:22 -W 65535 && python3 /usr/local/bin/wstunnel.py $PORT
