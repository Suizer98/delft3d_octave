import xarray as xr

# Open the existing dataset
dataset_trim = xr.open_dataset('trim-scsmCddb.nc')
dataset_tirh = xr.open_dataset('trih-scsmCddb.nc')

# Select the first three time steps
subset_dataset_trim = dataset_trim.isel(time=slice(0, 3))
subset_dataset_trih = dataset_tirh.isel(time=slice(0, 3))

# Save the subset dataset to a new NetCDF file
subset_dataset_trim.to_netcdf('fake-trim.nc')
subset_dataset_trih.to_netcdf('fake-trih.nc')
print(subset_dataset_trim['time'].values)
print(subset_dataset_trih['time'].values)

