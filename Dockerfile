FROM teddysun/v2ray:latest

# Konfiqurasiya faylını konteynerin içinə köçürürük
COPY config.json /etc/v2ray/config.json

# Cloud Run-ın təyin etdiyi dinamik portu config faylına yazmaq üçün qabıq (shell) əmri istifadə edirik
CMD sh -c 'sed -i "s/8080/$PORT/g" /etc/v2ray/config.json && /usr/bin/v2ray run -config /etc/v2ray/config.json'
