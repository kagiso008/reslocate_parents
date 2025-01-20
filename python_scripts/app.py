from fastapi import FastAPI, Request
import requests

app = FastAPI()

API_TOKEN = "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"
MODEL = "mistralai/Mistral"

@app.post("/predict")
async def predict(request: Request):
    input_data = await request.json()
    prompt = input_data.get("prompt", "")

    response = requests.post(
        f"https://api-inference.huggingface.co/models/{MODEL}",
        headers={"Authorization": f"Bearer {API_TOKEN}"},
        json={"inputs": prompt},
    )

    return response.json()