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

SOURCES_UPDATED=false
update_sources()
{
    if [ "$SOURCES_UPDATED" = false ] ; then
        if command_exists apt-get; then
            apt-get update
        fi
        if command_exists pacman; then
            pacman -Syu
        fi
        SOURCES_UPDATED=true
    fi 
}

install_hugo()
{
    # check if curl is installed
    # install otherwise
    if ! command_exists curl; then
        update_sources
        if command_exists apt-get; then
            apt-get install -y curl
        elif command_exists pacman; then
            pacman -S --noconfirm curl
        else
            yum install -y curl
        fi
    fi
    
    cd $WERCKER_STEP_ROOT    
    curl -sL https://github.com/spf13/hugo/releases/download/v${WERCKER_HUGO_BUILD_VERSION}/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64.tar.gz -o ${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64.tar.gz
    tar xzf hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64.tar.gz
    HUGO_COMMAND=${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64
}

install_git()
{
    # check if pygments is installed
    # install otherwise
    if ! command_exists git; then
        update_sources
        if command_exists apt-get; then
            apt-get install -y git
        elif command_exists pacman; then
            pacman -S --noconfirm git
        else
            yum install -y git
        fi
    fi
}

# set the theme name
if [ ! -n "$WERCKER_HUGO_THEME_CHECK_THEME" ]; then
    echo "no theme name set, using ${DEFAULT_THEME_NAME}"
    WERCKER_HUGO_THEME_CHECK_THEME=DEFAULT_THEME_NAME
fi

#check if hugo is already installed in the container
if ! command_exists "hugo"; then
    echo "hugo not found, installing hugo..."
    install_hugo
else
    hugo_version_output=`hugo version`
    echo "using the installed ${hugo_version_output}..."
    HUGO_COMMAND="hugo"
fi

install_git

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
