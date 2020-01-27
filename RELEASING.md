# Releasing Pofatu data

1. Update the ["raw" data](raw/) in the repository.

2. Dump the Pofatu excel file to CSV, running
   ```shell script
   pufatu dump
   ```

3. Check data consistency running
   ```shell script
   pufatu check
   ```

4. Create the data formats for distribution, running
   ```shell script
   pufatu dist
   ```

5. Commit and push all changes.

6. Create a release on GitHub

7. Edit the release's metadata on Zenodo

8. Copy the Zenodo DOI into the GitHub release description.

9. Update the [clld app](https://pofatu.clld.org)
