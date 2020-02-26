#define  FMT_HEADER_ONLY

#include "fmt/format.h"
#include "fmt/format-inl.h"
#include "fmt/printf.h"
int main()
{
    fmt::print("Hello, {}!", "world");  // uses Python-like format string syntax
    fmt::printf("Hello, %s!", "world"); // uses printf format string syntax
}
