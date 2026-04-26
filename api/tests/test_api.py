# api/tests/test_api.py
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import unittest.mock as mock
with mock.patch("joblib.load") as mock_load:
    mock_model = mock.MagicMock()
    mock_model.predict.return_value       = [1]
    mock_model.predict_proba.return_value = [[0.1, 0.9]]
    mock_load.return_value = mock_model
    from main import app  # ← pas api.main, juste main

from fastapi.testclient import TestClient
client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200

def test_ready():
    r = client.get("/ready")
    assert r.status_code == 200

def test_predict():
    r = client.post("/predict", json={"review": "great product"})
    assert r.status_code == 200
    assert r.json()["prediction"] in ["positive", "negative"]

def test_predict_batch():
    r = client.post("/predict_batch", json={
        "reviews": ["great product", "terrible quality"]
    })
    assert r.status_code == 200
    # Vérifier que la réponse a une clé "predictions"
    data = r.json()
    assert "predictions" in data
    assert len(data["predictions"]) == 2
    # Vérifier chaque prédiction
    for pred in data["predictions"]:
        assert "prediction" in pred
        assert "confidence" in pred