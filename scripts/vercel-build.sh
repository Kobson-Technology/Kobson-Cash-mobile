#!/usr/bin/env bash
#
# Construction de l'application web Kobson Cash pour Vercel.
#
# Vercel n'a pas Flutter dans son image de construction : ce script l'installe, puis construit
# l'application. Compter quelques minutes par déploiement.
#
# Il existe pour une raison précise : la commande de construction de Vercel est **limitée à
# 256 caractères**, et l'installation de Flutter, la configuration et la construction en demandent
# davantage. Mise bout à bout, elle était tronquée en silence — le déploiement échouait sans que la
# cause soit lisible.
#
# Les variables de l'application mobile sont fournies à la compilation par `--dart-define` :
# ce sont des constantes du bundle, pas des variables lues à l'exécution. Les changer demande
# donc une RECONSTRUCTION.
#
# Variables de compilation transmises à l'application (toutes celles utilisées par le mobile) :
#   API_BASE_URL             adresse de l'API REST. Défaut : https://apicash.runasp.net
#   GOOGLE_SERVER_CLIENT_ID  client OAuth 2.0 « Web » requis par Google Sign-In.
#                            Défaut : vide -> la connexion Google reste inactive sur le web.
#
# Variable facultative dans Vercel :
#   FLUTTER_VERSION          « stable » par défaut — À FIGER pour des constructions reproductibles.
#
set -euo pipefail

API="${API_BASE_URL:-https://apicash.runasp.net}"
GOOGLE_CLIENT_ID="${GOOGLE_SERVER_CLIENT_ID:-}"
FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_DIR="${HOME}/flutter-sdk"

if [ ! -d "${FLUTTER_DIR}" ]; then
  echo "Installation de Flutter (${FLUTTER_VERSION})..."
  git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
export PUB_CACHE="${HOME}/.pub-cache"

flutter config --no-analytics --enable-web >/dev/null
flutter pub get

# Toutes les variables de compilation de l'application sont transmises ici, exactement comme
# pour une construction mobile : aucune ne doit rester à sa valeur par défaut par oubli.
flutter build web \
  --release \
  --dart-define=API_BASE_URL="${API}" \
  --dart-define=GOOGLE_SERVER_CLIENT_ID="${GOOGLE_CLIENT_ID}"

echo "Construction terminee : build/web"
