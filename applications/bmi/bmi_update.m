function bmi_update(bmidll, dt)
[dt] = calllib(bmidll, 'update', dt);