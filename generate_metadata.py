import yaml
import git
import json
import sys
import os
import shutil
import datetime

def find_repo_revision(repo, filename, branch='master'):
    shutil.rmtree(os.path.join(filename + '_git'), ignore_errors=True)
    repo = git.Repo.clone_from(repo, os.path.join(filename+'_git'), branch=branch,)
    commits = repo.commit(branch)
    shutil.rmtree(os.path.join(filename+'_git'), ignore_errors=True)
    return commits


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
    galaxy_libs = []

    with open(filename) as json_data:
        data = json.load(json_data)
        json_data.close()
        galaxy_file = find_json_value(data, 'galaxy_file')

        if galaxy_file:
            with open(galaxy_file) as galaxy_file_data:
                galaxy_data = yaml.load(galaxy_file_data)
                for item in galaxy_data:

                    branch = "master"
                    if "version" in item:
                        branch = item['version']

                    revision = "master"
                    if ".git" in item['src']:
                        revision = find_repo_revision(repo=item['src'], filename=filename, branch=branch)

                    if 'name' in item:
                        d = {'lib': item['name'], 'src': item['src'], 'commit_hash': '{}'.format(revision)}
                    else:
                        d = {'lib': item['src'], 'src': item['src'], 'commit_hash': '{}'.format(revision)}

                    galaxy_libs.append(d)

    return galaxy_libs


def write_file(filename, data):
    with open('./meta/{}_meta.json'.format(filename), 'w') as meta_file:
        print(data, file=meta_file)

    return './meta/{}_meta.json'.format(filename)


def find_jenkins_env_data():
    jenkins_data = {
        'build_data': [
            {'jenkins': {
                'build_time': str(datetime.datetime.now()),
                'build_url': os.getenv('BUILD_URL', ''),
                'build_number': os.getenv('BUILD_ID', ''),
                'build_tag': os.getenv('BUILD_TAG', '')
            }},
            {'git': {
                'git_repo': os.getenv('GIT_URL', ''),
                'git_commit': os.getenv('GIT_COMMIT', ''),
                'git_previous_commit': os.getenv('GIT_PREVIOUS_COMMIT', ''),
                'git_branch': os.getenv('GIT_BRANCH', '')
            }}
        ]
    }

    return jenkins_data


if __name__ == "__main__":
    meta_data = list()
    meta_data.append({'ansible_galaxy': extract_galaxy_libs(filename=sys.argv[1])})
    meta_data.append(find_jenkins_env_data())
    write_file(filename=sys.argv[1], data=meta_data)
