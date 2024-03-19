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

## proxy
```
$ curl -Iv  http://localhost:8888/people/1
*   Trying 127.0.0.1:8888...
* Connected to localhost (127.0.0.1) port 8888 (#0)
> HEAD /people/1 HTTP/1.1
> Host: localhost:8888
> User-Agent: curl/7.84.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200
HTTP/1.1 200
< Server: nginx/1.25.4
Server: nginx/1.25.4
< Date: Wed, 06 Mar 2024 11:25:59 GMT
Date: Wed, 06 Mar 2024 11:25:59 GMT
< Content-Type: application/hal+json
Content-Type: application/hal+json
< Connection: keep-alive
Connection: keep-alive
< Vary: Origin
Vary: Origin
< Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Method
< Vary: Access-Control-Request-Headers
Vary: Access-Control-Request-Headers

<
* Connection #0 to host localhost left intact


$ curl http://localhost:8888/people/1 | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   204    0   204    0     0   3702      0 --:--:-- --:--:-- --:--:--  4000
{
  "firstName": "Gil Dong",
  "lastName": "Hong",
  "_links": {
    "self": {
      "href": "http://rest:8080/people/1"
    },
    "person": {
      "href": "http://rest:8080/people/1"
    }
  }
}
$ curl http://localhost:8888/people/1 | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   204    0   204    0     0   3634      0 --:--:-- --:--:-- --:--:--  4250
{
  "firstName": "Gil Dong",
  "lastName": "Hong",
  "_links": {
    "self": {
      "href": "http://rest:8080/people/1"
    },
    "person": {
      "href": "http://rest:8080/people/1"
    }
  }
}
```

## cache
```
$ docker exec restdb-proxy-1 tail -n 6 /var/log/nginx/api-proxy.access.log
172.27.0.1 - - [06/Mar/2024:12:32:11 +0000] "HEAD /people/1 HTTP/1.1" 200 0 "-" "curl/7.84.0" cs=EXPIRED
172.27.0.1 - - [06/Mar/2024:12:32:12 +0000] "HEAD /people/1 HTTP/1.1" 200 0 "-" "curl/7.84.0" cs=HIT
172.27.0.1 - - [06/Mar/2024:12:32:12 +0000] "HEAD /people/1 HTTP/1.1" 200 0 "-" "curl/7.84.0" cs=HIT
172.27.0.1 - - [06/Mar/2024:12:32:13 +0000] "HEAD /people/1 HTTP/1.1" 200 0 "-" "curl/7.84.0" cs=HIT
172.27.0.1 - - [06/Mar/2024:12:32:14 +0000] "HEAD /people/1 HTTP/1.1" 200 0 "-" "curl/7.84.0" cs=HIT
172.27.0.1 - - [06/Mar/2024:12:32:15 +0000] "HEAD /people/1 HTTP/1.1" 200 0 "-" "curl/7.84.0" cs=HIT


$ docker exec restdb-proxy-1 cat /etc/nginx/conf.d/proxy.conf
proxy_cache_path /etc/nginx/cache levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=1m use_temp_path=off;

log_format cache '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" cs=$upstream_cache_status';
server {
    listen 80;

    ## Access and error logs.
    access_log /var/log/nginx/api-proxy.access.log cache;
    error_log  /var/log/nginx/api-cache.error.log;

    location / {
        proxy_pass http://rest:8080;

        # proxy_ignore_headers X-Accel-Expires Expires Cache-Control;
        proxy_cache_valid 200 302 5s;
        proxy_cache_valid 404 1m;

        proxy_cache my_cache;
        # proxy_cache_valid 24h;
        # proxy_cache_methods GET POST;
    }
}%
```

## init
- https://spring.io/guides/gs/accessing-data-rest
<img width="1341" alt="image" src="https://github.com/pySatellite/restdb/assets/87309910/9a45696b-399e-4551-aa0b-ec24fc9f82e5">

## ref
- [AWS Regions](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)
- [official  GitHub Actions – CI/CD pipeline to deploy a Web App to Amazon EC2](https://aws.amazon.com/ko/blogs/devops/integrating-with-github-actions-ci-cd-pipeline-to-deploy-a-web-app-to-amazon-ec2/)
- [configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [AppSpec 파일 구조](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/reference-appspec-file-structure.html)
- [AppSpec 권한 섹션](https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/reference-appspec-file-structure-permissions.html)
- [CodeDeploy agent was not able to receive the lifecycle event. Check the CodeDeploy agent logs on your host and make sure the agent is running and can connect to the CodeDeploy server](https://stackoverflow.com/questions/73861102/before-install-codedeploy-agent-was-not-able-to-receive-the-lifecycle-event-ch)
- [InstanceAgent::Plugins::CodeDeployPlugin::CommandPoller: Missing credentials - please check if this instance was started with an IAM instance profile](https://ssue-dev.tistory.com/entry/AWS-CodeDeploy-%EB%B0%B0%ED%8F%AC%EC%8B%9C-%EB%82%98%EB%8A%94-%EC%97%90%EB%9F%AC-%ED%95%B4%EA%B2%B0%EB%B2%95)