# Ansible Workshop Exercises

> WIP!

Das Docker Image mit der aktuellsten Version der Dokumentation gebaut werden:
```bash
docker build -t ansible-workshop-exercises .
```

Container aus aktuellem Image starten, der Webserver wird hier auf Port 8080 verfügbar gemacht:
```bash
docker run -d -p 8080:8000/tcp --name workshop ansible-workshop-exercises
```
