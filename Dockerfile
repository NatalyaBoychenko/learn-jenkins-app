FROM mcr.microsoft.com/playwright:v1.40.0-jammy
RUN npm install -g netlify-cli serve
RUN apt update && apt install jq -y