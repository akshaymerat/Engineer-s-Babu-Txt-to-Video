# FROM python:3.10.8-slim-buster
# RUN apt-get update -y && apt-get upgrade -y \
  #   && apt-get install -y --no-install-recommends gcc libffi-dev musl-dev ffmpeg aria2 python3-pip \
  #  && apt-get clean \
  #  && rm -rf /var/lib/apt/lists/*

# COPY . /app/
# WORKDIR /app/
# RUN pip3 install --no-cache-dir --upgrade --requirement requirements.txt
# RUN pip install pytube
@ ENV COOKIES_FILE_PATH="youtube_cookies.txt"
# CMD gunicorn app:app & python3 main.py
FROM python:3.10-slim-bullseye  # बेस इमेज अपग्रेड

# डेबियन आर्काइव्हसाठी सोर्सेस फाईल अपडेट करा (फक्त बस्टरसाठी)
RUN sed -i 's/deb.debian.org/archive.debian.org/g; s/security.debian.org/archive.debian.org\/debian-security/g' /etc/apt/sources.list

# सिस्टीम डिपेंडन्सी एकाच RUN लेयरमध्ये
RUN apt-get update -o Acquire::Check-Valid-Until=false \
    && apt-get install -y --no-install-recommends \
        gcc \
        libffi-dev \
        musl-dev \
        ffmpeg \
        aria2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/  # फक्त requirements.txt कॉपी करा
WORKDIR /app

# Python डिपेंडन्सी एकाच चरणात इन्स्टॉल करा
RUN python -m pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt pytube

COPY . /app/  # उर्वरित फाईल्स कॉपी करा

ENV COOKIES_FILE_PATH="youtube_cookies.txt"

# CMD साठी योग्य फॉरमॅट
CMD ["sh", "-c", "gunicorn app:app & python3 main.py"]
