FROM python:3.12-buster

ENV PYTHONUNBUFFERED 1

COPY requirements.txt dev-requirements.txt ./

COPY poetry.lock pyproject.toml  ./

RUN pip install --upgrade pip && \
    pip install poetry && \
    pip install wheel && \
    pip install -r /requirements.txt && \
    pip install -r /dev-requirements.txt

WORKDIR /app
COPY . ./
RUN mkdir -p /var/log/fastapi
EXPOSE 7000/tcp
ENV PYTHONPATH app
CMD ["/app/entrypoint.sh"]
