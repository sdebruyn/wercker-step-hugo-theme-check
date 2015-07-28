#/bin/bash
set -e

HUGO_VERSION=0.14

command_exists()
{
    hash "$1" 2>/dev/null
}

install_hugo()
{
    # check if curl is installed
    # install otherwise
    if ! command_exists curl; then
        if command_exists apt-get; then
            apt-get update && apt-get install -y curl
        else
            yum install -y curl
        fi
    fi
    
    cd $WERCKER_STEP_ROOT    
    curl -sL https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux_amd64.tar.gz -o ${WERCKER_STEP_ROOT}/hugo_${HUGO_VERSION}_linux_amd64.tar.gz
    tar xzf hugo_${HUGO_VERSION}_linux_amd64.tar.gz
    export HUGO_COMMAND=${WERCKER_STEP_ROOT}/hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64
}

# check if git is installed
if ! command_exists git; then
    if command_exists apt-get; then
        apt-get update && apt-get install -y git
    else
        yum install -y git
    fi
fi

# set the theme name
if [ ! -n "$WERCKER_HUGO_THEME_CHECK_THEME" ]; then
    export WERCKER_HUGO_THEME_CHECK_THEME="mytheme"
fi

#check if hugo is already installed in the container
if ! command_exists "hugo"; then
    install_hugo
else
    export HUGO_COMMAND="hugo"
fi

# clone the example site
git clone --recursive https://github.com/spf13/HugoBasicExample.git
mkdir -p HugoBasicExample/themes/${WERCKER_HUGO_THEME_CHECK_THEME}

# move the theme to the example site
cd ${WERCKER_SOURCE_DIR}
mv * ${WERCKER_STEP_ROOT}/HugoBasicExample/themes/${WERCKER_HUGO_THEME_CHECK_THEME}/

# do hugo checks
cd ${WERCKER_STEP_ROOT}/HugoBasicExample
eval ${HUGO_COMMAND} check -t ${WERCKER_HUGO_THEME_CHECK_THEME}
eval ${HUGO_COMMAND} -t ${WERCKER_HUGO_THEME_CHECK_THEME}

# check if screenshots and readme exist
cd $WERCKER_STEP_ROOT/HugoBasicExample/themes/${WERCKER_HUGO_THEME_CHECK_THEME}/
[[ -f README.md && -f images/screenshot.png && -f images/tn.png ]] || (echo "Please include the required images in your images folder. See https://github.com/spf13/hugoThemes/blob/master/README.md" && exit 1)
