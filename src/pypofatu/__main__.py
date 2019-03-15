import sys
import re

from clldutils.clilib import ArgumentParserWithLogging, command
from clldutils.source import Source

from pypofatu.dataset import Dataset
from pypofatu.util import doi2source


@command()
def bibtex(args):
    year_pattern = re.compile('(?P<year>[0-9]{4})\)')
    ds = Dataset()
    for src in sorted(ds.itersources(), key=lambda s: s.id):
        fields, genre = None, 'article'
        if src.doi:
            rec = doi2source(src.doi)
            if rec:
                fields = {k.lower(): v for k, v in rec.items()}
                genre = rec.genre.lower()
        year = year_pattern.search(src.reference)
        if not fields:
            fields = {
                'author': src.reference,
                'title': '',
                'year': year.group('year') if year else '',
                'journal': '',
                'number': '',
                'pages': '',
                'doi': src.doi,
            }
        src = Source(genre, src.id.replace('-', '_'), **fields)
        print('')
        print(src.bibtex())


@command()
def stats(args):
    import attr
    ds = Dataset()
    locs = set(dp.location.name for dp in ds.iterdata())
    for loc in sorted(locs):
        print(loc)
    print('{0} locations'.format(len(locs)))


def main():  # pragma: no cover
    parser = ArgumentParserWithLogging('pypofatu')
    #parser.add_argument(
    #    '--repos',
    #    type=Repos,
    #    default=Repos('dplace-data'),
    #    help='Location of clone of D_PLACE/dplace-data (defaults to ./dplace-data)')
    sys.exit(parser.main())


if __name__ == '__main__':
    main()
