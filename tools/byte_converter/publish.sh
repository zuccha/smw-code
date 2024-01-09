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
    cp dist/byte_converter.html $WEBSITE_PATH
    pushd $WEBSITE_PATH > /dev/null

    if [[ -n $(git log --all --grep="$GIT_TAG") ]]; then
      log_warn "Skip publish $WEBSITE_NAME: already published"
      git reset byte_converter.html
    else
      log_info "Publish $WEBSITE_NAME"

      local BRANCH_NAME="$(git_current_branch)"
      git stash
      git checkout main

      git add byte_converter.html
      git commit -m $GIT_TAG
      git push

      git checkout $BRANCH_NAME
      git stash pop
    fi

    popd > /dev/null
  fi
}

if [[ -z $GIT_TAG ]]; then
  log_warn "Skip publish: no Git tag"
else
  publish_website $WEBSITE_1_NAME $WEBSITE_1_PATH
  publish_website $WEBSITE_2_NAME $WEBSITE_2_PATH
fi
