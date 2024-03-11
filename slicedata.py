import os
import xarray as xr


directory = os.getcwd()
day_counts = 5 * 24

for file in os.listdir(directory):
    # Check if the file starts with "trim"
    if file.startswith("trim") and file.endswith(".nc"):
        dataset_trim = xr.open_dataset(os.path.join(directory, file))
        subset_dataset_trim = dataset_trim.isel(time=slice(0, day_counts))

        # Save the subset dataset to a new NetCDF file
        output_filename = file.replace(".nc", "-5days.nc")
        subset_dataset_trim.to_netcdf(os.path.join(directory, output_filename))
        print(f"Subset dataset '{output_filename}' saved successfully.")

    # Check if the file starts with "trih"
    elif file.startswith("trih") and file.endswith(".nc"):
        dataset_trih = xr.open_dataset(os.path.join(directory, file))
        subset_dataset_trih = dataset_trih.isel(time=slice(0, day_counts))

        # Save the subset dataset to a new NetCDF file
        output_filename = file.replace(".nc", "-5days.nc")
        subset_dataset_trih.to_netcdf(os.path.join(directory, output_filename))
        print(f"Subset dataset '{output_filename}' saved successfully.")
