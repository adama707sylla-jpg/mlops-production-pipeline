# api/tests/test_api.py
from fastapi.testclient import TestClient
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

# Mock du modele pour les tests pas besoin du vrai modèle .pkl
import unittest.mock as mock
with mock.patch("joblib.load") as mock_load:
    mock_model = mock.MagicMock()
    mock_model.predict.return_value = [1]  # Prédiction de classe 1 pour les tests
    mock_model.predict_proba.return_value = [[0.1, 0.9]]  # Probabilités pour les classes
    mock_load.return_value = mock_model

    from api.main import app


client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "healthy"

def test_ready():
    r = client.get("/ready")
    assert r.status_code == 200

def test_predict():
    r = client.post("/predict", json={"review": "great product"})
    assert r.status_code == 200
    assert r.json()["prediction"] in ["positive", "negative"]
    assert 0 <= r.json()["confidence"] <= 1

def test_predict_batch():
    r = client.post("/predict_batch", json={
        "reviews": ["great product", "terrible quality"]
    })
    assert r.status_code == 200
    assert len(r.json()["predictions"]) == 2
   