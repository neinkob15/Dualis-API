FROM python:3-buster

WORKDIR /

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get install curl

COPY server.py ./

EXPOSE 5001

CMD [ "python", "-u", "./server.py" ]
