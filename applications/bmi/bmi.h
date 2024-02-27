void initialize(char* config_file);

void update(double* dt);

void get_var_rank(char* var_name, int* rank);

void get_var_type(char* var_name, char* c_type_name);

void get_var_shape(char* var_name, int shape[6]);


void get_0d_float(char* var_name, float** x);

void get_1d_double(char* var_name, double** x);


void get_1d_float(char* var_name, float** x);
// Pass 2d as vector
void get_2d_float(char* var_name, float** x);


void get_2d_double(char* var_name, double** x);

void get_3d_float(char* var_name, float** x);

void get_3d_double(char* var_name, double** x);

// Should be int32, how to define int here...?
void get_1d_int(char* var_name, int** x);

void get_2d_int(char* var_name, int** x);

void set_1d_float(char* var_name, float** x);

void set_2d_float(char* var_name, float** x);

void set_3d_float(char* var_name, float** x);


void set_1d_double(char* var_name, double** x);

void set_2d_double(char* var_name, double** x);

void set_1d_double_at_index(char* var_name, int* index, double* value);


void finalize();