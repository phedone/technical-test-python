from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware


class CorsHelper:
    def __init__(self, app: FastAPI, allowed_origins=None):
        if allowed_origins is None:
            allowed_origins = ["*"]

        self.app = app

        self._setup_cors(
            allowed_origins=allowed_origins,
        )

    def _setup_cors(self, allowed_origins: list[str]) -> None:
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=allowed_origins,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
            expose_headers=["*"],
        )
