#/bin/bash

LATEST_HUGO_VERSION=0.14

# check if curl is installed
# install otherwise
if [ "$(which curl)" == "" ]; then
    if [ "$(which apt-get)" != "" ]; then
        apt-get update
        apt-get install -y curl
    else
        yum install -y curl
    fi
fi

if [ "$WERCKER_HUGO_THEME_CHECK_VERSION" == "false" ]; then
    echo "The Hugo version in your wercker.yml isn't set correctly. Please put quotes around it. We will continue using the latest version ($LATEST_HUGO_VERSION)."
    export WERCKER_HUGO_THEME_CHECK_VERSION=""
fi

if [ ! -n "$WERCKER_HUGO_THEME_CHECK_VERSION" ]; then
    export WERCKER_HUGO_THEME_CHECK_VERSION=$LATEST_HUGO_VERSION
fi

if [ ! -n "$WERCKER_HUGO_THEME_CHECK_NAME" ]; then
    export WERCKER_HUGO_THEME_CHECK_NAME="mytheme"
fi

cd $WERCKER_STEP_ROOT
curl -L https://github.com/spf13/hugo/releases/download/v${WERCKER_HUGO_THEME_CHECK_VERSION}/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64.tar.gz -o ${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64.tar.gz
tar xzf hugo_${WERCKER_HUGO_THEME_CHECK_VERSION}_linux_amd64.tar.gz

${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64 new site $WERCKER_STEP_ROOT/test		
mkdir -p $WERCKER_STEP_ROOT/test/themes/${WERCKER_HUGO_THEME_CHECK_NAME}

cd $WERCKER_SOURCE_DIR
mv * $WERCKER_STEP_ROOT/test/themes/${WERCKER_HUGO_THEME_CHECK_NAME}/

cd $WERCKER_STEP_ROOT/test
${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64 new post/test.markdown

${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64 check -t ${WERCKER_HUGO_THEME_CHECK_NAME}
${WERCKER_STEP_ROOT}/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64/hugo_${WERCKER_HUGO_BUILD_VERSION}_linux_amd64 build -D -F -t ${WERCKER_HUGO_THEME_CHECK_NAME}
