#!/bin/bash

parallel_pids=()
parallel_names=()

run_parallel_task() {
    local name="$1"
    shift

    "$@" &
    parallel_pids+=("$!")
    parallel_names+=("$name")
}

wait_parallel_tasks() {
    local failed=0

    for i in "${!parallel_pids[@]}"; do
        if wait "${parallel_pids[$i]}"; then
            echo "  ✅ ${parallel_names[$i]} complete"
        else
            echo "  ⚠️  ${parallel_names[$i]} failed"
            failed=1
        fi
    done

    parallel_pids=()
    parallel_names=()
    return "$failed"
}
