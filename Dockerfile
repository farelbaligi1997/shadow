FROM alpine:latest

# Node.js, Dropbear SSH və lazım olan paketləri yükləyirik
RUN apk add --no-cache dropbear nodejs bash sudo

# Dropbear SSH konfiqurasiya qovluğu
RUN mkdir -p /etc/dropbear

# SSH Giriş məlumatları:
# İstifadəçi: proksima
# Şifrə: ssh_pass_2026
RUN adduser -D -s /bin/bash proksima && echo "proksima:ssh_pass_2026" | chpasswd
RUN echo "proksima ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Skripti konteynerin içinə köçürürük
WORKDIR /app
COPY server.js .

# Port mühitini təyin edirik
ENV PORT=8080

# SSH-i daxildə başladırıq və Node.js serverini aktiv edirik
CMD dropbear -E -p 127.0.0.1:22 -W 65535 && node server.js
