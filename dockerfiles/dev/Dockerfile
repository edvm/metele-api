FROM python:3.11-buster

ENV PYTHONUNBUFFERED 1

EXPOSE 7000

COPY poetry.lock pyproject.toml  ./
COPY ./scripts/install.sh /install.sh

RUN pip install --upgrade pip && \
    pip install poetry && \
    poetry config virtualenvs.create false && \
    poetry export -f requirements.txt --output requirements.txt && \
    /install.sh docker


WORKDIR /app

COPY . ./
EXPOSE 7000/tcp
ENV PYTHONPATH app
CMD ["/app/entrypoint.sh"]
