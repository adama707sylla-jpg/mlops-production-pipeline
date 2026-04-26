# api/main.py
import joblib, os
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

app = FastAPI(title="SmartReview MLOps Expert", version="2.0")

# Charge le modèle au démarrage — pas à chaque requête
MODEL_PATH = os.environ.get("MODEL_PATH", "model/model.pkl")
model = joblib.load(MODEL_PATH)

class PredictRequest(BaseModel):
    review: str

class PredictBatchRequest(BaseModel):
    reviews: List[str]

class PredictResponse(BaseModel):
    prediction: str
    confidence: float

# Health check — utilisé par Kubernetes readiness probe
@app.get("/health")
def health():
    return {"status": "healthy", "model_loaded": model is not None}

# Readiness probe — vérifie que le modèle est prêt
@app.get("/ready")
def ready():
    if model is None:
        return {"status": "not ready"}, 503
    return {"status": "ready"}

@app.post("/predict", response_model=PredictResponse)
def predict(req: PredictRequest):
    proba = model.predict_proba([req.review])[0]
    pred  = model.predict([req.review])[0]
    return {
        "prediction": "positive" if pred == 1 else "negative",
        "confidence": round(float(max(proba)), 4)
    }

@app.post("/predict_batch")
def predict_batch(req: PredictBatchRequest):
    predictions = model.predict(req.reviews)
    probas      = model.predict_proba(req.reviews)
    return {
        "predictions": [
            {
                "review": review,
                "prediction": "positive" if pred == 1 else "negative",
                "confidence": round(float(max(proba)), 4)
            }
            for review, pred, proba in zip(req.reviews, predictions, probas)
        ]
    }
from fastapi import FastAPI, Request
from fastapi.responses import Response

# Ping — SageMaker vérifie que le conteneur est vivant
@app.get("/ping")
def ping():
    return Response(content="", status_code=200)



# Invocations — SageMaker envoie les requêtes de prédiction ici
@app.post("/invocations")
async def invocations(request: Request):
    body = await request.json()
    review = body.get("review", "")
    proba = model.predict_proba([review])[0]
    pred  = model.predict([review])[0]
    return {
        "prediction": "positive" if pred == 1 else "negative",
        "confidence": round(float(max(proba)), 4)
    }