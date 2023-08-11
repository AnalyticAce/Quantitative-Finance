#!/bin/bash

packages=(
    "MetaTrader5"
    "pandas"
    "ta"
)

for package in "${packages[@]}"; do
    pip install "$package"
done

echo "Packages installation completed."
