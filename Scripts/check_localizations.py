import json,re
from pathlib import Path
root=Path(__file__).resolve().parents[1]
langs={'en','zh-Hans','zh-Hant','ja','ko','de','fr','es'}
source='\n'.join(p.read_text() for p in (root/'Sources').rglob('*.swift'))
keys=set(re.findall(r'\bL\("([^"\n]+)"',source))
for file in (root/'Resources').glob('*.xcstrings'):
 d=json.loads(file.read_text())
 for key,item in d['strings'].items():
  assert set(item['localizations'])==langs,(file.name,key)
  formats=[]
  for lang,translation in item['localizations'].items():
   unit=translation['stringUnit'];assert unit['state']=='translated' and unit['value'].strip(),(key,lang)
   formats.append(re.findall(r'%(?:\d+\$)?[@dfsu]',unit['value']))
  assert all(f==formats[0] for f in formats),(key,formats)
 if file.stem=='Localizable': assert keys<=set(d['strings']),keys-set(d['strings'])
print(f'PASS: {len(keys)} referenced message keys; 8 complete languages; format placeholders match.')
