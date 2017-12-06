#include <iostream>
#include <math.h>

// TODO: find proper alignment (__align__(x))
struct node {
    int value;
    int children[8];
    int next;
};

// function to add the elements of a static array and a more dynamic tree structure
__global__
void add(int n, float* a, node* nodes, float* b) {
    printf("hello world from the device!\n"); 
    int index = threadIdx.x;
    int stride = blockDim.x;
    int childID = 0;
    //int childID = nodes[0].children[0];
    for (int i = index; i < n; i += stride)
        b[i] += a[i] + nodes[childID].value;
}

int main(void) {
    // 1 + 8 + 8*8 + 8*8*8
    int N = 585;
    //int N = 1<<20;

    // create buffers
    float *a, *b;

    // initialize a and b arrays on the host
    for (int i = 0; i < N; i++) {
        a[i] = 1.0f;
        b[i] = 2.0f;
    }

    // create node buffer
    node nodes[N];
    // initialize "tree" structure
    // calculate the required depth for our structure first
    int depth = 1;
    int x = N;
    while (x >= 8) {
        x -= x % 8;
        x /= 8;
        depth++;
    }

    int rootnodelength = 1;
    for (int d = 0; d < depth; d++) {
        rootnodelength *= 8;
    }
    // pad rootnodelength with unused fields
    rootnodelength += N % rootnodelength;
    rootnodelength += 1;

    for (int i = 0; i < N; i++) {
        // replace depth with current depth
        nodes[i].value = (100 * depth) + i;
        // logarithm of x base b = log(x)/log(b)
        // TODO: create some sort of magical function to get the current depth for i
        // using a log base 8 function and more sik math skills
        // then populate nodes and their indeces in accordance with the current depth

        // for testing purposes **ONLY**
        for (int j = 0; j < 8; j++) {
            // set all children to node number 1 (yeah I know pretty lame)
            nodes[i].children[j] = 1;
        }
        // also set next temporarily
        nodes[i].next = 2;
    }

    printf("aaaaaaaaaaaaaaaa\n");
    // create space in memory for a copy of nodes to be used by the device
    node *nodes_d;
    cudaMallocManaged(&a, N * sizeof(float));
    cudaMallocManaged(&b, N * sizeof(float));
    cudaMallocManaged((void**) &nodes_d, sizeof(node) * sizeof(nodes));

    // copy nodes buffer to nodes_d (memory space we allocated for the device)
    cudaMemcpy(nodes_d, nodes, sizeof(node) * sizeof(node), cudaMemcpyHostToDevice);
    // suffering
    printf("AAAAAAAAAAAA\n");
    add<<<1, 256>>>(N, a, nodes, b);

    // wait for gpu (blocks thread till end is signaled)
    cudaDeviceSynchronize();
    // even more suffering
    printf("aaaaaabbbbbbbbbbbbbbbb");

    /*
    float max_error = 0.0f;
    for (int i = 0; i < N; i++)
        max_error = fmax(max_error, fabs(b[i]));
    std::cout << "max error: " << max_error << std::endl;
    */

    float median = 0.0f;
    for (int i = 0; i < N; i++) {
        median = fmax(median, fabs(b[i]));
    }
    std::cout << "median : " << median << "\n";

    // free memory
    cudaFree(a);
    cudaFree(b);
    cudaFree(nodes);

    return 0;
}
