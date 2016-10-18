# API

## Tutorial

### Introduction

GeneNetwork offers unprecedented access to the data of thousands of
QTL and GWAS experiments executed in the last decennium. These
datasets include mouse, rat, arabidopsis and even human data. Next to
having a browser-based user interface for accessing this data, our
goal is to present all data also through a REST API, so that it can be
used by anyone who has access to, for example, R and Python.  Next to
R/qtl-style CSV, most of the GN API outputs JSON. JSON can be parsed
by JSON parsers, available in most programming languages.

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

At this point almost all mouse BXD data is available through the REST
API (some 3,500 datasets!). We are expanding to all other non-human
datasets soon. Please contact us if you are interested in more data.

When you use this data for a publication make sure what the status is
by contacting the authors/owners of the dataset. Check also
http://genenetwork.org/statusandContact.html. In case you need
clarification please contact the GeneNetwork project.

### List species

```js
curl "http://test-gn2.genenetwork.org/api_pre1/species"

[[1,"mouse","Mus musculus"],[2,"rat","Rattus norvegicus"],[3,"arabidopsis","Arabidopsis thaliana"],[4,"human","Homo sapiens"],[5,"barley","Hordeum vulgare"],[6,"drosophila","Drosophila melanogaster"],[7,"macaque monkey","Macaca mulatta"],[8,"soybean","Soybean"],[9,"tomato","Tomato"]]
```

### Cross info

To get information on the BXD cross

```js
curl "http://test-gn2.genenetwork.org/api_pre1/group/BXD.json"

{"species_id":1,"species":"mouse","mapping_method_id":1,"group_id":1,"group":"BXD","genetic_type":"riset","chr_info":[["1",197195432],["2",181748087],["3",159599783],["4",155630120],["5",152537259],["6",149517037],["7",152524553],["8",131738871],["9",124076172],["10",129993255],["11",121843856],["12",121257530],["13",120284312],["14",125194864],["15",103494974],["16",98319150],["17",95272651],["18",90772031],["19",61342430],["X",166650296]]}
```

### Fetch datasets

to list all available datasets for the BXD

```js
curl "http://test-gn2.genenetwork.org/api_pre1/datasets/BXD"

[[7,"HC_U_0304_R","GNF Stem Cells U74Av2 (Mar04) RMA"],[9,"CB_M_1003_M","SJUT Cerebellum mRNA M430 (Oct03) MAS5"],[42,"CB_M_0204_P","INIA Brain mRNA M430 (Feb04) PDNN"],[44,"CB_M_1004_M","SJUT Cerebellum mRNA M430 (Oct04) MAS5"]
...
```

To get information on a dataset, e.g. HC_U_0304_R

```js
curl "http://test-gn2.genenetwork.org/api_pre1/dataset/HC_U_0304_R.json"

{"tissue_id":3,"tissue":"Hematopoietic Cells mRNA","short_name":"GNF Stem Cells U74Av2 (Mar04) RMA","public":2,"name":"HC_U_0304_R","id":7,"full_name":"GNF Stem Cells U74Av2 (Mar04) RMA","dataset":"probeset","data_scale":"log2","confidential":0}
```

or through its id (note the setting of "dataset")

```js
curl "http://test-gn2.genenetwork.org/api_pre1/dataset/10001.json"

{"year":"2001","title":"Genetic control of the mouse cerebellum: identification of quantitative trait loci modulating size and architecture","pmid":11438585,"name":"CBLWT2","id":10001,"descr":"Central nervous system, morphology: Cerebellum weight, whole, bilateral in adults of both sexes [mg]","dataset":"phenotype"}
```

or for a high-throughput set:

```js
curl "http://test-gn2.genenetwork.org/api_pre1/dataset/7.json"

{"tissue_id":3,"tissue":"Hematopoietic Cells mRNA","short_name":"GNF Stem Cells U74Av2 (Mar04) RMA","public":2,"name":"HC_U_0304_R","id":7,"full_name":"GNF Stem Cells U74Av2 (Mar04) RMA","dataset":"probeset","data_scale":"log2","confidential":0}
```

### Fetch phenotypes

#### Phenotype datasets

Phenotype datasets are 'classic' QTL datasets with individuals
(strains) and measured traits - distinguishable on the
'dataset=phenotype' field in the dataset record above.

Fetch the measurements with

