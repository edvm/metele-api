## Settings
### Configure project settings

0. Any environment variable set on *.env* will be available on the running container
1. Any value set on *.env* file will override values set on `app/settings/Settings` class.

### Running the project

0. Use the *localenv.sh* script to start the docker container

```bash
‹main*› » ./scripts/devel/localenv.sh up
[+] Building 13.5s (11/11)                                                                 ...
[+] Running 1/1
 ✔ Container fastapi  Recreated                                                                                                                           0.1s 
Attaching to fastapi
fastapi  | DEBUG:asyncio:Using selector: EpollSelector
fastapi  | [2024-02-16 17:50:08 +0000] [8] [INFO] Running on http://0.0.0.0:7000 (CTRL + C to quit)
fastapi  | INFO:hypercorn.error:Running on http://0.0.0.0:7000 (CTRL + C to quit)
```

1. Open your web browser and visit: http://localhost:7000/api/v1/hello/

You should see the following response `{"message":"Hello World"}`

### Running the project in DEBUG mode

0. This will run FastAPI on your local system (outside Docker container). It activates the *virtualenv* and start *hypercorn* in debug mode. Keep in mind that *.local.env* values (HOST and PORT) are used:

```bash
‹main*› » ./scripts/devel/localenv.sh debug
NETWORK_NAME is not set. Using the default network: bridge
DEBUG:asyncio:Using selector: EpollSelector
[2024-02-16 17:53:18 +0000] [1556034] [INFO] Running on http://127.0.0.1:7000 (CTRL + C to quit)
INFO:hypercorn.error:Running on http://127.0.0.1:7000 (CTRL + C to quit)
```
