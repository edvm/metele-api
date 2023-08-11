from api.urls import router as api_router
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from services import settings


def get_application() -> FastAPI:
    """Return FastAPI application."""

    application = FastAPI(
        title=settings.PROJECT_NAME,
        debug=settings.DEBUG,
        version=settings.VERSION,
    )
    application.include_router(api_router, prefix=settings.API_PREFIX)

    return application


app = get_application()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
