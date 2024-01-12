publish_website() {
  local WEBSITE_NAME=$1
  local WEBSITE_PATH=$2

  if [[ -z $WEBSITE_NAME ]]; then
    log_warn "Skip publish website: no website name"
  elif [[ -z $WEBSITE_PATH ]]; then
    log_warn "Skip publish $WEBSITE_NAME: no website path"
  elif [[ ! -d $WEBSITE_PATH ]]; then
    log_warn "Skip publish $WEBSITE_NAME: website $WEBSITE_PATH is doesn't exist"
  else
    pushd $WEBSITE_PATH > /dev/null

    if [[ -n $(git log --all --grep="$TAG") ]]; then
      log_warn "Skip publish $WEBSITE_NAME: already published"
    else
      log_info "Publish $WEBSITE_NAME"

      if git status --porcelain | grep -q "^.M"; then git stash; STASHED=1; fi

      local BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
      if [[ $BRANCH_NAME != main ]]; then git checkout main; fi

      cp $BYTE_CONVERTER_HTML_PATH $WEBSITE_PATH
      git add $BYTE_CONVERTER_HTML_NAME
      git commit -m $TAG
      git push

      if [[ $BRANCH_NAME != main ]]; then git checkout $BRANCH_NAME; fi
      if [[ -n $STASHED ]]; then git stash pop; fi
    fi

    popd > /dev/null
  fi
}

source $ROOT/_scripts/log.sh
BYTE_CONVERTER_HTML_NAME="byte_converter.html"
BYTE_CONVERTER_HTML_PATH="$(pwd)/dist/$BYTE_CONVERTER_HTML_NAME"

if [[ -z $TAG ]]; then
  log_warn "Skip publish: no Git tag"
else
  publish_website $WEBSITE_1_NAME $WEBSITE_1_PATH
  publish_website $WEBSITE_2_NAME $WEBSITE_2_PATH
fi
