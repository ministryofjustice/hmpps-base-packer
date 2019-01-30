import yaml
import git
import json
import sys


def find_json_value(json_obj, key):

    def _(dictobj, lookup):
        if lookup in dictobj.keys():
            return dictobj[lookup]
        else:
            for sub_dictobj in [d for d in dictobj.values() if type(d) == dict]:
                result = _(sub_dictobj, lookup)
                if result:
                    return result

            # if objects in dictobj.values() are lists, go through them
            for listobject in [l for l in dictobj.values() if type(l) == list]:
                for sub_dictobj in [d for d in listobject if type(d) == dict]:
                    result = _(sub_dictobj, lookup)
                    if result:
                        return result
            return None

    return _(json_obj, key)


def extract_galaxy_libs(filename):
    with open(filename) as json_data:
        data = json.load(json_data)
        json_data.close()

    print(find_json_value(data, 'galaxy_file'))


if __name__ == "__main__":
    extract_galaxy_libs(filename=sys.argv[1])
