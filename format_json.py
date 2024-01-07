import json


with open('next_campaigns_raw.json', 'r', encoding='utf8') as f:
    j = json.loads(f.read())

with open('next_campaigns.json', 'w', encoding='utf8') as f:
    json.dump(j, f, indent=4, sort_keys=True)


with open('next_totds_raw.json', 'r', encoding='utf8') as f:
    j = json.loads(f.read())

with open('next_totds.json', 'w', encoding='utf8') as f:
    json.dump(j, f, indent=4, sort_keys=True)