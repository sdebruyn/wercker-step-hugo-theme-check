#/bin/bash
set -e

LATEST_HUGO_VERSION=0.14

# update sources if needed
if [ "$(which apt-get)" != "" ]; then
    apt-get update
fi

# check if curl is installed
if [ "$(which curl)" == "" ]; then
    if [ "$(which apt-get)" != "" ]; then
        apt-get install -y curl
    else
        yum install -y curl
    fi
fi

# check if git is installed
if [ "$(which git)" == "" ]; then
    if [ "$(which apt-get)" != "" ]; then
        apt-get install -y git
    else
        yum install -y git
    fi
fi

# set the hugo version
if [ "$WERCKER_HUGO_THEME_CHECK_VERSION" == "false" ]; then
    echo "The Hugo version in your wercker.yml isn't set correctly. Please put quotes around it. We will continue using the latest version ($LATEST_HUGO_VERSION)."
    export WERCKER_HUGO_THEME_CHECK_VERSION=""
fi

if [ ! -n "$WERCKER_HUGO_THEME_CHECK_VERSION" ]; then
    export WERCKER_HUGO_THEME_CHECK_VERSION=$LATEST_HUGO_VERSION
fi

# set the theme name
if [ ! -n "$WERCKER_HUGO_THEME_CHECK_THEME" ]; then
    export WERCKER_HUGO_THEME_CHECK_THEME="mytheme"
fi

# install hugo
cd $WERCKER_STEP_ROOT
curl -L https://github.com/spf13/hugo/releases/download/v${WERCKER_HUGO_THEME_CHECK_VERSION}/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64.tar.gz -o ${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64.tar.gz
tar xzf hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64.tar.gz

# clone the example site
git clone --recursive https://github.com/spf13/HugoBasicExample.git
mkdir -p HugoBasicExample/themes/${WERCKER_HUGO_THEME_CHECK_THEME}

# move the theme to the example site
cd $WERCKER_SOURCE_DIR
mv * $WERCKER_STEP_ROOT/HugoBasicExample/themes/${WERCKER_HUGO_THEME_CHECK_THEME}/

# do hugo checks
cd $WERCKER_STEP_ROOT/HugoBasicExample
${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64 check -t ${WERCKER_HUGO_THEME_CHECK_THEME}
${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64 -t ${WERCKER_HUGO_THEME_CHECK_THEME}

# check if screenshots and readme exist
cd $WERCKER_STEP_ROOT/HugoBasicExample/themes/${WERCKER_HUGO_THEME_CHECK_THEME}/
[[ -f README.md && -f images/screenshot.png && -f images/tn.png ]] && echo the required files exist || exit 1
