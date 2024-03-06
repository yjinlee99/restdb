# Springboot REST -> DB

## run
```
./gradlew bootRun
```
## API
<details>
     <summary>API DETAIL</summary>

### select API
```
$ curl -I http://localhost:8080/people
HTTP/1.1 204
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Link: <http://localhost:8080/people>;rel="self",<http://localhost:8080/profile/people>;rel="profile",<http://localhost:8080/people/search>;rel="search"
Date: Wed, 06 Mar 2024 02:47:14 GMT

$ curl http://localhost:8080/people
{
  "_embedded" : {
    "people" : [ ]
  },
  "_links" : {
    "self" : {
      "href" : "http://localhost:8080/people?page=0&size=20"
    },
    "profile" : {
      "href" : "http://localhost:8080/profile/people"
    },
    "search" : {
      "href" : "http://localhost:8080/people/search"
    }
  },
  "page" : {
    "size" : 20,
    "totalElements" : 0,
    "totalPages" : 0,
    "number" : 0
  }
}%

$ curl http://localhost:8080/people/1
{
  "firstName" : "Frodo",
  "lastName" : "Baggins",
  "_links" : {
    "self" : {
      "href" : "http://localhost:8080/people/1"
    },
    "person" : {
      "href" : "http://localhost:8080/people/1"
    }
  }
}%
```

### insert API
```
$ curl -i -H "Content-Type:application/json" -d '{"firstName": "Frodo", "lastName": "Baggins"}' http://localhost:8080/people
HTTP/1.1 201
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Location: http://localhost:8080/people/1
Content-Type: application/hal+json
Transfer-Encoding: chunked
Date: Wed, 06 Mar 2024 02:50:04 GMT

{
  "firstName" : "Frodo",
  "lastName" : "Baggins",
  "_links" : {
    "self" : {
      "href" : "http://localhost:8080/people/1"
    },
    "person" : {
      "href" : "http://localhost:8080/people/1"
    }
  }
}%
```

</details>

## dockerize
- https://spring.io/guides/topicals/spring-boot-docker
- only when it's m2 [issues](https://github.com/pySatellite/restdb/issues/3) : --platform linux/amd64 
```
$ ./gradlew clean bootJar
$ docker build --platform linux/amd64 --build-arg JAR_FILE=build/libs/restdb-0.2.0-SNAPSHOT.jar -f docker/Dockerfile -t restdb:0.2.0 .
$ docker run --platform linux/amd64 -d --name restdb020 -p 8020:8080 restdb:0.2.0
```

## docker compose
```
$ docker compose -f docker-compose.yml up -d --force-recreate --build

```

## init
- https://spring.io/guides/gs/accessing-data-rest
<img width="1341" alt="image" src="https://github.com/pySatellite/restdb/assets/87309910/9a45696b-399e-4551-aa0b-ec24fc9f82e5">
