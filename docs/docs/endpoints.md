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
