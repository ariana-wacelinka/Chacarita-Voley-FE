param(
  [string]$BackendUrl = "https://chaca-jjsnmt6wj7u3.lafuah.com/graphql"
)

flutter build appbundle --release --dart-define=BACKEND_URL=$BackendUrl
