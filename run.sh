#/bin/bash
set -e

HUGO_VERSION=0.14
DEFAULT_THEME_NAME="mytheme"
EXAMPLE_SITE="https://github.com/spf13/HugoBasicExample.git"

command_exists()
{
    echo "checking if the command $1 exists..."
    hash "$1" 2>/dev/null
}

install_hugo()
{
    # check if curl is installed
    # install otherwise
    if ! command_exists curl; then
        echo "curl not found, installing curl..."
        if command_exists apt-get; then
            apt-get update && apt-get install -y curl
        else
            yum install -y curl
        fi
    fi
    
    cd ${WERCKER_STEP_ROOT}
    echo "downloading hugo with curl..."
    curl -sL https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux_amd64.tar.gz -o ${WERCKER_STEP_ROOT}/hugo_${HUGO_VERSION}_linux_amd64.tar.gz
    echo "unpacking hugo..."
    tar xzf hugo_${HUGO_VERSION}_linux_amd64.tar.gz
    export HUGO_COMMAND=${WERCKER_STEP_ROOT}/hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64
    echo "we will be using ${HUGO_COMMAND}"
}

# check if git is installed
if ! command_exists git; then
    echo "git not found, installing git..."
    if command_exists apt-get; then
        apt-get update && apt-get install -y git
    else
        yum install -y git
    fi
fi

# set the theme name
if [ ! -n "$WERCKER_HUGO_THEME_CHECK_THEME" ]; then
    echo "no theme name set, using ${DEFAULT_THEME_NAME}"
    export WERCKER_HUGO_THEME_CHECK_THEME=DEFAULT_THEME_NAME
fi

#check if hugo is already installed in the container
if ! command_exists "hugo"; then
    echo "hugo not found, installing hugo..."
    install_hugo
else
    hugo_version_output=`hugo version`
    echo "using the installed ${hugo_version_output}..."
    export HUGO_COMMAND="hugo"
fi

# clone the example site
cd ${WERCKER_STEP_ROOT}
echo "cloning the example site from ${EXAMPLE_SITE} to a new directory called example..."
git clone --recursive ${EXAMPLE_SITE} example
echo "creating the directory example/themes/${WERCKER_HUGO_THEME_CHECK_THEME}"
mkdir -p ${WERCKER_STEP_ROOT}/example/themes/${WERCKER_HUGO_THEME_CHECK_THEME}

# move the theme to the example site
cd ${WERCKER_SOURCE_DIR}
echo "moving the theme to the example site..."
mv * ${WERCKER_STEP_ROOT}/example/themes/${WERCKER_HUGO_THEME_CHECK_THEME}/

# do hugo checks
cd ${WERCKER_STEP_ROOT}/example
echo "running hugo check..."
eval ${HUGO_COMMAND} check -t ${WERCKER_HUGO_THEME_CHECK_THEME}
echo "running hugo..."
eval ${HUGO_COMMAND} -t ${WERCKER_HUGO_THEME_CHECK_THEME}

# check if screenshots and readme exist
echo "checking if the required images exist..."
cd $WERCKER_STEP_ROOT/example/themes/${WERCKER_HUGO_THEME_CHECK_THEME}/
echo "checking if the required images exist in ${WERCKER_HUGO_THEME_CHECK_THEME}/images/ ..."
[[ -f README.md && -f images/screenshot.png && -f images/tn.png ]] || (echo "Please include the required images in your images folder. See https://github.com/spf13/hugoThemes/blob/master/README.md" && exit 1)
