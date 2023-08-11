if [ ! -d "./app" ]; then
    echo "You must run this script from the root of the project."
    exit 1
fi

if [ ! -d "./venv" ]; then
    echo "You must create a virtual environment first."
    exit 1
fi
source ./venv/bin/activate
PYTHONPATH=`pwd`/app hypercorn --bind 0.0.0.0:7000 --reload main:app