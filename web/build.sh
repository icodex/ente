#!/bin/sh

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
apt-get install nodejs -y
npm install npm@latest -g
npm install --global yarn

git submodule update --init --recursive
yarn install
NEXT_PUBLIC_ENTE_ENDPOINT=https://api.disktank.com yarn build
