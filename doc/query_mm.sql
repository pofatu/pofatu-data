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
