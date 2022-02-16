# Web Server
This is a web server that dumps the request data (HTTP method, path, headers, POST data)

## Setup
First build the image
```
docker build -t http_web_server:latest .
```

## Usage
### Via Dockerfile
To run a docker container on port 8080, run the command:
```
HTTP_PORT=8080 docker run -p $HTTP_PORT:$HTTP_PORT http_web_server:latest $HTTP_PORT
```

