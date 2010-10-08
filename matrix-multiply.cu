#include <stdio.h>
#include <cuda.h>

typedef float MatrixVal;

typedef struct matrix {
	MatrixVal *values;
	unsigned int rows, cols;
} Matrix;

typedef struct input {
	Matrix *A, *B;
} Input;

void setMatrixPosition(Matrix *matrix, unsigned int row, unsigned int col, MatrixVal value) {
	matrix->values[col + matrix->cols * row] = value;
}

MatrixVal getMatrixPosition(Matrix *matrix, unsigned int row, unsigned int col) {
	return matrix->values[col + matrix->cols * row];
}

void setMatrixSize(Matrix *matrix, unsigned int rows, unsigned int cols) {
	matrix->values = (MatrixVal *) malloc(rows * cols * sizeof(MatrixVal));
	matrix->cols = cols;
	matrix->rows = rows;
}

Matrix *newMatrix() {
	Matrix *matrix = (Matrix *) malloc(sizeof(Matrix));
	return matrix;
}

void deleteMatrix(Matrix *matrix) {
	free(matrix->values);
	free(matrix);
}

Matrix *readMatrixFrom(FILE *src) {
	unsigned int row, col, rows, cols;
	MatrixVal value;
	Matrix *matrix = newMatrix();
	fscanf(src, "%u %u", &rows, &cols);
	setMatrixSize(matrix, rows, cols);
	for (row = 0; row < rows; row++) {
		for (col = 0; col < cols; col++) {
			fscanf(src, "%f", &value);
			setMatrixPosition(matrix, row, col, value);
		}
	}
	return matrix;
}

void deleteInput(Input input) {
	deleteMatrix(input.A);
	deleteMatrix(input.B);
}

Input readMatricesFromFiles(char *fileName1, char *fileName2) {
	Input input;
	FILE *file1, *file2;
	file1 = fopen(fileName1, "r");
	input.A = readMatrixFrom(file1);
	fclose(file1);
	file2 = fopen(fileName2, "r");
	input.B = readMatrixFrom(file2);
	fclose(file2);
	return input;
}

Input readMatricesFromStdin() {
	Input input;
	input.A = readMatrixFrom(stdin);
	input.B = readMatrixFrom(stdin);
	return input;
}

void printUsage() {
	printf("Usage: matrix-multiply <cuda|cpu> [file-with-matrix1 file-with-matrix2]\n");
	printf("\nIf files are not passed, matrices are read from stdin.\n");
	printf("Input format: n-rows n-cols entries\n");
	printf("Output format: n-rows n-cols result-entries\n");
	printf("Output is always to stdout\n");
}

void processUsingCuda(Input input) {
}

void processUsingCpu(Input input) {
}

int main(int argc, char **argv) {
	Input input;
	if (argc == 2) {
		input = readMatricesFromStdin();
	} else if (argc == 4) {
		input = readMatricesFromFiles(argv[2], argv[3]);
	} else {
		printf("Error: wrong number of arguments: %d\n", argc);
		printUsage();
		return 1;
	}
	if (strcmp(argv[1], "cuda") == 0) {
		processUsingCuda(input);
	} else if (strcmp(argv[1], "cpu") == 0) {
		processUsingCpu(input);
	} else {
		printf("Error: %s is not a valid form of computation\n");
		printUsage();
		return 2;
	}
	return 0;
}
