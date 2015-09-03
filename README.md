# Wercker build step for hugo themes

This build step for [wercker](http://wercker.com) validates a [hugo](http://gohugo.io) theme.

The script is based on the [hugo build](https://github.com/ArjenSchwarz/wercker-step-hugo-build) step by Arjen Schwarz.

[![wercker status](https://app.wercker.com/status/644025422415f837c19663891770cc29/m "wercker status")](https://app.wercker.com/project/bykey/644025422415f837c19663891770cc29)

## How it works

1. Downloads and installs hugo if it is not already installed
1. Clones https://github.com/spf13/HugoBasicExample as an example website to test the theme
1. The theme is put in the themes folder
1. The `hugo check` command is used to validate the syntax
1. The `hugo` command is used to make sure the site builds with your theme
1. The script checks if you have the required files to publish your theme (*README.md*, *images/tn.png*, *images/screenshot.png*)

## Versioning

The version number consists of three numbers. A bump in the in the major version (first number) indicates breaking changes. A bump in the second number indicates new features. The third number is increased for bugfixes.

## Configuration

* `theme`: the name of your theme (default: *mytheme*)

### Docker stack example

	box: samueldebruyn/hugo-build
	build:
	  steps:
	    - samueldebruyn/hugo-theme-check:
	        theme: material-lite

### Old Wercker stack example

	box: wercker/default
	build:
	  steps:
	    - samueldebruyn/hugo-theme-check:
	        theme: material-lite
