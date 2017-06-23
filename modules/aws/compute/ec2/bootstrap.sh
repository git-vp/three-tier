#!/usr/bin/env bash

# Script to install the following tools in a Ubuntu image
#   * Python
#
# Created by: Venugopal Panchamukhi
# Date: 01/06/2017

sudo apt-get --assume-yes update
sudo apt-get --assume-yes install python
sudo apt-get --assume-yes install mysql-client