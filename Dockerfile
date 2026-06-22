FROM teddysun/v2ray:latest

# Giriş nöqtəsini (entrypoint) sıfırlayırıq ki, yazdığımız skript maneəsiz işləsin
ENTRYPOINT []

# Konfiqurasiya faylını köçürürük
COPY config.json /etc/v2ray/config.json

# Əvvəlcə portu əvəzləyirik, sonra v2ray-i işə salırıq
CMD ["sh", "-c", "sed -i \"s/8080/$PORT/g\" /etc/v2ray/config.json && v2ray run -config /etc/v2ray/config.json"]
