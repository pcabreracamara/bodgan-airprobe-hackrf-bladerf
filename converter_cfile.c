/*
bladeRF binary sc16q12 to GnuRadio complex converter
*/

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    FILE    *fp;
    FILE    *fpout;
    static short    buffer[16384];
    static float    output[16384];
    int   i, length;

    if (argc != 3) {
        fprintf(stderr, "usage: iqtocmplx <infile> <outfile>\n");
        exit(-1);
    }

    /*--- open binary file (for parsing) ---*/
    fp = fopen(argv[1], "rb");
    if (fp == 0) {
        fprintf(stderr, "Cannot open input file <%s>\n", argv[1]);
        exit(-1);
    }

    /*--- open binary file (for parsing) ---*/
    fpout = fopen(argv[2], "wb");
    if (fpout == 0) {
        fprintf(stderr, "Cannot open output file <%s>\n", argv[2]);
        exit(-1);
    }

    while(!feof(fp))  {
        length = fread(&buffer[0], 1, 16384, fp);
        for(i = 0; i < length / 2; i++)  {
            output[i] = (float)buffer[i] * (1.0f/2048.0f);
        }
        fwrite(&output[0], 1, length * 2, fpout);
    }

    fclose(fp);
    fclose(fpout);
    return 0;
}
