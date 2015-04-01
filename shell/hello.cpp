#include <iostream>
#include <string>
#include <cstdio>

main(int argc, char** argv) {
	std::cout << "Hello shell!\n" << std::endl;
	std::cout << "Here is stdin: \n" << std::endl;
    std::string line;
	while (getline(std::cin, line)) {
		std::cout << line << std::endl;
		if (line[0]=='e') {
			std::cerr << "This is an error!!!" << std::endl;
		}
		if (line[0]=='0') {
			std::cout<<"exiting hello.cpp"<<std::endl;
			return 0;
		}
	}
}
