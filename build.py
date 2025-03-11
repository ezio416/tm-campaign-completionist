# c 2023-12-28
# m 2025-03-10

import os
from zipfile import ZipFile, ZIP_DEFLATED


def main():
    dir = os.getcwd()

    src = dir + '/src'
    if not os.path.isdir(src):
        print('src folder missing!')
        return

    has_assets = True
    assets = dir + '/assets'
    if not os.path.isdir(assets):
        print('assets folder missing!')
        has_assets = False

    license = dir + '/LICENSE.txt'
    if not os.path.isfile(license):
        print('LICENSE.txt missing!')
        return

    info = dir + '/info.toml'
    if not os.path.isfile(info):
        print('info.toml missing!')
        return

    with open(info, 'r') as f:
        lines = f.readlines()

    for line in lines:
        if 'version' in line:
            zip_name = dir.split('\\')[-1] + '_' + line.split(' ')[2].replace('"', '').replace('\n', '') + '.op'
            break

    new_zip_name = dir + '/versions/unsigned/' + zip_name

    if os.path.isfile(new_zip_name):
        print(zip_name + ' already exists in unsigned folder!')
        return

    with ZipFile(zip_name, 'w', ZIP_DEFLATED) as z:
        z.write(info, os.path.basename(info))
        z.write(license, os.path.basename(license))

        for dir, subdirs, files in os.walk(src):
            for file in files:
                abspath = os.path.join(dir, file)
                z.write(abspath, os.path.relpath(abspath, os.path.join(src, '..')))

        if has_assets:
            for dir, subdirs, files in os.walk(assets):
                for file in files:
                    abspath = os.path.join(dir, file)
                    z.write(abspath, os.path.relpath(abspath, os.path.join(assets, '..')))

    os.rename(zip_name, new_zip_name)


if __name__ == '__main__':
    main()
