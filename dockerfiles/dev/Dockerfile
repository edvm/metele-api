FROM python:3.12.2

ENV PYTHONUNBUFFERED 1

COPY requirements.txt dev-requirements.txt ./

RUN pip install --upgrade pip && \
    pip install wheel && \
    pip install -r /dev-requirements.txt

WORKDIR /app
COPY . ./
RUN mkdir -p /var/log/fastapi
EXPOSE 7000/tcp
ENV PYTHONPATH app
CMD ["/app/entrypoint.sh"]
