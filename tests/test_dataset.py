import itertools

from pypofatu.dataset import Dataset


def test_Dataset():
    ds = Dataset()
    dps = list(ds.iterdata())
    assert len(dps) == 4117
    assert len(list(ds.itersources())) == 98
    assert len(list(ds.itercontributions())) == 28
