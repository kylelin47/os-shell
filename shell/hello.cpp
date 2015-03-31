#include <iostream>
#include <string>

main(int argc, char** argv) {
	std::cout << "Hello shell!\n" << std::endl;
	std::cout << "Here is stdin: \n" << std::endl;
    std::string line;
	while (getline(std::cin, line)) std::cout << line << std::endl;
}
