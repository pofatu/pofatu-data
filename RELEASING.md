# Releasing Pofatu data

1. Update the ["raw" data](raw/) in the repository.

2. Dump the Pofatu excel file to CSV, running
   ```shell
   pofatu dump
   ```

3. Check data consistency running
   ```shell
   pofatu check
   ```

4. Create the data formats for distribution, running
   ```shell
   pofatu dist
   ```

5. Commit and push all changes.

6. Create a release on GitHub

7. Edit the release's metadata on Zenodo

8. Copy the Zenodo DOI into the GitHub release description.

9. Update the [clld app](https://pofatu.clld.org):
   ```shell
   cd ../pofatu
   clld initdb development.ini
   pytest
   workon appconfig
   cd appconfig/apps/pofatu
   fab deploy:production
   ```

