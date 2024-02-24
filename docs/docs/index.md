# Home 

## Install

To install the project, follow these steps:

0. Check which python version do you have installed in your system. I'll use *3.12* in this document.

1. Clone the repository to your local machine.

2. Run the `localenv.sh` script located in the `scripts/devel` directory. This script sets up the local environment for the project.

   ```bash
   chmod +x ./scripts/devel/localenv.sh
   ./scripts/devel/localenv.sh install 3.12
   ```

3. In order to create docker containers, we need some environment variables to be set. Copy *local.env.example* and set appropiate settings according to your project:

   ```bash
   cp local.env.example .local.env
   ```

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

## Endpoints
### Add a new API endpoint

0. Place a new file with api endpoints inside `app/api/routes/`. Each new file must provide an `APIRouter` . See `app/api/routes/hello.py` and use it as an example for new modules:

```py
from fastapi import APIRouter

newmodule_router = APIRouter()
@newmodule_router.get(...)
async def new(...):
    ...
```

1. Register `APIRouter` from previous file on `app/api/routes/urls.py` 

URL to access defined APIs are like: `http://host:port/<API_PREFIX>/<PREFIX_VERSION>` where:

- `API_PREFIX` is defined on `settings.py` . Remember you can change this value on *.env* file.
- `PREFIX_VERSION` is defined on `app/api/urls.py` when using `include_router` (use`hello_router`as an example)

## Services

Services must be placed inside `app/services/` directory. The project already provides the following services:

### HTTP

Its an HTTP client. Usefull when you have to call external API's or other services. By default, it'll retry up to 5 times if the request fails.

```python
from services import http

async def test():
    result = await http.get(url="https://google.com")
```

### Logger

A logger ready to be used.

```python
from services import logger

async def test():
    logger.debug("cool!")
```

### Settings

Access your project settings from any part of your code. Remember that settings are defined on `settings.py` -> `Settings` class.  Any class attribute defined in `Settings` class can be overrided on *.env* file  

```python
from services import settings

async def test():
    return settings.HOST + ":" + settings.PORT
```

