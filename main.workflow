workflow "PublishNPM" {
  resolves = [
    "test",
    "copyfiles",
    "Publish",
  ]
  on = "push"
}

action "install" {
  uses = "actions/npm"
  runs = "npm install"
}

action "build" {
  uses = "actions/npm"
  runs = "npm run build"
  needs = ["install"]
}

action "rcfile" {
  uses = "actions/npm"
  runs = "mv .npmrc.ci .npmrc"
  needs = ["build"]
}

action "copyfiles" {
  uses = "actions/npm"
  runs = "bash -c"
  args = ["cp * .* dist/ 2>/dev/null || :"]
  needs = [
    "rcfile",
    "test",
  ]
}

action "test" {
  uses = "actions/npm"
  needs = ["build"]
  args = "run test:ci"
  secrets = ["NPM_AUTH_TOKEN"]
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter"
  needs = ["copyfiles"]
  args = "branch master"
}

action "Publish" {
  uses = "actions/npm"
  needs = ["Filters for GitHub Actions"]
  args = "publish dist/ --access public"
  secrets = ["NPM_AUTH_TOKEN"]
}
