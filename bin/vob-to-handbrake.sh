#!/bin/bash

set -eo pipefail
shopt -s nullglob

cat_and_cleanup() {
    local output=${1:?}
    shift

    cat "$@" >"$output" \
        && rm -f "$@"
}

transcode() {
    local src_dir=${1:?}
    local movie_path=${2:?}

    local all_the_tracks=1,2,3,4,5,6,7,8,9,10

    # TODO: maybe we don't need this. maybe we can just drop "--main-feature" and it will combine for us?
    # TODO: at the same time, every system i care about supports large files
    if [ "$(find "$src_dir" -name "*.vob" -print | wc -l)" -gt 1 ]; then
        echo "Multple vobs found. Combining them now..."
        cat_and_cleanup "$src_dir/combined.vob" "$src_dir"/*.vob
    fi

    HandBrakeCLI \
        --audio "$all_the_tracks" \
        --input "$src_dir" \
        --main-feature \
        --markers \
        --native-language eng \
        --optimize \
        --output "$movie_path" \
        --preset "High Profile"

        # TODO: this would be nice, but its erring sometimes. extract them to srt files instead?
        # --subtitle "scan,$all_the_tracks" \
        # --subtitle-default=1

    return $?
}

main() {
    # TODO: proper usage
    local vob_dir=${1:?}
    local movie_path=${2:?}

    vob_dir=${vob_dir%/}

    echo "Transcoding $vob_dir -> $movie_path..."
    transcode "$vob_dir" "$movie_path"

    echo "Cleaning $vob_dir..."
    # todo: eventually we can automatically delete, but lets make sure it works first
    mv "$vob_dir" "$vob_dir.done"

    echo "SUCCESS creating $movie_path"
}

main "$@"
