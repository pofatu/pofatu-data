# Releasing Pofatu data

1. Check data consistency running
   ```shell
   pofatu check
   ```

2. Create the data formats for distribution, running
   ```shell
   pofatu dist
   ```

3. Commit and push all changes.

4. Create a release on GitHub

5. Edit the release's metadata on Zenodo

6. Copy the Zenodo DOI into the GitHub release description.

7. Update the [clld app](https://pofatu.clld.org):
   ```shell
   cd ../pofatu
   clld initdb development.ini
   pytest
   workon appconfig
   cd appconfig/apps/pofatu
   fab deploy:production
   ```

