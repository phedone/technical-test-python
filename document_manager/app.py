import os

import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI

from document_manager.core.cors import CorsHelper
from document_manager.views.views import router

load_dotenv()


def build_app(router):
    app = FastAPI(
        title="Diabolocom AI Technical Test",
        version="1.0.0",
    )
    CorsHelper(app)

    app.include_router(router)
    return app


def main():
    load_dotenv()

    app = build_app(router)
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("SERVICE_PORT", "8000")))


if __name__ == "__main__":
    main()
