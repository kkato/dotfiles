default_branch() {
  local ref
  if ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null); then
    echo "${ref##*/}"
    return
  fi
  for b in main master; do
    if git rev-parse --verify "$b" >/dev/null 2>&1; then
      echo "$b"
      return
    fi
  done
  echo master
}
