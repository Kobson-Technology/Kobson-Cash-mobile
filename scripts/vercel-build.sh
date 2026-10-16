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
# L'adresse de l'API est fournie à la compilation par `--dart-define` : c'est une constante du
# bundle, pas une variable lue à l'exécution. La changer demande donc une RECONSTRUCTION.
#
# Variable facultative dans Vercel :
#   FLUTTER_VERSION   « stable » par défaut — À FIGER pour des constructions reproductibles.
#
set -euo pipefail

API="${API_BASE_URL:-https://apicash.runasp.net}"
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

flutter build web \
  --release \
  --dart-define=API_BASE_URL="${API}"

echo "Construction terminee : build/web"
