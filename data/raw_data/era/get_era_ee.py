# mamba env create -f get_era_ee.yml 
# mamba activate get-era-ee
# python get_era_ee.py > log_ee.txt

import ee
import xarray as xr
import numpy as np

ee.Initialize(project="ee-sylvainmschmitt", opt_url='https://earthengine-highvolume.googleapis.com')
ic = ee.ImageCollection("ECMWF/ERA5_LAND/HOURLY").filter(ee.Filter.date('1980-01-01', '2025-01-01'))
# ic = ee.ImageCollection("ECMWF/ERA5_LAND/HOURLY").filter(ee.Filter.date('2000-01-01', '2001-01-01'))
leg = ee.Geometry.Rectangle(-53, 4, -52, 5)
ds = xr.open_mfdataset([ic], engine='ee', projection=ic.first().select(0).projection(), geometry=leg, fast_time_slicing=True)
ds = ds[['dewpoint_temperature_2m', 'temperature_2m', 'surface_net_solar_radiation', 'surface_pressure',
         'u_component_of_wind_10m', 'v_component_of_wind_10m', 'total_precipitation_hourly']]

# saturated                      
ds['tas'] = ds['temperature_2m'] - 273.15
ds['bsat'] = 18.678 - (ds['tas'] / 234.5)
ds['fsat'] = 1.00072 + 10**-7 * 101325 * (0.032 + 5.9 * 10**-6 * ds['tas']**2)
ds['esat'] = ds['fsat'] * 611.21 * (np.exp(ds['bsat'] * ds['tas'] / (257.14 + ds['tas'])))

# actual vapor pressure
ds['sp'] = ds['surface_pressure']
ds['tdew'] = ds['dewpoint_temperature_2m'] - 273.15
ds['b'] = 18.678 - (ds['tdew'] / 234.5)
ds['f'] = 1.00072 + 10**-7 * ds['sp'] * (0.032 + 5.9 * 10**-6 * ds['tdew']**2)
ds['e'] = ds['f'] * 611.21 * (np.exp(ds['b'] * ds['tdew'] / (257.14 + ds['tdew'])))

ds['time'] = ds['time'] - 3*60*60*10**9
ds['vpd'] = (ds['esat'] - ds['e']) / 1000
ds['pr'] = ds['total_precipitation_hourly'] * 1000
ds['snet'] = ds['surface_net_solar_radiation'] / 3600
ds["snet"] = ds["snet"].diff("time").reindex_like(ds["snet"])
ds['snet'] = ds['snet'].clip(min=0)
ds['ws'] = np.sqrt(ds['u_component_of_wind_10m']** 2 + ds['v_component_of_wind_10m']** 2)

ds = ds[['pr', 'snet', 'tas', 'vpd', 'ws']]
ds.to_netcdf('test.nc')

# csv transfer
ds = xr.open_mfdataset("era.nc")
ds_df = ds.to_dataframe()
ds_df.to_csv("era.tsv", sep="\t", index=True)
