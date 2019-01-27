#include "stdio.h"
#include <netpbm/pam.h> 


extern void convert(pixel **image, int columns, int rows);


int main(int argc, char *argv[]) {

    int columns, rows;
    pixval max_val;
    if (argc != 2) {
        fprintf(stderr, "Error. Usage: ./convert path_to_ppm_file\n");
        return 1;
    }
    FILE *input, *result;
    input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Error while opening file %s\n", argv[1]);
        return 1;
    }
    printf("Read image\n");
    pixel **image = ppm_readppm(input, &columns, &rows, &max_val);
    fclose(input);

    printf("Convert image\n");
    convert(image, columns, rows);

    gray **new_image = (gray**) image;

    result = fopen("result.pgm", "w");
    if (!result) {
        fprintf(stderr, "Error while opening result file\n");
        return 1;
    }
    printf("Save image\n");
    pgm_writepgm(result, new_image, columns, rows, 255, 1);
    fclose(result);
	return 0;
}
