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
CMD [ "run", "--host=0.0.0.0" ]
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD ["python", "-c", "import http.client; import sys; conn = http.client.HTTPConnection('localhost', 5000); conn.request('GET', '/'); res = conn.getresponse(); sys.exit(1) if res.status != 200 else sys.exit(0)"]
