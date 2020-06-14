FROM python:3-alpine

WORKDIR /opt/dualis-app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN apk add --no-cache bash
RUN apk add --no-cache curl

COPY . .

EXPOSE 5001

CMD [ "python", "./server.py" ]
