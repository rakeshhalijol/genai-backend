from fastapi.responses import StreamingResponse

from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, File, UploadFile
import pandas as pd
import time
import io
from model import (
    gen_AI_model
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def process_xlsx(file_content):
    df = pd.read_excel(file_content)
    return df


@app.post("/upload/")
async def upload_xlsx(file: UploadFile = File(...)):
    t = time.time()
    try:
        content = await file.read()
        data = process_xlsx(content)
        result = gen_AI_model(data)
        # Create a file-like object with the XSLT content
        xslt_file = io.BytesIO(result.encode("utf-8"))

        # Return the file as a downloadable response
        response = StreamingResponse(
            xslt_file, media_type="text/xml", headers={"Content-Disposition": "attachment; filename=xslt_output.xsl"}
        )
        return response
    except Exception as e:
        return {"error": str(e)}
    finally:
        print(time.time() - t)
