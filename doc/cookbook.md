# Recipes for "cooking" with Pofatu

This cookbook collects shareable "recipes", i.e. pieces of code or how-to instructions
for using Pofatu data 
- to answer research questions (e.g. "in which regions do we find samples with high aluminum oxide levels?")
- in particular computing environments (e.g. the "command line", Excel, R, etc.).


## Retrieve samples matching a set of geochemical criteria

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


### Retrieving the measurements

These criteria translate to the following - somewhat lenghty, but quite transparent - SQL:
```sql
select
  s.id as sampl_id, s.sample_name, s.artefact_id,
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

Saving this query to a file `query.sql` and running it as

```shell script
$ cat query.sql | sqlite3 dist/pofatu.sqlite -csv -header
```

yield the following output, suitable for piping into a CSV file:
```csv
sampl_id,sample_name,artefact_id,"SiO2 [%]","K2O [%]","Na2O [%]","V [ppm]","Rb [ppm]","Sr [ppm]","Zr [ppm]","Nb [ppm]"
collerson2007_KC-05-11,KC-05-11,KC-05-11-WEISLER,47.83,1.05,3.33,297.9,22.07,602.94,305.62,28.75
collerson2007_D465,D465,D465-EMORY,45.23,1.89,3.35,292.7,24.09,600.4,312.3,29.3
weisler2016_2012-559,2012-559,EIAO-2012-559,47.35,1.0,3.24,293.0,23.1,614.16,348.0,29.6
weisler2016_2012-560,2012-560,EIAO-2012-560,47.28,1.02,3.03,295.0,23.2,618.12,342.0,29.6
weisler2016_2012-562,2012-562,EIAO-2012-562,46.99,1.06,3.15,297.0,18.6,621.54,342.0,29.4
weisler2016_2012-567,2012-567,EIAO-2012-567,46.74,0.968,3.07,293.0,20.2,601.07,341.0,29.2
weisler2016_2012-568,2012-568,EIAO-2012-568,46.81,1.01,3.07,299.0,24.3,614.16,342.0,29.4
weisler2016_2012-569,2012-569,EIAO-2012-569,46.97,0.951,3.13,299.0,17.7,612.1,350.0,29.6
weisler2016_2012-570,2012-570,EIAO-2012-570,47.06,1.02,3.17,304.0,21.0,605.52,337.0,29.3
weisler2016_2012-575,2012-575,EIAO-2012-575,47.0,0.984,3.18,318.0,18.7,613.63,343.0,29.3
weisler2016_2012-576,2012-576,EIAO-2012-576,47.49,0.954,3.12,314.0,21.8,610.8,350.0,29.6
weisler1998_2032,2032,MANGAREVA-85-2032-GREEN,47.35,1.0,3.34,315.0,18.0,591.0,279.0,29.9
weisler1998_2294,2294,MOOREA-85-2294-GREEN,47.27,1.0,3.27,315.0,18.0,593.0,273.0,28.0
weisler1998_832-1,832-1,EIAO-832-1-WEISLER,47.66,1.05,3.35,329.0,20.0,584.0,276.0,28.3
mcalister2017_118,118,NH-ANAHO-118,46.94,0.99,3.18,296.0,22.0,604.0,292.0,29.0
mcalister2017_119,119,NH-ANAHO-119,46.84,1.01,3.2,290.0,21.0,601.0,298.0,29.0
mcalister2017_1344,1344,NH-ANAHO-1344,46.72,1.0,3.17,297.0,18.0,592.0,295.0,29.0
mcalister2017_5071,5071,NH-HAKAEA-5071,46.69,0.98,3.22,292.0,19.0,602.0,293.0,28.0
mcalister2017_5140,5140,NH-PUA-5140,46.37,1.0,3.23,298.0,17.0,605.0,295.0,28.0
mcalister2017_5182,5182,NH-PUA-5182,46.83,1.13,3.1,295.0,27.0,590.0,302.0,29.0
sinton1997_EIAO-J,EIAO-J,EIAO-EIAO-J,47.65703424,1.013763757,3.223768749,306.81,17.12,592.5,308.01,28.38
sinton1997_I82-N,I82-N,UH-HANE-I82-N,47.84915653,1.028959616,3.152772814,287.43,20.84,593.42,306.5,28.68
sinton1997_M94-62,M94-62,UH-HANE-M94-62,47.67099193,0.983429651,3.345688502,297.79,17.09,588.18,304.4,27.87
```


### Retrieving methodological metadata

Pofatu also provides detailed methodological metadata for the geochemical data, such as
information about reference samples.

A query like the following can be used to retrieve methodological metadata for
the geochemical data of a particular sample:
```sql
select
  distinct
  s.sample_name,
  m.code,
  m.parameter,
  coalesce(r.sample_name, 'NA') as 'Reference sample name (international standard)',
  coalesce(r.sample_measured_value, 'NA') as 'Measured value',
  coalesce(r.uncertainty, 'NA') as 'SD',
  coalesce(r.uncertainty_unit, 'NA') as 'SD Unit'
