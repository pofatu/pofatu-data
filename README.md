# pofatu-data

This repository is used for curating the Pofatu dataset, which is browsable online at
https://pofatu.clld.org and [published on Zenodo]().

[Released versions](https://github.com/pofatu/pofatu-data/releases) of this repository
provide analysis-friendly formats of the data in the [`dist`](dist/) directory, in particular:

- a set of CSV files, described by [metadata](dist/metadata.json), following the 
  [CSV on the Web - CSVW](https://www.w3.org/TR/tabular-data-primer/) standard.
- an [SQLite](https://sqlite.org/index.html) database file.

In the following, we assume that:
- you have the Pofatu data available locally, either
through downloading a [released versions](https://github.com/pofatu/pofatu-data/releases) or via cloning the repository using `git`,
- you have navigated in the shell to the root of the repository, i.e. the directory
  where this README.md is located.


## Querying the CSVW data

While somewhat tedious, the CSVW data can be queried almost "manually", i.e. with very little
tooling. In the following example we will use command line tools available in the [csvkit](https://csvkit.readthedocs.io/en/1.0.3/cli.html)
package, but scientific computing environments like R (with R-Studio) or Python (with Pandas)
will provide similar (or better) functionality.

From `dist/metadata.json` we learn that `dist/samples.csv` contains a column `location_loc1`,
which specifies a rough region in which a sample was collected.

```shell script
$ csvcut -c location_loc1 dist/samples.csv | sort | uniq
AUSTRAL
...
VANUATU
```

If we are interested in samples from Vanuatu, we can then list `ID`s of these:

```shell script
$ csvgrep -c location_loc1 -m VANUATU dist/samples.csv | csvcut -c ID
ID
Reepmeyer-2008-AO_ANU9001
Reepmeyer-2008-AO_ANU9002
...
```

Once we have identified a sample we are interested in, we can list all measurements recorded in
Pofatu about this sample:

```shell script
$ csvcut -c Sample_ID,parameter,value_string dist/measurements.csv | csvgrep -c Sample_ID -m"Reepmeyer-2008-AO_ANU9001" | csvcut -c parameter,value_string
parameter,value_string
SiO2 [%],70.98
TiO2 [%],0.36
Al2O3 [%],14.02
FeO [%],3.02
CaO [%],0.99
MgO [%],0.19
MnO [%],0.17
K2O [%],5.67
Na2O [%],4.27
P [ppm],285.3549225066772
Sc [ppm],9.78581002071119
Ti [ppm],1756.8461601308043
V [ppm],1.2513331781460335
...
```


## Querying the SQLite data

Of course, querying interrelated data from multiple tables is a lot more convenient using a 
relational database. To retrieve **all** measurements for samples from Vanuatu at once, we only
need to run the SQL query
```sql
select
    s.id, m.parameter, m.value_string 
from 
    "samples.csv" as s, "measurements.csv" as m 
where 
    m.sample_id = s.id and s.location_loc1 == 'VANUATU';
```

We can do so using the [SQLite command line program](https://www.sqlite.org/download.html):
```shell script
$ sqlite3 dist/pofatu.sqlite "select s.id, m.parameter, m.value_string from \"samples.csv\" as s, \"measurements.csv\" as m where m.sample_id = s.id and s.location_loc1 == 'VANUATU'"
Reepmeyer-2008-AO_ANU9001|SiO2 [%]|70.98
Reepmeyer-2008-AO_ANU9001|TiO2 [%]|0.36
Reepmeyer-2008-AO_ANU9001|Al2O3 [%]|14.02
Reepmeyer-2008-AO_ANU9001|FeO [%]|3.02
Reepmeyer-2008-AO_ANU9001|CaO [%]|0.99
Reepmeyer-2008-AO_ANU9001|MgO [%]|0.19
Reepmeyer-2008-AO_ANU9001|MnO [%]|0.17
Reepmeyer-2008-AO_ANU9001|K2O [%]|5.67
Reepmeyer-2008-AO_ANU9001|Na2O [%]|4.27
Reepmeyer-2008-AO_ANU9001|P [ppm]|285.3549225066772
...
```

But we could also use a graphical user interface such as the Firefox add-on [SQLite manager](https://addons.mozilla.org/en-US/firefox/addon/sqlite-manager-webext/).

If you installed the Python package [`pypofatu`](https://pypi.org/project/pypofatu/), you can run
the query using the `pofatu query` subcommand:
```shell script
$ pofatu query "select s.id, m.parameter, m.value_string from \"samples.csv\" as s, \"measurements.csv\" as m where m.sample_id = s.id and s.location_loc1 == 'VANUATU' limit 10"
INFO    SQLite database at dist/pofatu.sqlite
ID                         parameter      value_string
Reepmeyer-2008-AO_ANU9001  SiO2 [%]              70.98
Reepmeyer-2008-AO_ANU9001  TiO2 [%]               0.36
Reepmeyer-2008-AO_ANU9001  Al2O3 [%]             14.02
Reepmeyer-2008-AO_ANU9001  FeO [%]                3.02
Reepmeyer-2008-AO_ANU9001  CaO [%]                0.99
Reepmeyer-2008-AO_ANU9001  MgO [%]                0.19
Reepmeyer-2008-AO_ANU9001  MnO [%]                0.17
Reepmeyer-2008-AO_ANU9001  K2O [%]                5.67
Reepmeyer-2008-AO_ANU9001  Na2O [%]               4.27
Reepmeyer-2008-AO_ANU9001  P [ppm]              285.35
```


As a more real-life example, we query the SQLite database to retrieve all samples
with measurements matching the following set of criteria:
- 45 < SiO2 < 48.8
- 0.95 < K2O < 2
- 3 < Na2O < 3.37
- 280 < V < 333
- 16 < Rb < 31
- 575 < Sr < 622
- 272 < Zr < 354
- 27 < Nb < 30

This translates to the following - somewhat lenghty, but quite transparent - SQL:
```sql
select
  s.id, s.name, s.artefact_id,
  sio2.value_string as "SiO2 [%]",
  k2o.value_string as "K2O [%]",
  na2o.value_string as "Na2O [%]",
  v.value_string as "V [ppm]",
  rb.value_string as "Rb [ppm]",
  sr.value_string as "Sr [ppm]",
  zr.value_string as "Zr [ppm]",
  nb.value_string as "Nb [ppm]"
from
  "samples.csv" as s
  join "measurements.csv" as sio2 on s.id = sio2.sample_id
  join "measurements.csv" as k2o on s.id = k2o.sample_id
  join "measurements.csv" as na2o on s.id = na2o.sample_id
  join "measurements.csv" as v on s.id = v.sample_id
  join "measurements.csv" as rb on s.id = rb.sample_id
  join "measurements.csv" as sr on s.id = sr.sample_id
  join "measurements.csv" as zr on s.id = zr.sample_id
  join "measurements.csv" as nb on s.id = nb.sample_id
where
  sio2.parameter = 'SiO2 [%]' and sio2.value > 45 and sio2.value < 48.8 and
  k2o.parameter = 'K2O [%]' and k2o.value > 0.95 and k2o.value < 2 and
  na2o.parameter = 'Na2O [%]' and na2o.value > 3 and na2o.value < 3.37 and
  v.parameter = 'V [ppm]' and v.value > 280 and v.value < 333 and
  rb.parameter = 'Rb [ppm]' and rb.value > 16 and rb.value < 31 and
  sr.parameter = 'Sr [ppm]' and sr.value > 575 and sr.value < 622 and
  zr.parameter = 'Zr [ppm]' and zr.value > 272 and zr.value < 354 and
  nb.parameter = 'Nb [ppm]' and nb.value > 27 and nb.value < 30
;
```

Saving this query as file `query.sql` and running it as

```shell script
$ cat query.sql | sqlite3 dist/pofatu.sqlite -csv -header
```

yield the following output, suitable for piping into a CSV file:
```csv
ID,name,artefact_id,"SiO2 [%]","K2O [%]","Na2O [%]","V [ppm]","Rb [ppm]","Sr [ppm]","Zr [ppm]","Nb [ppm]"
Collerson-2007-Science_KC-05-11,KC-05-11,KC-05-11-WEISLER,47.83,1.05,3.33,297.9,22.07,602.94,305.62,28.75
Collerson-2007-Science_D465,D465,D465-EMORY,45.23,1.89,3.35,292.7,24.09,600.4,312.3,29.3
Weisler-2016-AO_2012-559,2012-559,EIAO-2012-559,47.35,1.0,3.24,293.0,23.1,614.16,348.0,29.6
Weisler-2016-AO_2012-560,2012-560,EIAO-2012-560,47.28,1.02,3.03,295.0,23.2,618.12,342.0,29.6
Weisler-2016-AO_2012-562,2012-562,EIAO-2012-562,46.99,1.06,3.15,297.0,18.6,621.54,342.0,29.4
Weisler-2016-AO_2012-567,2012-567,EIAO-2012-567,46.74,0.968,3.07,293.0,20.2,601.07,341.0,29.2
Weisler-2016-AO_2012-568,2012-568,EIAO-2012-568,46.81,1.01,3.07,299.0,24.3,614.16,342.0,29.4
Weisler-2016-AO_2012-569,2012-569,EIAO-2012-569,46.97,0.951,3.13,299.0,17.7,612.1,350.0,29.6
Weisler-2016-AO_2012-570,2012-570,EIAO-2012-570,47.06,1.02,3.17,304.0,21.0,605.52,337.0,29.3
Weisler-2016-AO_2012-575,2012-575,EIAO-2012-575,47.0,0.984,3.18,318.0,18.7,613.63,343.0,29.3
Weisler-2016-AO_2012-576,2012-576,EIAO-2012-576,47.49,0.954,3.12,314.0,21.8,610.8,350.0,29.6
Weisler-1998-CurrAnth_2032,2032.0,MANGAREVA-85-2032-GREEN,47.35,1.0,3.34,315.0,18.0,591.0,279.0,29.9
Weisler-1998-CurrAnth_2294,2294.0,MOOREA-85-2294-GREEN,47.27,1.0,3.27,315.0,18.0,593.0,273.0,28.0
Weisler-1998-CurrAnth_832-1,832-1,EIAO-832-1-WEISLER,47.66,1.05,3.35,329.0,20.0,584.0,276.0,28.3
McAlister-2017-PO_118,118.0,NH-ANAHO-118,46.94,0.99,3.18,296.0,22.0,604.0,292.0,29.0
McAlister-2017-PO_119,119.0,NH-ANAHO-119,46.84,1.01,3.2,290.0,21.0,601.0,298.0,29.0
McAlister-2017-PO_1344,1344.0,NH-ANAHO-1344,46.72,1.0,3.17,297.0,18.0,592.0,295.0,29.0
McAlister-2017-PO_5071,5071.0,NH-HAKAEA-5071,46.69,0.98,3.22,292.0,19.0,602.0,293.0,28.0
McAlister-2017-PO_5140,5140.0,NH-PUA-5140,46.37,1.0,3.23,298.0,17.0,605.0,295.0,28.0
McAlister-2017-PO_5182,5182.0,NH-PUA-5182,46.83,1.13,3.1,295.0,27.0,590.0,302.0,29.0
Sinton-1997-Database_EIAO-J,EIAO-J,EIAO-EIAO-J,47.65703423620975,1.0137637574177782,3.223768748588535,306.81,17.12,592.5,308.01,28.38
Sinton-1997-Database_I82-N,I82-N,UH-HANE-I82-N,47.84915652873425,1.0289596160310437,3.152772813651769,287.43,20.84,593.42,306.5,28.68
Sinton-1997-Database_M94-62,M94-62,UH-HANE-M94-62,47.670991925270584,0.9834296505213199,3.3456885017735627,297.79,17.09,588.18,304.4,27.87
```

Exporting the results of a query to CSV is simple. See the relevant 
[section of the SQLite documentation](https://sqlite.org/cli.html#csv_export)
for details.
