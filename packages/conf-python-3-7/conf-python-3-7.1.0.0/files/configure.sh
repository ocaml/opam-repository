for version in 3.11 3.10 3.9 3.8 3.7; do
    python_exe="python$version"
    if "$python_exe" test.py; then
        echo "python3: \"$python_exe\"" >> conf-python-3-7.config
        exit 0
    fi
done
exit 1