```js
curl "http://test-gn2.genenetwork.org/api_pre1/trait/10001.json"
[[4,"BXD1",61.400001525878906,2.380000114440918],[5,"BXD2",49.0,1.25],[6,"BXD5",62.5,2.319999933242798],[7,"BXD6",53.099998474121094,1.2200000286102295],[8,"BXD8",59.099998474121094,2.069999933242798],[9,"BXD9",53.900001525878906,1.0499999523162842],[10,"BXD11",53.099998474121094,1.100000023841858],[11,"BXD12",45.900001525878906,1.090000033378601],[12,"BXD13",48.400001525878906,1.6299999952316284],[13,"BXD14",49.400001525878906,0.4399999976158142],[14,"BXD15",47.400001525878906,1.149999976158142],[15,"BXD16",56.29999923706055,1.2100000381469727],[16,"BXD18",53.599998474121094,1.440000057220459],[17,"BXD19",50.099998474121094,1.4199999570846558],[18,"BXD20",48.20000076293945,1.6699999570846558],[19,"BXD21",50.599998474121094,1.309999942779541],[20,"BXD22",53.79999923706055,1.5099999904632568],[21,"BXD23",48.599998474121094,1.0299999713897705],[22,"BXD24",54.900001525878906,1.9199999570846558],[23,"BXD25",49.599998474121094,0.8100000023841858],[24,"BXD27",47.400001525878906,2.25],[25,"BXD28",51.5,0.8700000047683716],[26,"BXD29",50.20000076293945,0.5600000023841858],[27,"BXD30",53.599998474121094,1.1399999856948853],[28,"BXD31",49.70000076293945,0.9100000262260437],[29,"BXD32",56.0,1.190000057220459],[30,"BXD33",52.099998474121094,0.6600000262260437],[31,"BXD34",53.70000076293945,1.2200000286102295],[32,"BXD35",49.70000076293945,2.0299999713897705],[33,"BXD36",44.5,0.7300000190734863],[35,"BXD38",51.099998474121094,1.7899999618530273],[36,"BXD39",54.900001525878906,0.8700000047683716],[37,"BXD40",49.900001525878906,1.1299999952316284],[39,"BXD42",59.400001525878906,0.949999988079071]]
```

which contains the records for [strain_id,strain,value,s.e.] for dataset 10001.

Or from the dataset name

```js
curl "http://test-gn2.genenetwork.org/api_pre1/trait/CBLDT2.json"

(nyi)
```

