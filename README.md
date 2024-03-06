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

### init
- https://spring.io/guides/gs/accessing-data-rest
<img width="1341" alt="image" src="https://github.com/pySatellite/restdb/assets/87309910/9a45696b-399e-4551-aa0b-ec24fc9f82e5">
