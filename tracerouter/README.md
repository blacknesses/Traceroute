# 🌐 Traceroute

![license](https://img.shields.io/github/license/ttafsir/evengsdk)
[![PyPI version](https://badge.fury.io/py/eve-ng.svg)](https://badge.fury.io/py/eve-ng)

Open source library and command line utilities to work with the [EVE-NG](https://www.eve-ng.net/)  [REST API](https://www.eve-ng.net/index.php/documentation/howtos/how-to-eve-ng-api/) .

Traceroute allows you to test routes and encompasses the basic functionalities of the tracert package.

## Requirements

* Python 3.10+

## ⚙️ Installation guide

BASH: You can install "traceroute" through bash script automation

```sh
curl -s https://raw.githubusercontent.com/blacknesses/traceroute/main/install.sh | bash
```

PIP: You can also install "traceroute" through pip

```sh
pip install git+https://github.com/blacknesses/traceroute
```

## 📖 Basic Usage

```sh
traceroute IP/Domain
```

⚠️ OBS: when translating domains, traceroute does not recognize syntaxes such as: http, //, :.
