import itertools

from pypofatu.dataset import Dataset


def test_Dataset():
    ds = Dataset()
    dps = list(ds.iterdata())
    assert len(dps) == 4335
    assert len(list(ds.itersources())) == 106
    assert len(list(ds.itercontributions())) == 30
    assert len(list(ds.itermethods())) == 1380
