## IRIS Connections application

 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/iris-connections)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-connections&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-connections)
 
IRIS Connections is a developer tool to do impact analysis in your source code in your browser


## Installation with ZPM

zpm:USER>install iris-connections

## Installation with Docker

Clone/git pull the repo into any local directory:

```
$ git clone https://github.com/yurimarx/iris-connections.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d --build
```


## See app UI

Open the following to see your source-code dependencies:

```
localhost:52773/connections/index.html 
```

![IRIS Connections screen](https://github.com/yurimarx/iris-connections/raw/master/irisconnectionspitch.gif)


## See app API

If you want yo see your dependencies from a REST API, you can get swagger Open API 2.0 documentation on:
```
http://localhost:52773/iris-connections/_spec
```
