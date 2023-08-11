#!/bin/bash

packages=(
    "MetaTrader5"
    "pandas"
    "ta"
    "telebot"
    "plotly"
)

for package in "${packages[@]}"; do
    pip install "$package"
done

echo "Packages installation completed."
