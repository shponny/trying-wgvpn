#!/bin/bash

pipenv --rm
pipenv install
pipenv run install
pipenv run deplot
pipenv run test