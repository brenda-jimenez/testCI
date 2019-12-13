#!/bin/bash
#lerna version --tag-version-prefix='beta' --conventional-commits --conventional-graduate --create-release github

lerna version --conventional-commits --create-release github

#Update qa
git checkout qa
git pull 
git rebase staging

#Update master
#git checkout master
#git pull 
#git rebase staging


