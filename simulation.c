/*
 Aleksander Buła, 370738
 Program korzysta z macierzy takiej jak w poleceniu (z grzejnikami i chłodnicami)
 Każda komórka macierzy trzyma dwie wartości typu float:
    * obecna temperature
    * nową temperature
 Funkcja step() przechodzi po całej macierzy odpowiednio wyliczając
 nową temperature dla kazdej z komórek. Następnie wykonywane jest drugie
 przejście które nadpisuje obecne wartości na nowo obliczone.
*/

#include "stdio.h"
#include "stdlib.h"


extern void start(int width, int height, void *M, 
    float *G, float *C, float w);
extern void step();

/* Data structure for holding the floats
   1st - current temperature value
   2nd - newly calcualted temperature value
*/
typedef struct data {
    float x;
    float y;
} data;


void parse_matrix(data *M, FILE *input, int columns, int rows) {
    float tmp;

    printf("Read matrix values\n");
    for(int i = 1; i < rows - 1; ++i) {
        for(int j = 1; j < columns - 1; ++j) {
            if (fscanf(input, "%f", &tmp) == EOF) {
                fprintf(stderr, "Errow while reading input file (values)\n");
                exit(1);
            }
            M[i * columns + j].x = tmp;
        }
    }

    printf("Read heater values\n");
    for(int i = 1; i < columns - 1; ++i) {
        if (fscanf(input, "%f", &tmp) == EOF) {
            fprintf(stderr, "Errow eawhile reading input file (heaters)\n");
            exit(1);
        }
        M[i].x = tmp;
        M[i].y = tmp;
        M[(rows - 1) * columns + i].x = tmp;
        M[(rows - 1) * columns + i].y = tmp;
    }

    printf("Read radiators values\n");
    for(int i = 1; i < rows - 1; ++i) {
        if (fscanf(input, "%f", &tmp) == EOF) {
            fprintf(stderr, "Errow while reading input file (radiators)\n");
            exit(1);
        }
        M[i * rows].x = tmp;
        M[i * rows].y = tmp;
        M[i * rows + (columns - 1)].x = M[i * rows].x;
        M[i * rows + (columns - 1)].y = M[i * rows].y;
    }
}


void show_simulation(data *M, int columns, int rows) {
    for(int i = 0; i < rows; ++i) {

        for(int j = 0; j < columns; ++j) {
            if ((i == 0 && j == 0) ||
                (i == rows - 1 && j == 0) || 
                (i == 0 && j == columns - 1) ||
                (i == rows - 1 && j == columns - 1)) 
                printf("XXXX ");
            else {
                printf("%.2f ",M[i * columns + j].x);
            }
        }
        printf("\n");
    }
}


int main(int argc, char *argv[]) {
    int columns, rows, steps = 0;
    float coefficient = 0.0;
    FILE *input;

    /* Parse the command line arguments */
    if (argc != 4) {
        fprintf(stderr, "Error! Usage: ./simulation \
path_to_file coefficient number_of_steps\n");
        exit(1);
    }

    coefficient = atof(argv[2]);
    steps = atoi(argv[3]);

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

    /* Increase the value in order to fit 
    the heaters and the radiators in the matrix */
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
    /* Run the simulation */
    /**********************/
    printf("Start the setup\n");
    start(columns, rows, (void*) M, NULL, NULL, coefficient);

    printf("Run simulation\nInitial temperature:\n");
    show_simulation(M, columns, rows);
    
    for(int i = 1; i <= steps; ++i) {
        printf("After step %d:\n", i);
        step();
        // if (i % 2 == 1) 
        show_simulation(M, columns, rows);
    }

    printf("End the simulation\n");
	return 0;
}
