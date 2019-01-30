import yaml
import git
import json
import sys


def extract_galaxy_libs(filename):
    with open(filename) as json_data:
        data = json.load(json_data)
        json_data.close()

    print(data)


if __name__ == "__main__":
    extract_galaxy_libs(filename=sys.argv[1])
