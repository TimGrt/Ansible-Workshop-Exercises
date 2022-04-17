# Ansible Workshop Exercises

> WIP!

Das Docker Image mit der aktuellsten Version der Dokumentation bauen:
```bash
docker build -t ansible-workshop-exercises .
```

Container aus aktuellem Image starten, der Webserver wird hier auf Port 8080 verfügbar gemacht:
```bash
docker run -d -p 8080:8000/tcp --name workshop ansible-workshop-exercises
```

## Development

Create a Python virtual environment:

```bash
pip3 -m venv mkdocs-venv
```

Activate VE:

```bash
source mkdocs-venv/bin/activcate
```

Install requirements from project directory:

```bash
pip3 install -r requirements.txt
```

Get IP address:

```bash
hostname -I
```
Start MkDocs built-in dev-server for live-preview:

```bash
mkdocs serve -a 172.26.220.226:8080
```
