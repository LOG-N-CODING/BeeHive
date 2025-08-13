# 베이스 이미지: Python 3.10이 설치된 경량 이미지
FROM python:3.10-slim

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드 복사
COPY . .

# 필수 패키지 설치
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn[standard] \
    openai

# 앱 실행 명령
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]