from
  "samples.csv" as s
  join "measurements.csv" as d on s.id = d.sample_id
  join "methods.csv" as m on m.id = d.method_id
  left outer join "methods_reference_samples.csv" as mr on mr.method_id = m.id
  left outer join "reference_samples.csv" as r on mr.reference_sample_id = r.id
where
  s.id = 'hermann2017_At3-229-064'
;
```

Note that (some) methodological metadata is not available for a small fraction of Pofatu data.
Thus, we have to use
- a `left outer join` construct to also retrieve measurements with no related method and
- the `coalesce` function to provide string representations of `NULL` values.

The results of this query look as follows:
```csv
sample_name,code,parameter,"Reference sample name (international standard)","Measured value",SD,"SD Unit"
...
At3-229-064,hermann2017_A,Dy,WSE,6,2.9795967841,%
At3-229-064,hermann2017_A,Er,AC-E,15.93,2.516507482,%
At3-229-064,hermann2017_A,Er,JB-2,2.6,21.8387942907,%
At3-229-064,hermann2017_A,Er,WSE,3.02,21.177312178,%
At3-229-064,hermann2017_A,Yb,AC-E,15.66,1.4079126317,%
At3-229-064,hermann2017_A,Yb,JB-2,2.62,2.7650232099,%
At3-229-064,hermann2017_A,Yb,WSE,2.48,1.1237823319,%
At3-229-064,hermann2017_A,Th,AC-E,16.65,2.7552203558,%
At3-229-064,hermann2017_A,Th,JB-2,<LD,0,%
At3-229-064,hermann2017_A,Th,WSE,3,15.0282496621,%
At3-229-064,hermann2017_B,Sr87_Sr86,"NBS 987 ",0.710248,0.000008,2sigma
At3-229-064,hermann2017_C,Pb206_Pb204,"NBS 981",16.9415,0.0052,2sigma
At3-229-064,hermann2017_C,Pb207_Pb204,"NBS 981",15.4924,0.002,2sigma
At3-229-064,hermann2017_C,Pb208_Pb204,"NBS 981",36.701,0.007,2sigma
At3-229-064,hermann2017_D,Age,NA,NA,NA,NA
```

### Putting it all together

Since SQL is a very powerful query language, we can plugin the above query to retrieve
methodological metadata for **all** samples matching the above query:
```sql
select
  distinct
  s.sample_name,
  m.code,
  m.parameter,
  coalesce(r.sample_name, 'NA') as 'Reference sample name (international standard)',
  coalesce(r.sample_measured_value, 'NA') as 'Measured value',
  coalesce(r.uncertainty, 'NA') as 'SD',
  coalesce(r.uncertainty_unit, 'NA') as 'SD Unit'
from
  "samples.csv" as s
  join "measurements.csv" as d on s.id = d.sample_id
  join "methods.csv" as m on m.id = d.method_id
  left outer join "methods_reference_samples.csv" as mr on mr.method_id = m.id
  left outer join "reference_samples.csv" as r on mr.reference_sample_id = r.id
where
  s.id in (
    select  
      s.id
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
  )
;
```
and get
```shell script
$ cat query_combined.sql | sqlite3 dist/pofatu.sqlite -csv -header
sample_name,code,parameter,"Reference sample name (international standard)","Measured value",SD,"SD Unit"
KC-05-11,collerson2007_A,SiO2,BCR-2,54.77,0.11,%
KC-05-11,collerson2007_A,TiO2,BCR-2,2.38,0.11,%
KC-05-11,collerson2007_A,Al2O3,BCR-2,13.53,0.17,%
KC-05-11,collerson2007_A,FeO,BCR-2,10.59,0.19,%
KC-05-11,collerson2007_A,CaO,BCR-2,7.18,0.05,%
KC-05-11,collerson2007_A,MgO,BCR-2,3.63,0.03,%
KC-05-11,collerson2007_A,MnO,BCR-2,0.2,0.001,%
KC-05-11,collerson2007_A,K2O,BCR-2,1.81,0.03,%
KC-05-11,collerson2007_A,Na2O,BCR-2,3.21,0.08,%
...
```
