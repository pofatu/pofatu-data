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
