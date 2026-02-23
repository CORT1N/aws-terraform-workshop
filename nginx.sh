#!/bin/bash

sudo dnf update -y
sudo dnf install nginx -y

systemctl enable nginx
systemctl start nginx