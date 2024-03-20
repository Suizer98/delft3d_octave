import os
import pandas as pd
import xarray as xr


self_defined_name = "test"
directory = os.getcwd()

# Convert strings to datetime objects to use in .sel()
start_time = pd.to_datetime("2001-12-31 00:00:00")
end_time = pd.to_datetime("2002-01-01 00:00:00")

for file in os.listdir(directory):
    # Check if the file starts with "trim"
    if file.startswith("trim") and file.endswith(".nc"):
        dataset_trim = xr.open_dataset(os.path.join(directory, file))
        # subset_dataset_trim = dataset_trim.isel(time=slice(0, 3))
        subset_dataset_trim = dataset_trim.sel(time=slice(start_time, end_time))

        # Save the subset dataset to a new NetCDF file
        output_filename = file.replace(".nc", f"-{self_defined_name}.nc")
        subset_dataset_trim.to_netcdf(os.path.join(directory, output_filename))
        print(f"Subset dataset '{output_filename}' saved successfully.")

    # Check if the file starts with "trih"
    elif file.startswith("trih") and file.endswith(".nc"):
        dataset_trih = xr.open_dataset(os.path.join(directory, file))
        subset_dataset_trih = dataset_trih.sel(time=slice(start_time, end_time))

        # Generate new platform names based on the length of the existing platform names
        # platform_names_len = len(subset_dataset_trih["platform_name"])
        # new_platform_names = [f"test-station-{i+1}" for i in range(platform_names_len)]
        # subset_dataset_trih["platform_name"].values = new_platform_names

        # Save the subset dataset to a new NetCDF file
        output_filename = file.replace(".nc", f"-{self_defined_name}.nc")
        subset_dataset_trih.to_netcdf(os.path.join(directory, output_filename))
        print(f"Subset dataset '{output_filename}' saved successfully.")