GN2 can also return the phenotypes in the R/qtl2 CSV data format as
described
[here](http://kbroman.org/qtl2/assets/vignettes/input_files.html).

```js
curl "http://test-gn2.genenetwork.org/api_pre1/trait/10001.csv"

(nyi)
```

#### mRNA probesets

get dataset phenotype information for a range (here mRNA probesets) - note this
only works for datasets that have the 'dataset=probeset' attribute.

```js
curl "http://test-gn2.genenetwork.org/api_pre1/phenotypes/HC_U_0304_R.json?start=100&stop=101"

[{"symbol":"0610005C13Rik","p_value":0.666,"name_id":104617,"name":"104617_at","mean":8.165623333333329,"locus":"mCV25433152","chr":7,"additive":-0.0489058035714287,"Mb":52.823543,"MAX_LRS":9.99712881751494},
{"symbol":"0610006I08Rik","p_value":0.914,"name_id":96017,"name":"96017_at","mean":10.4658333333333,"locus":"CEL-3_23204282","chr":19,"additive":0.0437053571428568,"Mb":8.845681,"MAX_LRS":7.76436750913729}]
```

Get the actual trait values or measurements of a sample with the
stderr (in this dataset stderr is missing, so null)

```js
curl "http://test-gn2.genenetwork.org/api_pre1/trait/HC_U_0304_R/104617_at.json"

[[4,"BXD1",8.049,null],[5,"BXD2",8.116,null],[6,"BXD5",8.064,null],[7,"BXD6",8.17,null],[8,"BXD8",8.067,null],[9,"BXD9",8.105,null],[10,"BXD11",8.317,null],[11,"BXD12",8.127,null],[13,"BXD14",8.135,null],[14,"BXD15",8.253,null],[15,"BXD16",8.335,null],[16,"BXD18",8.208,null],[17,"BXD19",8.239,null],[19,"BXD21",8.158,null],[20,"BXD22",8.226,null],[22,"BXD24",8.043,null],[23,"BXD25",7.947,null],[24,"BXD27",8.201,null],[25,"BXD28",8.068,null],[26,"BXD29",8.238,null],[27,"BXD30",8.223,null],[28,"BXD31",8.119,null],[29,"BXD32",8.039,null],[30,"BXD33",8.271,null],[31,"BXD34",8.314,null],[33,"BXD36",8.194,null],[35,"BXD38",8.163,null],[36,"BXD39",8.197,null],[37,"BXD40",8.15,null],[39,"BXD42",8.231,null]]
```

here another example of a sample that includes parent values and stderr:

```js
curl "http://test-gn2.genenetwork.org/api_pre1/trait/HC_M2_0606_P/1443823_s_at.json"

[[1,"B6D2F1",15.251,0.136],[2,"C57BL/6J",15.626,0.28],[3,"DBA/2J",14.716,0.26],[4,"BXD1",15.198,0.153],[5,"BXD2",14.918,0.023],[6,"BXD5",15.057,0.273],[7,"BXD6",15.232,0.107],[8,"BXD8",14.968,0.189],[9,"BXD9",14.87,0.454],[10,"BXD11",15.084,0.082],[11,"BXD12",15.192,0.298],[12,"BXD13",14.924,0.33],[14,"BXD15",15.343,0.34],[15,"BXD16",15.226,0.071],[17,"BXD19",15.364,0.074],[18,"BXD20",15.36,0.103],[19,"BXD21",14.792,0.911],...
```

GN2 can also return the phenotypes in the R/qtl2 CSV data format as
described
[here](http://kbroman.org/qtl2/assets/vignettes/input_files.html).

```js
curl "http://test-gn2.genenetwork.org/api_pre1/trait/HC_U_0304_R/104617_at.csv"

id,value
4,8.049
5,8.116
6,8.064
7,8.17
8,8.067
9,8.105
10,8.317
```

Note that the identifiers match the strain ID. Getting information on these,
as well as the individual genotypes is WIP.

### Fetch genotypes

GN2 returns the genotypes in the R/qtl2 CSV data format as described
[here](http://kbroman.org/qtl2/assets/vignettes/input_files.html). Note
that we offer genotypes in the transposed form (row = marker).

```sh
curl "http://test-gn2.genenetwork.org/api_pre1/genotype/mouse/BXD/geno.csv"
```

returns

```csv
BXD5,BXD6,BXD8,BXD9,BXD11,BXD12,BXD13,BXD14,BXD15,BXD16,BXD18,BXD19,BXD20,BXD21,BXD22,BXD23,BXD24a,BXD24,BXD25,BXD27,BXD28,BXD29,BXD30,BXD31,BXD32,BXD33,BXD34,BXD35,BXD36,BXD37,BXD38,BXD39,BXD40,BXD41,BXD42,BXD43,BXD44,BXD45,BXD48,BXD49,BXD50,BXD51,BXD52,BXD53,BXD54,BXD55,BXD56,BXD59,BXD60,BXD61,BXD62,BXD63,BXD64,BXD65,BXD66,BXD67,BXD68,BXD69,BXD70,BXD71,BXD72,BXD73,BXD74,BXD75,BXD76,BXD77,BXD78,BXD79,BXD80,BXD81,BXD83,BXD84,BXD85,BXD86,BXD87,BXD88,BXD89,BXD90,BXD91,BXD92,BXD93,BXD94,BXD95,BXD96,BXD97,BXD98,BXD99,BXD100,BXD101,BXD102,BXD103
rs6269442,B,B,D,D,D,B,B,D,B,B,D,D,B,D,D,D,D,B,B,B,D,B,D,D,B,B,B,B,B,B,B,B,B,D,B,D,B,B,D,B,B,H,H,B,D,B,B,H,H,B,B,D,D,D,D,D,B,B,H,B,B,B,B,D,B,D,B,D,D,D,D,D,H,B,D,D,B,D,B,B,D,D,B,D,D,B,B,B,B,B,B,B,D
rs6365999,B,B,D,D,D,B,B,D,B,B,D,D,B,D,D,D,D,B,B,B,D,B,D,D,B,B,B,B,B,B,B,B,B,D,B,D,B,B,D,B,B,H,H,B,D,B,B,H,H,B,B,D,D,D,D,D,B,B,H,B,B,B,B,D,B,D,B,D,D,D,D,D,H,B,D,D,B,D,B,B,D,D,B,D,D,B,B,B,B,B,B,U,D
rs6376963,B,B,D,D,D,B,B,D,B,B,D,D,B,D,D,D,D,B,B,B,D,B,D,D,B,B,B,B,B,B,B,B,B,D,B,D,B,D,D,B,B,H,H,B,B,B,B,H,H,B,B,D,D,D,D,B,B,B,H,B,B,B,B,D,B,D,B,D,D,D,D,D,H,B,D,D,B,D,B,B,D,D,B,D,D,B,B,B,B,B,B,U,D
```

The meta file can be fetched with

```sh
curl "http://test-gn2.genenetwork.org/api_pre1/genotype/mouse/BXD.json"
```

returning

```js
{"description":"BXD","crosstype":"riself","geno":"BXD/BXD_geno_6a766888cf7a5b5b9376ee165b4518ab_20150722.csv","geno_transposed":true,"metadata":{"original":{"source":"GeneNetwork","unique_id":"42171462281377824604ec3d83771d79","date":"20150722"},"geno":{"unique_id":"6a766888cf7a5b5b9376ee165b4518ab","date":"20150722"},"gmap":{"unique_id":"dfbafbe862fb3572d3e847b7b7859540","date":"20150722"},"genotypes_descr":{"1":"maternal","2":"paternal","3":"heterozygous"}},"genotypes":{"B":1,"D":2,"H":3},"x_chr":"X","na.strings":["U"],"gmap":"BXD/BXD_gmap_dfbafbe862fb3572d3e847b7b7859540_20150722.csv"}
```

which describes the genotypes used (B, D and U).

Furthermore there is the gmap data with

```sh
curl "http://test-gn2.genenetwork.org/api_pre1/genotype/mouse/BXD/gmap.csv"
```

```csv
rs6269442,1,0.0,3.482275
rs6365999,1,0.0,4.811062
rs6376963,1,0.895,5.008089
```

A larger BXD17K is available through

```sh
curl "http://test-gn2.genenetwork.org/api_pre1/genotype/mouse/BXD17K.json"
```
