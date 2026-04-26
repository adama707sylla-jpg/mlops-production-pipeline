FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Le modèle est maintenant à la racine du projet
COPY ../model/ ./model/

RUN printf '#!/bin/bash\nexec uvicorn main:app --host 0.0.0.0 --port 8080\n' > /usr/local/bin/serve \
    && chmod +x /usr/local/bin/serve

EXPOSE 8080
CMD ["serve"]