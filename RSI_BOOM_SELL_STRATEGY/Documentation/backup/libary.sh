#!/bin/bash

packages=(
    "MetaTrader5==5.0.40"
    "pandas==1.3.3"
    "ta==0.7.0"
    "termcolor==1.1.0"
    "playsound"
    "telebot"
    "plotly"
)

for package in "${packages[@]}"; do
    pip install "$package"
done

echo "Packages installation completed."
