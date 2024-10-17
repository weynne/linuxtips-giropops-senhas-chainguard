# LINUXtips-Giropops-Senhas-Chainguard

### **DESAFIO PICK 2024.2**

Este desafio consiste em:

1. Instale o Trivy para verificar as vulnerabilidades(CVES) da sua imagem de container. 
2. Utilize o Docker Scout para verificar as vulnerabilidades(CVES) da sua imagem de container.
3. Utilize uma imagem Distroless para otimizar sua imagem de container.
4. Utilize o Hadolint para saber se o Dockerfile está utilizando as melhores práticas. 
5. Envie a imagem para o Docker Hub. 
6. Assine sua imagem utilizando o Cosing e envie novamente para o Docker Hub.
7. Suba a aplicação.

## Resolução

###### Obs: Antes de executar os comandos do Trivy, Docker Scout e enviar a imagem para o Docker Hub, certifique-se de estar logado no Docker Hub utilizando o comando `docker login`.

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
3. Otimizando a imagem utilizando Distroless:

### Antes da otimização:
###### Tamanho da imagem: **136MB** 
```
FROM python:3-slim
WORKDIR /app
COPY ./giropops-senhas/requirements.txt requirements.txt
COPY ./giropops-senhas/app.py . 
COPY ./giropops-senhas/templates/ templates/
COPY ./giropops-senhas/static/ static/
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD ["python", "-c", "import http.client; import sys; conn = http.client.HTTPConnection('localhost', 5000); conn.request('GET', '/'); res = conn.getresponse(); sys.exit(1) if res.status != 200 else sys.exit(0)"]
```
### Depois da otimização:
###### Tamanho da imagem: **83MB** 
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
4. Instalando o [Hadolint](https://github.com/hadolint/hadolint)
```
sudo mv hadolint-v2.12.0-linux-x86_64 /usr/local/bin/hadolint
sudo chmod +x /usr/local/bin/hadolint
```
- Utilizando o Hadolint: 
```
hadolint Dockerfile
```
###### Obs: A única melhoria sugerida para o Dockerfile otimizado com Distroless é a DL3007, que informa sobre o perigo da utilização de imagens latest. Como a Distroless é da chainguard é necessário entrar em contato com eles para solicitar uma versão específica e só assim poder tirar o warning DL3007.
5. Colocando a imagem no Docker Hub:
```
docker push SUA_IMAGEM:1.0
```
6. Instalando o [Cosign](https://docs.sigstore.dev/cosign/system_config/installation/)
- Criando as chaves privada e pública no Cosign:
```
cosign generate-key-par 
```
- Assinando a imagem: 
```
cosign sign --key SUA_CHAVE_PRIVADA SUA_IMAGEM:1.0
```
- Enviando novamente para o Docker Hub:
```
docker push SUA_IMAGEM:1.0
```
- Validando a imagem:
```
cosign verify --key SUA_CHAVE_PUBLICA SUA_IMAGEM:1.0
```
7. Subindo a aplicação: 
- Crie uma network para a comunicação entre o container da App e o container do Redis
```
docker network create -d bridge net-giropops-senhas
```
- Crie um container utilizando a network que acabamos de criar e utilize a imagem do Redis
```
docker container run -d -p 6379:6379 --network -net-giropops-senhas --name redis-chainguad cgr.dev/chainguard/redis
```
- Crie um container utilizando a imagem SEU_USUARIO_NO_DOCKER_HUB/linuxtips-giropops-senhas-chainguard:1.0
```
docker container run -d -p 5000:5000 --network net-giropops-senhas --env REDIS_HOST=redis-chainguard --name giropops-senhas-chainguard SEU_USUARIO_NO_DOCKER_HUB/linuxtips-giropops-senhas-chainguard:1.0
```
- Por fim acesse o seu navegador utilizando a url: **localhost:5000**
