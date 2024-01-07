import json


for name in ('next_campaign', 'next_totd'):
    try:
        with open(f'{name}_raw.json', 'r', encoding='utf8') as f:
            j = json.loads(f.read())

        with open(f'{name}.json', 'w', encoding='utf8') as f:
            json.dump(j, f, indent=4, sort_keys=True)

    except Exception as e:
        print(e)