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
