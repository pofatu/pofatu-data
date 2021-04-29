# pofatu-data

This repository is used for curating the Pofatu dataset, which is browsable online at
https://pofatu.clld.org and [published on Zenodo]().

[Released versions](https://github.com/pofatu/pofatu-data/releases) of this repository
provide analysis-friendly formats of the data in the [`dist`](dist/) directory, in particular:

- a set of CSV files, described by [metadata](dist/metadata.json), following the 
  [CSV on the Web - CSVW](https://www.w3.org/TR/tabular-data-primer/) standard.
- an [SQLite](https://sqlite.org/index.html) database file.

See also

> Hermann, A., Forkel, R., McAlister, A. et al. Pofatu, a curated and open-access database for geochemical sourcing of archaeological materials. Sci Data 7, 141 (2020). DOI: [10.1038/s41597-020-0485-8](https://doi.org/10.1038/s41597-020-0485-8)

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

From `dist/metadata.json` we learn that `dist/samples.csv` contains a column `location_region`,
which specifies a rough region in which a sample was collected.

```shell
$ csvcut -c location_region dist/samples.csv | sort | uniq
AUSTRAL
...
VANUATU
```

If we are interested in samples from Vanuatu, we can then list `ID`s of these:

```shell
$ csvgrep -c location_region -m VANUATU dist/samples.csv | csvcut -c ID
ID
reepmeyer2008_ANU9001
reepmeyer2008_ANU9002
...
```

Once we have identified a sample we are interested in, we can list all measurements recorded in
Pofatu about this sample:

```shell
$ csvcut -c Sample_ID,parameter,value_string dist/measurements.csv | csvgrep -c Sample_ID -m"reepmeyer2008_ANU9001" | csvcut -c parameter,value_string
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
    m.sample_id = s.id and s.location_region == 'VANUATU';
```

We can do so using the [SQLite command line program](https://www.sqlite.org/download.html):
```shell script
$ sqlite3 dist/pofatu.sqlite "select s.id, m.parameter, m.value_string from \"samples.csv\" as s, \"measurements.csv\" as m where m.sample_id = s.id and s.location_region == 'VANUATU'"
reepmeyer2008_ANU9001|SiO2 [%]|70.98
reepmeyer2008_ANU9001|TiO2 [%]|0.36
reepmeyer2008_ANU9001|Al2O3 [%]|14.02
reepmeyer2008_ANU9001|FeO [%]|3.02
reepmeyer2008_ANU9001|CaO [%]|0.99
reepmeyer2008_ANU9001|MgO [%]|0.19
reepmeyer2008_ANU9001|MnO [%]|0.17
reepmeyer2008_ANU9001|K2O [%]|5.67
reepmeyer2008_ANU9001|Na2O [%]|4.27
reepmeyer2008_ANU9001|P [ppm]|285.3549225066772
...
```

If you installed the Python package [`pypofatu`](https://pypi.org/project/pypofatu/), you can run
the query using the `pofatu query` subcommand:
```shell script
$ pofatu query "select s.id, m.parameter, m.value_string from \"samples.csv\" as s, \"measurements.csv\" as m where m.sample_id = s.id and s.location_region == 'VANUATU' limit 10"
INFO    SQLite database at dist/pofatu.sqlite
ID                         parameter      value_string
reepmeyer2008_ANU9001  SiO2 [%]              70.98
reepmeyer2008_ANU9001  TiO2 [%]               0.36
reepmeyer2008_ANU9001  Al2O3 [%]             14.02
reepmeyer2008_ANU9001  FeO [%]                3.02
reepmeyer2008_ANU9001  CaO [%]                0.99
reepmeyer2008_ANU9001  MgO [%]                0.19
reepmeyer2008_ANU9001  MnO [%]                0.17
reepmeyer2008_ANU9001  K2O [%]                5.67
reepmeyer2008_ANU9001  Na2O [%]               4.27
reepmeyer2008_ANU9001  P [ppm]              285.35
```

You can also explore the data using the [datasette](https://datasette.readthedocs.io/en/stable/installation.html#install-using-pip)
tool, which provides a user interface to browse the databases in your browser.

For a more real-life example of using Pofatu data, see [the cookbook](doc/cookbook.md)

Exporting the results of a query to CSV is simple. See the relevant 
[section of the SQLite documentation](https://sqlite.org/cli.html#csv_export)
for details.
