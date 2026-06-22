FROM teddysun/v2ray:latest

# Giriş nöqtəsini tamamilə təmizləyirik
ENTRYPOINT []

# Cloud Run-a konteyner daxilində hansı portu gözlədiyini qəti şəkildə bildiririk
ENV PORT=8080

# Konfiqurasiya faylını köçürürük
COPY config.json /etc/v2ray/config.json

# Heç bir skript olmadan, birbaşa orijinal v2ray əmrini çağırırıq
CMD ["v2ray", "run", "-config", "/etc/v2ray/config.json"]
