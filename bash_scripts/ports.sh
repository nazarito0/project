#!/bin/bash

IP=$(minikube ip)

if [ -z "$IP" ]; then
    echo "Помилка: Minikube не запущений!"
    exit 1
fi

sudo pkill socat 2>/dev/null

sudo nohup socat TCP-LISTEN:80,fork,reuseaddr TCP:$IP:80 > /dev/null 2>&1 &
sudo nohup socat TCP-LISTEN:443,fork,reuseaddr TCP:$IP:443 > /dev/null 2>&1 &

echo "Трафік перенаправлено на $IP"
