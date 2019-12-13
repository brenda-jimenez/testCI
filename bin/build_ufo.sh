#!/bin/bash

lerna run build \
  --stream \
  --scope=@lineage/ufo \
  --include-filtered-dependencies
