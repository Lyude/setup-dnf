#!/bin/sh
# Check if we need to refresh the metadata cache, and signal back to the Github job if so
timestamp() {
    date -r /var/cache/dnf/last_makecache +%s.%N
}

echo "::group::Refreshing metadata"
if [[ -e /var/cache/dnf/last_makecache ]]; then
    old_time=$(timestamp)
fi

retries=0
until dnf makecache --timer; do
    last_rc=$?
    let retries=$retries+1
    if [[ $retries -ge 5 ]]; then
        echo "::error::Failed to update dnf metadata cache"
        exit $last_rc
    else
        echo "Failed to update dnf metadata cache, retrying ($retries/5)"
        rm /var/cache/dnf/last_makecache
    fi
done

new_time=$(timestamp)

echo time=$new_time >> $GITHUB_OUTPUT
if [[ $old_time == $new_time ]]; then
    echo refreshed=0 >> $GITHUB_OUTPUT
else
    echo refreshed=1 >> $GITHUB_OUTPUT
fi

# vim: ts=4 sts=4 sw=4 tw=100 expandtab
