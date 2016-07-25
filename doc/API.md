# API

## Tutorial

Most of the API outputs JSON. JSON can be parsed by JSON parsers,
available in most languages.

See if the server is live

```js
curl "http://test-gn2.genenetwork.org/api_pre1/"

{"version":"0.50-pre1","I am":"genenetwork"}
```

or with wget

```js
wget -qO - "http://test-gn2.genenetwork.org/api_pre1/"

{"version":"0.50-pre1","I am":"genenetwork"}
```

List species

```js
curl "http://test-gn2.genenetwork.org/api_pre1/species"

[[1,"mouse","Mus musculus"],[2,"rat","Rattus norvegicus"],[3,"arabidopsis","Arabidopsis thaliana"],[4,"human","Homo sapiens"],[5,"barley","Hordeum vulgare"],[6,"drosophila","Drosophila melanogaster"],[7,"macaque monkey","Macaca mulatta"],[8,"soybean","Soybean"],[9,"tomato","Tomato"]]
```

To get information on the BXD cross

```js
curl "http://test-gn2.genenetwork.org/api_pre1/group/BXD.json"

{"species_id":1,"species":"mouse","mapping_method_id":1,"group_id":1,"group":"BXD","genetic_type":"riset","chr_info":[["1",197195432],["2",181748087],["3",159599783],["4",155630120],["5",152537259],["6",149517037],["7",152524553],["8",131738871],["9",124076172],["10",129993255],["11",121843856],["12",121257530],["13",120284312],["14",125194864],["15",103494974],["16",98319150],["17",95272651],["18",90772031],["19",61342430],["X",166650296]]}
```

to list all available datasets for the BXD

```js
curl "http://test-gn2.genenetwork.org/api_pre1/datasets/BXD"

[[7,"HC_U_0304_R","GNF Stem Cells U74Av2 (Mar04) RMA"],[9,"CB_M_1003_M","SJUT Cerebellum mRNA M430 (Oct03) MAS5"],[42,"CB_M_0204_P","INIA Brain mRNA M430 (Feb04) PDNN"],[44,"CB_M_1004_M","SJUT Cerebellum mRNA M430 (Oct04) MAS5"]
...
```

To get information on a dataset, e.g. HC_U_0304_R

```js
curl "http://test-gn2.genenetwork.org/api_pre1/dataset/HC_U_0304_R.json"

{"tissue_id":3,"tissue":"Hematopoietic Cells mRNA","short_name":"GNF Stem Cells U74Av2 (Mar04) RMA","public":2,"name":"HC_U_0304_R","id":7,"full_name":"GNF Stem Cells U74Av2 (Mar04) RMA","data_scale":"log2","confidential":0}
```

or through its id

```js
curl "http://test-gn2.genenetwork.org/api_pre1/dataset/7.json"

{"tissue_id":3,"tissue":"Hematopoietic Cells mRNA","short_name":"GNF Stem Cells U74Av2 (Mar04) RMA","public":2,"name":"HC_U_0304_R","id":7,"full_name":"GNF Stem Cells U74Av2 (Mar04) RMA","data_scale":"log2","confidential":0}
```

get dataset phenotype information for a range (here mRNA propesets)

```js
curl "http://test-gn2.genenetwork.org/api_pre1/phenotypes/HC_U_0304_R.json?start=100&stop=101"

[{"symbol":"0610005C13Rik","p_value":0.666,"name_id":104617,"name":"104617_at","mean":8.165623333333329,"locus":"mCV25433152","chr":7,"additive":-0.0489058035714287,"Mb":52.823543,"MAX_LRS":9.99712881751494},
{"symbol":"0610006I08Rik","p_value":0.914,"name_id":96017,"name":"96017_at","mean":10.4658333333333,"locus":"CEL-3_23204282","chr":19,"additive":0.0437053571428568,"Mb":8.845681,"MAX_LRS":7.76436750913729}]
```

Get the actual trait measurements with the stderr (here "null")

```js
curl "http://test-gn2.genenetwork.org/api_pre1/phenotype/HC_U_0304_R/104617_at.json"

[[4,"BXD1",8.0493,"null"],[5,"BXD2",8.1155,"null"],[6,"BXD5",8.0643,"null"],[7,"BXD6",8.1703,"null"],[8,"BXD8",8.0674,"null"],[9,"BXD9",8.1049,"null"],[10,"BXD11",8.3174,"null"],[11,"BXD12",8.1275,"null"],[13,"BXD14",8.1352,"null"],[14,"BXD15",8.2532,"null"],[15,"BXD16",8.3353,"null"],[16,"BXD18",8.2075,"null"],[17,"BXD19",8.2391,"null"],[19,"BXD21",8.1582,"null"],[20,"BXD22",8.2263,"null"],[22,"BXD24",8.0426,"null"],[23,"BXD25",7.9472,"null"],[24,"BXD27",8.201,"null"],[25,"BXD28",8.068,"null"],[26,"BXD29",8.2375,"null"],[27,"BXD30",8.223,"null"],[28,"BXD31",8.1194,"null"],[29,"BXD32",8.039,"null"],[30,"BXD33",8.2712,"null"],[31,"BXD34",8.3136,"null"],[33,"BXD36",8.1942,"null"],[35,"BXD38",8.163,"null"],[36,"BXD39",8.1966,"null"],[37,"BXD40",8.1498,"null"],[39,"BXD42",8.2312,"null"]]
```

here an example that includes parents and stderr:

```js
curl "http://test-gn2.genenetwork.org/api_pre1/phenotype/HC_M2_0606_P/1443823_s_at.json"

[[1,"B6D2F1",15.251,0.136],[2,"C57BL/6J",15.626,0.28],[3,"DBA/2J",14.716,0.26],[4,"BXD1",15.198,0.153],[5,"BXD2",14.918,0.023],[6,"BXD5",15.057,0.273],[7,"BXD6",15.232,0.107],[8,"BXD8",14.968,0.189],[9,"BXD9",14.87,0.454],[10,"BXD11",15.084,0.082],[11,"BXD12",15.192,0.298],[12,"BXD13",14.924,0.33],[14,"BXD15",15.343,0.34],[15,"BXD16",15.226,0.071],[17,"BXD19",15.364,0.074],[18,"BXD20",15.36,0.103],[19,"BXD21",14.792,0.911],...
```
