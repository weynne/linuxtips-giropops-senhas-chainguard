# LINUXtips-Giropops-Senhas-Chainguard

### **DESAFIO PICK 2024.2**

Este desafio consiste em:

1. Instale o Trivy para verificar as vulnerabilidades(CVES) da sua imagem de container. 
2. Utilize o Docker Scout para verificar as vulnerabilidades(CVES) da sua imagem de container.
3. Utilize uma imagem Distroless para otimizar sua imagem de container.
4. Utilize o Hadolint para saber se o Dockerfile está utilizando as melhores práticas. 
5. Assine sua imagem utilizando o Cosing.
6. Envie a imagem para o Docker Hub.
7. Utilize novamente o Trivy e Docker Scout para verificar as vulnerabilidades(CVES) na sua imagem otimizada com Distroless.

## Resolução

1. Instalando o [Trivy](https://aquasecurity.github.io/trivy/v0.56/getting-started/installation/)
- Utilizando o Trivy para verificar as vulnerabilidades(CVES):
```
trivy image SUA_IMAGEM:1.0
```
2. Utilizando o Docker Scout para verificar as vulnerabilidades(CVES):
```
docker scout cves SUA_IMAGEM:1.0
```
- Consultando as recomendações do Docker Scout:
```
docker scout recommendations SUA_IMAGEM:1.0
```
##### OBS: É necessario logar utilizando o docker login para utilizar o docker scout.
3. Otimizando a imagem utilizando Distroless:
```
FROM cgr.dev/chainguard/python:latest-dev AS dev-builder
WORKDIR /app
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"
COPY ./giropops-senhas/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

FROM cgr.dev/chainguard/python:latest
WORKDIR /app
COPY --from=dev-builder /app/venv /app/venv
COPY ./giropops-senhas/app.py . 
COPY ./giropops-senhas/templates/ templates/
COPY ./giropops-senhas/static/ static/
EXPOSE 5000
ENV PATH="/app/venv/bin:$PATH"
ENTRYPOINT [ "flask" ]
CMD ["run", "--host=0.0.0.0"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD ["python", "-c", "import http.client; import sys; conn = http.client.HTTPConnection('localhost', 5000); conn.request('GET', '/'); res = conn.getresponse(); sys.exit(1) if res.status != 200 else sys.exit(0)"]
```
