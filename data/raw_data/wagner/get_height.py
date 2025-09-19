# mamba env create -f get_era_ee.yml 
# mamba activate get-era-ee
# python get_era_ee.py > log_ee.txt

import xarray as xr
import ee

ee.Initialize(project="ee-sylvainmschmitt", opt_url='https://earthengine-highvolume.googleapis.com')
ic = ee.ImageCollection(ee.Image("projects/sat-io/open-datasets/CTREES/AMAZON-CANOPY-TREE-HT"))
leg = ee.Geometry.Rectangle([-53, 4, -52, 5], proj="EPSG:4326")
ds = xr.open_mfdataset([ic], engine='ee', projection="EPSG:4326", scale = 0.0001, geometry=leg)
ds.to_netcdf('canopy_height.nc')

# csv transfer
ds = xr.open_mfdataset("canopy_height.nc")
ds_df = ds.to_dataframe()
ds_df.to_csv("canopy_height.tsv", sep="\t", index=True)
