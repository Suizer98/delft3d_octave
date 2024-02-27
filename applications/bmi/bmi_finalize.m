function bmi_finalize(bmidll)
calllib(bmidll, 'finalize');
unloadlibrary(bmidll);
end