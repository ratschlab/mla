all:
	$(CXX) -static -O3 --std=c++17 -march=core-avx2 -Wall -Werror -o parse_plast parse_plast.cpp
