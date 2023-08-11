#!/bin/sh
cd /app/
python -m hypercorn --bind 0.0.0.0:7000 main:app
