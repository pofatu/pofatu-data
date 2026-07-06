# Releasing Pofatu data

Make sure, `pypofatu` is installed:
```shell
pip install -U pypofatu
```


1. Check data consistency running
   ```shell
   pofatu check
   ```
   Some warnings about "missing methods" are expected.

2. Create the data formats for distribution, running
   ```shell
   pofatu dist
   ```

3. Validate the CSVW data (the `--lax` option is necessary to allow for null-valued foreign keys,
   cf. the "missing methods" reported above):
   ```shell
   csvwvalidate dist/metadata.json --lax
   ```

4. Test the distribution data by re-running the examples in [README.md](README.md)
   and [cookbook][doc/cookbook.md].
   ```shell
   csvcut -c location_region dist/samples.csv | sort | uniq
   ```
   ```shell
   csvgrep -c location_region -m VANUATU dist/samples.csv | csvcut -c ID
   ```
   ```shell
   csvcut -c Sample_ID,parameter,value_string dist/measurements.csv | csvgrep -c Sample_ID -m"reepmeyer2008_ANU9001" | csvcut -c parameter,value_string
   ```
   ```shell
   pofatu query "select s.id, m.parameter, m.value_string from \"samples.csv\" as s, \"measurements.csv\" as m where m.sample_id = s.id and s.location_region == 'VANUATU' limit 10"
   ```
   ```shell
   sqlite3 dist/pofatu.sqlite "select s.id, m.parameter, m.value_string from \"samples.csv\" as s, \"measurements.csv\" as m where m.sample_id = s.id and s.location_region == 'VANUATU'"
   ```
   ```shell
   cat doc/query.sql | sqlite3 dist/pofatu.sqlite -csv -header
   ```
   ```shell
   cat doc/query_mm.sql | sqlite3 dist/pofatu.sqlite -csv -header
   ```
   ```shell
   cat doc/query_combined.sql | sqlite3 dist/pofatu.sqlite -csv -header | wc -l
   ```
   >= 1159

5. Commit and push all changes.

6. Create a release on GitHub

7. Edit the release's metadata on Zenodo

8. Copy the Zenodo DOI into the GitHub release description.

9. Update the [clld app](https://pofatu.clld.org):
   ```shell
   cd ../pofatu
   clld initdb development.ini
   pytest
   ```

10. Deploy the app.

