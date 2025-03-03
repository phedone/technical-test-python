from fastapi import APIRouter
from fastapi_restful.cbv import cbv

router = APIRouter()


@cbv(router)
class DocumentManagerView:
    """
    Ai Export Service
    """

    @router.get("/heartbeat", include_in_schema=False)
    def heartbeat(self):
        """
        Service headtbeat check url
        """
        return {"is_alive": True}

    @router.post("/scan-folders")
    def scan_folders(self): ...
