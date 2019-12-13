#!/bin/bash

NODE_ENV=development \
  lerna run start  \
     (node ./node_modules/npm-delay 1000 && lerna run start --scope=@lineage/ufo --stream)
