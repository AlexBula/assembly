/*
 Aleksander Buła, 370738
*/

#include "stdio.h"
#include "stdlib.h"


extern void start(int width, int height, void *M);
extern void step();

/* Data structure for holding the floats
   1st - current status
   2nd - status in the next step */
typedef struct data {
    int x;
    int y;
} data;


void parse_matrix(data *M, FILE *input, int columns, int rows) {
    int tmp, i, j;
    printf("Read matrix values\n");
    for(i = 1; i < rows - 1; ++i) {
        for(j = 1; j < columns - 1; ++j) {
            if (fscanf(input, "%d", &tmp) == EOF) {
                fprintf(stderr, "Errow while reading input file (values)\n");
                exit(1);
            }
            /* Add 1 -> 0 is used as a border */
            M[i * columns + j].x = tmp;
            M[i * columns + j].y = tmp;
        }
    }
}


void show_simulation(data *M, int columns, int rows) {
    int i, j;
    for(i = 1; i < rows - 1; ++i) {
        for(j = 1; j < columns - 1; ++j) {
            printf("%d ",M[i * columns + j].x);
        }
        printf("\n");
    }
}


int main(int argc, char *argv[]) {
    int columns, rows, steps = 0, i;
    FILE *input;
    
    printf("Begin the preparations\n");
    /* Parse the command line arguments */
    if (argc != 3) {
        fprintf(stderr, "Error! Usage: ./life \
path_to_file number_of_steps\n");
        exit(1);
    }

    steps = atoi(argv[2]);

    input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Error while opening file %s\n", argv[1]);
        exit(1);
    }

    /* Get the columns and rows value */
    printf("Read size\n");
    if (fscanf(input, "%d %d", &columns, &rows) == EOF) {
        fprintf(stderr, "Error while reading input file (size)\n");
        exit(1);
    }
    
    /* Expand the matrix for border cases */
    columns += 2;
    rows += 2;

    data *M = (data*)calloc(columns * rows, sizeof(data));
    if (!M) {
        fprintf(stderr, "Failed to allocate memory\n");
        exit(1);
    }

    /* Parse the matrix values from the file */
    parse_matrix(M, input, columns, rows);

    fclose(input);


    /**********************/
    /*    Game of Life    */
    /**********************/
    printf("Start the setup\n");
    start(columns, rows, (void*) M);

    printf("Start the game of life\nInitial state:\n");
    show_simulation(M, columns, rows);

    for(i = 1; i <= steps; ++i) {
        printf("After step %d:\n", i);
        step();
        // if (i % 2 == 1) 
        show_simulation(M, columns, rows);
    }

    printf("End the game of life\n");
	return 0;
}
