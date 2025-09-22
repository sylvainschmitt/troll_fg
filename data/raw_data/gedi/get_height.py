# mamba env create -f get_era_ee.yml 
# mamba activate get-era-ee
# python get_era_ee.py > log_ee.txt

import xarray as xr
import ee

ee.Initialize(project="ee-sylvainmschmitt", opt_url='https://earthengine-highvolume.googleapis.com')
ic = ee.ImageCollection("LARSE/GEDI/GEDI02_A_002_MONTHLY")
leg = ee.Geometry.Rectangle([-53, 4, -52, 5], proj="EPSG:4326")
ds = xr.open_mfdataset([ic], engine='ee', projection="EPSG:4326", scale = 0.01, geometry=leg, fast_time_slicing=True)
ds = ds[['rh98']]

# from matplotlib import pyplot as plt
# ds.rh98.plot()
# plt.show()

ds.to_netcdf('canopy_height.nc')

# csv transfer
ds = xr.open_mfdataset("canopy_height.nc")
ds_df = ds.to_dataframe()
ds_sub = ds_df.dropna()
ds_sub.to_csv("canopy_height.tsv", sep="\t", index=True)
