# 🌐 Traceroute

Traceroute is an improved tool for traditional traceroute and tracert. This entry-level version includes only the main features of traditional tracert, plus the whois of each gateway.

## 🚨 Requirements

* Python 3.10+

## ⚙️ Installation

You can install `traceroute` through automated bash script

```sh
sudo curl -s "https://raw.githubusercontent.com/blacknesses/Traceroute/principal/install.sh" | bash
```

## 📖 Basic Usage

```sh
trace IP/Domain
trace -v 0.1
```

⚠️ Warning: Traceroute does not accept url syntax (https://) only the domain or ip address

## 🥺 Uninstall
```sh
sudo /usr/local/bin/uninstall_trace.sh
```

![GitHub License](https://img.shields.io/github/license/blacknesses/Traceroute)
![GitHub top language](https://img.shields.io/github/languages/top/blacknesses/Traceroute)
