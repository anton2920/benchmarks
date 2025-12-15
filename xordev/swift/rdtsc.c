#include <immintrin.h>

unsigned long long
rdtsc(void)
{
	return __rdtsc();
}
